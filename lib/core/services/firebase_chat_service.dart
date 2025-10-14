import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:history_ai/models/chat_history.dart';
import 'package:history_ai/models/message.dart';

class FirebaseChatService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Lưu message vào Firestore (theo user -> subcollection `messages`)
  Future<void> saveMessage(String chatId, Message message) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection("chats")
        .doc(user.uid)
        .collection("chatRooms")
        .doc(chatId)
        .collection("messages")
        .add({
      "text": message.text,
      "isUser": message.isUser,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }


  /// Lấy stream messages riêng của user
  Stream<List<Message>> getMessages(String chatId) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection("chats")
        .doc(user.uid)
        .collection("chatRooms")
        .doc(chatId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Message(
      text: doc["text"] ?? "",
      isUser: doc["isUser"] ?? false,
    ))
        .toList());
  }


  /// Xoá toàn bộ lịch sử chat của user
  Future<void> clearChat(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messages = await _db
        .collection("chats")
        .doc(user.uid)
        .collection("chatRooms")
        .doc(chatId)
        .collection("messages")
        .get();

    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
  }
  /// Tạo chat room mới trên Firestore
  Future<void> createChatRoom(String userId, String chatId, String title) async {
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(userId)
        .collection("chatRooms")
        .doc(chatId)
        .set({
      "title": title,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Lấy stream của danh sách các phòng chat (lịch sử chat)
  Stream<List<ChatHistory>> getChatHistories() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]); // Trả về stream rỗng nếu chưa đăng nhập

    return _db
        .collection("chats")
        .doc(user.uid)
        .collection("chatRooms")
        .orderBy("createdAt", descending: true) // Sắp xếp để chat mới nhất lên đầu
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatHistory(
          id: doc.id,
          title: data['title'] ?? 'Không có tiêu đề',
          lastMessage: '', // Sẽ được cập nhật sau
          messages: [],
        );
      }).toList();
    });
  }

  // ✅ HÀM MỚI: Đổi tên một phòng chat
  Future<void> renameChatRoom(String chatId, String newTitle) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection("chats")
        .doc(user.uid)
        .collection("chatRooms")
        .doc(chatId)
        .update({"title": newTitle});
  }

  // ✅ HÀM MỚI: Xóa một phòng chat (bao gồm cả các tin nhắn bên trong)
  Future<void> deleteChatRoom(String chatId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final chatRoomRef =
    _db.collection("chats").doc(user.uid).collection("chatRooms").doc(chatId);

    // Xóa tất cả các document tin nhắn trong sub-collection
    final messages = await chatRoomRef.collection("messages").get();
    for (var doc in messages.docs) {
      await doc.reference.delete();
    }

    // Xóa document của phòng chat
    await chatRoomRef.delete();
  }
}

