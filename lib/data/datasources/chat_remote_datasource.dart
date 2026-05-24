import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/chat_history.dart';
import '../../domain/entities/message.dart';

import 'package:flutter/foundation.dart';

class ChatRemoteDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GenerativeModel _generativeModel;

  // Lời nhắc hệ thống chuyên về lịch sử
  static final Content systemPrompt = Content.text(
      "Bạn là một trợ lý AI chuyên về lịch sử Việt Nam và thế giới. "
      "Hãy giải thích các sự kiện một cách ngắn gọn, rõ ràng và dễ hiểu, như thể bạn đang kể chuyện cho học sinh hoặc sinh viên. "
      "Hãy bao gồm các mốc thời gian, nhân vật quan trọng, hoặc các chi tiết thú vị để làm cho câu chuyện trở nên sinh động. "
      "Luôn luôn trả lời bằng tiếng Việt.");

  ChatRemoteDataSource({required String apiKey})
      : _generativeModel = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
        );

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

  Future<void> createChatRoom(String userId, String chatId, String title) async {
    await _db
        .collection("chats")
        .doc(userId)
        .collection("chatRooms")
        .doc(chatId)
        .set({
      "title": title,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ChatHistory>> getChatHistories() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection("chats")
        .doc(user.uid)
        .collection("chatRooms")
        .orderBy("createdAt", descending: true)
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

  Future<String> askAI(String question, List<Message> history) async {
    try {
      final List<Content> conversation = [
        systemPrompt,
      ];

      for (final message in history) {
        if (message.isUser) {
          conversation.add(Content.text(message.text));
        } else {
          conversation.add(Content.model([TextPart(message.text)]));
        }
      }

      conversation.add(Content.text(question));

      final response = await _generativeModel.generateContent(conversation);
      final answer = response.text;

      if (answer == null || answer.isEmpty) {
        return "🤖 Rất tiếc, tôi không thể tìm thấy câu trả lời. Vui lòng thử lại.";
      }
      return answer;
    } catch (e) {
      debugPrint("Lỗi khi gọi API của Google AI: $e");
      return "❌ Đã xảy ra lỗi khi kết nối với AI. Vui lòng kiểm tra lại kết nối hoặc API key.";
    }
  }
}
