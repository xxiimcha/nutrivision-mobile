import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sjq/constant/constant.dart';
import 'package:sjq/models/message.model.dart';

class ChatService {
  Future<List<Message>> getMessagesForUser(String userId) async {
    try {
      // Fetch messages for the logged-in user
      final response = await http.get(Uri.parse('$BASE_URL/messages/$userId'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<Message> messages = jsonResponse.map((text) => Message.fromJson(text)).toList();
        
        // Fetch sender names for each message
        for (var message in messages) {
          message.senderName = await getSenderName(message.sender);
        }

        return messages;
            } else {
        throw Exception('Failed to load messages with status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      rethrow;
    }
  }

  // New method to fetch the sender's name from the backend
  Future<String> getSenderName(String userId) async {
    try {
      final response = await http.get(Uri.parse('$BASE_URL/messages/admin/$userId'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['name'];
      } else {
        debugPrint('Failed to fetch sender name for $userId');
        return 'Unknown'; // Return 'Unknown' if the user is not found
      }
    } catch (e) {
      debugPrint('Error fetching sender name for $userId: $e');
      return 'Unknown';
    }
  }

  // Method to fetch messages between two users (sender and receiver)
  Future<List<Message>> getMessagesBetweenUsers(String loggedInUserId, String otherUserId) async {
    try {
      final url = Uri.parse('$BASE_URL/messages/conversation');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'loggedInUserId': loggedInUserId,
          'otherUserId': otherUserId,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((text) => Message.fromJson(text)).toList();
            } else {
        throw Exception('Failed to load conversation with status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading conversation messages: $e');
      rethrow;
    }
  }

  // New method to send a message
  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    try {
      final url = Uri.parse('$BASE_URL/messages/send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'sender': senderId,
          'receiver': receiverId,
          'text': text,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }
}
