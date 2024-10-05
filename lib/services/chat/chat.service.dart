import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sjq/models/message.model.dart';

class ChatService {
  // Fetch messages from the backend
  Future<List<Message>> getMessages(String userId) async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/messages/$userId')); // Replace with actual API

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((text) => Message.fromJson(text)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }
}
