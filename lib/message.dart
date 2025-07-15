class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.status = MessageStatus.sent,
  }) : timestamp = timestamp ?? DateTime.now();

  Message copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return Message(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  failed,
  streaming,
}
