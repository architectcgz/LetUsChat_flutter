class MessageSendResult{
  int messageId;
  DateTime sendTime;

//<editor-fold desc="Data Methods">
  MessageSendResult({
    required this.messageId,
    required this.sendTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageSendResult &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId &&
          sendTime == other.sendTime);

  @override
  int get hashCode => messageId.hashCode ^ sendTime.hashCode;

  @override
  String toString() {
    return 'MessageSendResult{ messageId: $messageId, sendTime: $sendTime,}';
  }

  MessageSendResult copyWith({
    int? messageId,
    DateTime? sendTime,
  }) {
    return MessageSendResult(
      messageId: messageId ?? this.messageId,
      sendTime: sendTime ?? this.sendTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'sendTime': sendTime,
    };
  }

  factory MessageSendResult.fromMap(Map<String, dynamic> map) {
    return MessageSendResult(
      messageId: map['messageId'] as int,
      sendTime: DateTime.parse(map['sendTime']),
    );
  }

//</editor-fold>
}