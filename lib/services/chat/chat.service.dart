import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sjq/models/contact.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  Future<List<Contact>> getContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loggedInUserId = prefs.getString('userId'); // Get logged-in user ID

    if (loggedInUserId == null) {
      throw Exception('No logged-in user');
    }

    // Replace with your actual backend API URL
    final response = await http.get(Uri.parse('http://localhost:5000/api/messages/conversations/$loggedInUserId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      List<Contact> contacts = jsonList.map((json) => Contact.fromJson(json)).toList();
      return contacts;
    } else {
      throw Exception('Failed to load contacts');
    }
  }
}
