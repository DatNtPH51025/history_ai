import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/chat_history.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final AuthRepository _authRepository;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Message>>? _messageSubscription;
  StreamSubscription<List<ChatHistory>>? _chatHistorySubscription;

  ChatCubit({
    required ChatRepository chatRepository,
    required AuthRepository authRepository,
  })  : _chatRepository = chatRepository,
        _authRepository = authRepository,
        super(ChatState.initial()) {
    _init();
  }

  void _init() {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user == null) {
        _cancelAllSubscriptions();
        emit(ChatState.initial());
      } else {
        _loadInitialChatHistories();
      }
    });
  }

  void _cancelAllSubscriptions() {
    _messageSubscription?.cancel();
    _chatHistorySubscription?.cancel();
    _messageSubscription = null;
    _chatHistorySubscription = null;
  }

  void _loadInitialChatHistories() {
    _chatHistorySubscription?.cancel();
    _chatHistorySubscription = _chatRepository.getChatHistories().listen((histories) {
      emit(state.copyWith(chatHistories: histories));
      if (state.activeChatId.isEmpty && histories.isNotEmpty) {
        loadChat(histories.first.id);
      }
    });
  }

  Future<String> createNewChat(String title) async {
    final user = _authRepository.currentUser;
    if (user == null) throw Exception("Người dùng chưa đăng nhập!");

    final newChatId = DateTime.now().millisecondsSinceEpoch.toString();
    await _chatRepository.createChatRoom(user.uid, newChatId, title);

    loadChat(newChatId);
    return newChatId;
  }

  void loadChat(String chatId) {
    _messageSubscription?.cancel();

    emit(state.copyWith(
      activeChatId: chatId,
      messages: [],
    ));

    _messageSubscription = _chatRepository.getMessages(chatId).listen((messages) {
      if (state.activeChatId == chatId) {
        emit(state.copyWith(messages: messages));
        _updateChatHistoryLocally(chatId, messages);
      }
    });
  }

  void _updateChatHistoryLocally(String chatId, List<Message> messages) {
    final updatedHistories = state.chatHistories.map((chat) {
      if (chat.id == chatId) {
        return chat.copyWith(
          lastMessage: messages.isNotEmpty ? messages.last.text : '',
        );
      }
      return chat;
    }).toList();

    emit(state.copyWith(chatHistories: updatedHistories));
  }

  Future<void> renameChat(String chatId, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    await _chatRepository.renameChatRoom(chatId, newTitle.trim());
  }

  Future<void> deleteChat(String chatId) async {
    await _chatRepository.deleteChatRoom(chatId);

    if (state.activeChatId == chatId) {
      final remainingChats = state.chatHistories.where((c) => c.id != chatId).toList();
      if (remainingChats.isNotEmpty) {
        loadChat(remainingChats.first.id);
      } else {
        emit(state.copyWith(
          messages: [],
          activeChatId: '',
        ));
      }
    }
  }

  Future<void> sendChatMessage(String messageText) async {
    final text = messageText.trim();
    if (text.isEmpty) return;

    if (state.activeChatId.isEmpty) {
      await createNewChat("Cuộc trò chuyện mới");
      await Future.delayed(const Duration(milliseconds: 500));
    }

    String chatId = state.activeChatId;
    if (chatId.isEmpty) return;

    final chatIndex = state.chatHistories.indexWhere((c) => c.id == chatId);
    final isFirstMessageInNewChat = chatIndex != -1 && state.chatHistories[chatIndex].lastMessage.isEmpty;

    if (isFirstMessageInNewChat) {
      final newTitle = text.split(' ').take(5).join(' ');
      await renameChat(chatId, newTitle);
    }

    final userMsg = Message(text: text, isUser: true);
    emit(state.copyWith(isLoading: true));
    await _chatRepository.saveMessage(chatId, userMsg);

    try {
      final chatHistory = List<Message>.from(state.messages);
      final aiText = await _chatRepository.askAI(text, chatHistory);
      final aiMsg = Message(text: aiText, isUser: false);
      await _chatRepository.saveMessage(chatId, aiMsg);
    } catch (e) {
      final errorMsg = Message(text: "❌ Lỗi AI: $e", isUser: false);
      await _chatRepository.saveMessage(chatId, errorMsg);
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _cancelAllSubscriptions();
    return super.close();
  }
}
