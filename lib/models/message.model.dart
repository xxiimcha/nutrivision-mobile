class Message {
  final String sender;
  final String receiver;
  final String text;
  final String timestamp;

  Message({required this.sender, required this.receiver, required this.text, required this.timestamp});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      receiver: json['receiver'],
      text: json['text'],
      timestamp: json['timestamp'],
    );
  }
}
