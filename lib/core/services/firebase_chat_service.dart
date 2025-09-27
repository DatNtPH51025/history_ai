// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:history_ai/models/message.dart';
//
// class FirebaseChatService {
//   final _db = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;
//
//   /// Lưu message vào Firestore
//   Future<void> saveMessage(Message message) async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     await _db.collection("chats").add({
//       "text": message.text,
//       "isUser": message.isUser,
//       "timestamp": FieldValue.serverTimestamp(),
//       "userId": user.uid,
//     });
//   }
//
//   /// Stream đọc message theo user (Realtime update)
//   Stream<List<Message>> getMessages() {
//     final user = _auth.currentUser;
//     if (user == null) return const Stream.empty();
//
//     return _db
//         .collection("chats")
//         .where("userId", isEqualTo: user.uid)
//         .orderBy("timestamp", descending: false)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => Message(
//       text: doc["text"] ?? "",
//       isUser: doc["isUser"] ?? false,
//     ))
//         .toList());
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:history_ai/models/message.dart';

class FirebaseChatService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Lưu message vào Firestore (theo user -> subcollection `messages`)
  Future<void> saveMessage(Message message) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection("chats")
        .doc(user.uid)
        .collection("messages")
        .add({
      "text": message.text,
      "isUser": message.isUser,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  /// Lấy stream messages riêng của user
  Stream<List<Message>> getMessages() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection("chats")
        .doc(user.uid)
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
  Future<void> clearChat() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messages = await _db
        .collection("chats")
        .doc(user.uid)
        .collection("messages")
        .get();

    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
  }
}
