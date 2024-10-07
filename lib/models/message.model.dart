class Message {
  final String sender;
  final String receiver;
  final String text;
  final DateTime timestamp;

  Message({
    required this.sender,
    required this.receiver,
    required this.text,
    required this.timestamp,
  });

  // Factory method to create a Message from a JSON map
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      receiver: json['receiver'],
      text: json['text'],
      // Handle string or DateTime objects in the 'timestamp' field
      timestamp: json['timestamp'] is String
          ? DateTime.parse(json['timestamp'])
          : json['timestamp'] as DateTime,
    );
  }

  // Convert Message instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'receiver': receiver,
      'text': text,
      'timestamp': timestamp.toIso8601String(), // Ensure to use a DateTime object here
    };
  }
}
