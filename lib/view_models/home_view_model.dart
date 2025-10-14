import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:history_ai/core/services/firebase_chat_service.dart';
import 'package:history_ai/models/chat_history.dart';
import 'package:history_ai/models/home_state.dart';
import 'package:history_ai/models/message.dart';
import 'package:history_ai/models/ai_history_model.dart';
import 'package:history_ai/providers/auth_provider.dart'; // ✅ Import auth provider

class HomeViewModel extends StateNotifier<HomeState> {
  final HistoryAI _aiModel;
  final FirebaseChatService _chatService = FirebaseChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref _ref; // ✅ 1. Thêm Ref vào ViewModel

  StreamSubscription<List<Message>>? _messageSubscription;
  StreamSubscription<List<ChatHistory>>? _chatHistorySubscription; // ✅ Thêm subscription cho lịch sử

  // ✅ 2. Sửa constructor để nhận Ref
  HomeViewModel({required HistoryAI aiModel, required Ref ref})
      : _aiModel = aiModel,
        _ref = ref, // Lưu lại ref
        super(HomeState(
        messages: [],
        chatHistories: [],
        isLoading: false,
        controller: TextEditingController(),
        activeChatId: '',
      )) {
    _init(); // Gọi hàm khởi tạo
  }

  void _init() {
    // Chỉ cần một khối listen là đủ
    _ref.listen<User?>(authProvider, (previousUser, newUser) {
      if (newUser == null) {
        // Người dùng đã đăng xuất
        _cancelAllSubscriptions();
        state = HomeState.initial(); // Tạo một hàm static để reset state
      } else if (previousUser == null && newUser != null) {
        // Người dùng vừa đăng nhập (hoặc đã đăng nhập khi app khởi động)
        _loadInitialChatHistories();
      }
    }, fireImmediately: true); // ✅ Thêm fireImmediately: true
  }


  // ✅ Hàm mới để hủy tất cả các subscription đang chạy
  void _cancelAllSubscriptions() {
    _messageSubscription?.cancel();
    _chatHistorySubscription?.cancel();
    _messageSubscription = null;
    _chatHistorySubscription = null;
  }

  void _loadInitialChatHistories() {
    _chatHistorySubscription?.cancel(); // Hủy sub cũ nếu có
    _chatHistorySubscription = _chatService.getChatHistories().listen((histories) {
      if (!mounted) return; // Kiểm tra nếu ViewModel còn "sống"
      state = state.copyWith(chatHistories: histories);
      if (state.activeChatId.isEmpty && histories.isNotEmpty) {
        loadChat(histories.first.id);
      }
    });
  }

  /// Tạo chat mới và trả về ID của nó.
  Future<String> createNewChat(String title) async { // ✅ Chuyển thành async và trả về Future<String>
    final user = _auth.currentUser;
    // Ném lỗi nếu người dùng không tồn tại
    if (user == null) throw Exception("Người dùng chưa đăng nhập!");

    final newChatId = DateTime.now().millisecondsSinceEpoch.toString();

    // ✅ Dùng await để đảm bảo hàm này hoàn thành trước khi đi tiếp
    await _chatService.createChatRoom(user.uid, newChatId, title);

    // Không cần cập nhật state ở đây nữa vì _loadInitialChatHistories sẽ làm việc đó.
    // Việc này giúp tránh race condition.

    // Tải và kích hoạt chat mới
    loadChat(newChatId);

    return newChatId; // ✅ Trả về ID của chat mới
  }

  /// Load chat theo chatId
  void loadChat(String chatId) {
    // ✅ 3. Hủy listener cũ trước khi tạo listener mới
    _messageSubscription?.cancel();

    state = state.copyWith(
      activeChatId: chatId,
      messages: [], // Xóa tin nhắn cũ để hiển thị loading hoặc chờ dữ liệu mới
    );

    // Bắt đầu listener mới
    _messageSubscription = _chatService.getMessages(chatId).listen((messages) {
      // Chỉ cập nhật nếu listener này vẫn dành cho cuộc trò chuyện đang hoạt động
      if (state.activeChatId == chatId) {
        state = state.copyWith(messages: messages);
        _updateChatHistoryLocally(chatId, messages);
      }
    });
  }

