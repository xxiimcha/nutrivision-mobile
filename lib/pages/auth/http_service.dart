import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sjq/constant/constant.dart';
import 'package:sjq/models/event.model.dart'; // Import your Event model
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create an instance of FlutterSecureStorage
const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
class HttpService {
  final String baseUrl = BASE_URL;

  Future<Map<String, dynamic>> signUp(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      debugPrint('Sign-up response status: ${response.statusCode}');
      debugPrint('Sign-up response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to Signup: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error during sign-up: $e');
      rethrow;
    }
  }

  Future<void> sendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      debugPrint('Send OTP response status: ${response.statusCode}');
      debugPrint('Send OTP response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'otp': otp,
        }),
      );

      debugPrint('Verify OTP response status: ${response.statusCode}');
      debugPrint('Verify OTP response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify OTP: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      rethrow;
    }
  }

 Future<Map<String, dynamic>> login(String identifier, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'identifier': identifier,  // Use 'identifier' instead of 'email' if your backend expects it
        'password': password,
      }),
    );

    debugPrint('Login response status: ${response.statusCode}');
    debugPrint('Login response body: ${response.body}');

    if (response.statusCode == 200) {
      // Decode the response to retrieve user data
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      // Assuming the userId is returned in the response, adjust the key as needed
      final String userId = responseData['userId']; // Adjust this line based on your API response

      // Save the userId in secure storage
      await _secureStorage.write(key: 'userId', value: userId);
      debugPrint('User ID saved to secure storage: $userId');

      return responseData;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error during login: $e');
    rethrow;
  }
}

  // Fetch events from the server
  Future<List<Event>> fetchEvents({String? date}) async {
    try {
      final uri = Uri.parse('$baseUrl/events').replace(queryParameters: {
        if (date != null) 'date': date,
      });

      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      debugPrint('Fetch events response status: ${response.statusCode}');
      debugPrint('Fetch events response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> eventJson = jsonDecode(response.body);
        return eventJson.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching events: $e');
      rethrow;
    }
  }
}
