import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sjq/models/client.model.dart';

class UserService {
  final String baseUrl = 'http://localhost:5000/api';

  Future<void> createEntry(Client client) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/patients/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(client.toJson()),
      );

      if (response.statusCode == 201) {
        print('Patient record created successfully');
      } else {
        print('Failed to create patient record with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to create patient record: ${response.body}');
      }
    } catch (e) {
      print('Error creating patient record: $e');
      rethrow;
    }
  }
}
