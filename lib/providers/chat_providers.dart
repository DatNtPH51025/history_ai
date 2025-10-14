import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/core/services/firebase_chat_service.dart';
import 'package:history_ai/models/chat_history.dart';
import 'package:history_ai/providers/auth_provider.dart'; // Import để lấy user

// Provider để lấy service, có thể tái sử dụng
final chatServiceProvider = Provider((ref) => FirebaseChatService());

// Provider cho danh sách lịch sử chat
final chatHistoriesProvider = StreamProvider.autoDispose<List<ChatHistory>>((ref) {
  // Lắng nghe trạng thái đăng nhập
  final user = ref.watch(authProvider);

  // Nếu người dùng đã đăng xuất, trả về một stream rỗng
  if (user == null) {
    return Stream.value([]);
  }

  // Nếu đã đăng nhập, lấy dữ liệu
  final chatService = ref.read(chatServiceProvider);
  return chatService.getChatHistories();
});
