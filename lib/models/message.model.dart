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
      sender: json['sender'] ?? '', // Fallback to an empty string if null
      receiver: json['receiver'] ?? '', // Fallback to an empty string if null
      text: json['text'] ?? '', // Fallback to an empty string if null
      // Safely parse the timestamp or use a fallback
      timestamp: json['timestamp'] is String
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Convert Message instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'receiver': receiver,
      'text': text,
      'timestamp': timestamp.toIso8601String(), // Convert DateTime to ISO string format
    };
  }
}