  /// Cập nhật lịch sử chat (chỉ ở trạng thái local)
  void _updateChatHistoryLocally(String chatId, List<Message> messages) {
    final updatedHistories = state.chatHistories.map((chat) {
      if (chat.id == chatId) {
        return chat.copyWith(
          lastMessage: messages.isNotEmpty ? messages.last.text : '',
          // không cần cập nhật messages ở đây vì nó đã ở trong state chính
        );
      }
      return chat;
    }).toList();

    state = state.copyWith(chatHistories: updatedHistories);
  }

  /// Gửi message và gọi AI
  Future<void> callAI() async {
    // ✅ 4. Nếu chưa có chat nào, tự động tạo một chat mới
    if (state.activeChatId.isEmpty) {
      createNewChat("Cuộc trò chuyện mới");
      // Đợi một chút để chat được tạo và active
      await Future.delayed(const Duration(milliseconds: 500));
    }
    String chatId = state.activeChatId;

    // ✅ Nếu chưa có chat, tạo mới và lấy ID
    if (chatId.isEmpty) {
      chatId = await createNewChat("Cuộc trò chuyện mới");
    }

    if (chatId.isEmpty) return; // Vẫn kiểm tra để đảm bảo an toàn

    // Trong hàm callAI
    final userMessage = state.controller.text.trim();

// Kiểm tra xem đây có phải là tin nhắn đầu tiên của một chat mới không
    final isFirstMessageInNewChat = state.chatHistories
        .firstWhere((c) => c.id == chatId)
        .lastMessage.isEmpty; // Hoặc một logic khác để nhận biết

    if (isFirstMessageInNewChat) {
      // Lấy khoảng 5 từ đầu tiên làm tiêu đề mới
      final newTitle = userMessage.split(' ').take(5).join(' ');
      await renameChat(chatId, newTitle);
    }

    if (userMessage.isEmpty) return;

    state.controller.clear();

    final userMsg = Message(text: userMessage, isUser: true);

    // Chỉ cần lưu vào Firestore, listener sẽ tự động cập nhật UI
    state = state.copyWith(isLoading: true);
    await _chatService.saveMessage(chatId, userMsg);

    try {
      // ✅ Lấy lịch sử tin nhắn hiện tại từ state
      final chatHistory = List<Message>.from(state.messages);

      // ✅ Truyền cả câu hỏi và lịch sử vào hàm ask
      final aiText = await _aiModel.ask(userMessage, chatHistory);

      final aiMsg = Message(text: aiText, isUser: false);
      await _chatService.saveMessage(chatId, aiMsg);
    } catch (e) {
      final errorMsg = Message(text: "❌ Lỗi AI: $e", isUser: false);
      await _chatService.saveMessage(chatId, errorMsg);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ✅ HÀM MỚI: Đổi tên cuộc trò chuyện
  Future<void> renameChat(String chatId, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    await _chatService.renameChatRoom(chatId, newTitle.trim());
    // Listener từ `_loadInitialChatHistories` sẽ tự động cập nhật UI
  }

  // ✅ HÀM MỚI: Xóa cuộc trò chuyện
  Future<void> deleteChat(String chatId) async {
    await _chatService.deleteChatRoom(chatId);

    // Nếu cuộc trò chuyện bị xóa là cuộc trò chuyện đang hoạt động
    if (state.activeChatId == chatId) {
      // Chuyển sang cuộc trò chuyện khác nếu có, hoặc reset
      final remainingChats = state.chatHistories.where((c) => c.id != chatId).toList();
      if (remainingChats.isNotEmpty) {
        loadChat(remainingChats.first.id);
      } else {
        // Nếu không còn chat nào, reset trạng thái
        state = state.copyWith(
          messages: [],
          activeChatId: '',
        );
      }
    }
    // Listener từ `_loadInitialChatHistories` sẽ tự động cập nhật danh sách
  }
  // ✅ 5. Đừng quên hủy listener khi ViewModel bị dispose
  @override
  void dispose() {
    _cancelAllSubscriptions(); // ✅ Đảm bảo hủy khi ViewModel bị dispose
    state.controller.dispose();
    super.dispose();
  }
}

/// Provider Riverpod
final homeViewModelProvider =
StateNotifierProvider.autoDispose<HomeViewModel, HomeState>((ref) {
  final apiKey = dotenv.env['GOOGLE_API_KEY'];
  if (apiKey == null) {
    throw Exception("API_KEY không được tìm thấy trong file .env");
  }
  final aiModel = HistoryAI(apiKey: apiKey);
  // ✅ 4. Truyền ref vào ViewModel
  return HomeViewModel(aiModel: aiModel, ref: ref);
});