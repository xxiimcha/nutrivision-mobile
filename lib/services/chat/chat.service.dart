import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sjq/models/message.model.dart';

class ChatService {
  Future<List<Message>> getMessages(String userId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/messages/$userId'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((text) => Message.fromJson(text)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error loading messages: $e');
      rethrow; // Pass the error up so it can be handled appropriately in the UI
    }
  }
}

