import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sjq/constant/constant.dart';
import 'package:sjq/models/client.model.dart';
import 'package:sjq/models/weekly_improvement.model.dart';

class UserService {
  final String baseUrl = BASE_URL;

  // Method to create a patient record
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
        debugPrint('Patient record created successfully');
      } else {
        debugPrint('Failed to create patient record with status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to create patient record: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating patient record: $e');
      rethrow;
    }
  }

  // Method to fetch patients by user ID
  Future<List<Client>> getPatientsByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patients/$userId'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        // Access the 'patients' key
        List<dynamic> patientsData = data['patients'];

        return patientsData.map((json) => Client.fromJson(json)).toList();
      } else {
        debugPrint('Failed to fetch patients with status code: ${response.statusCode}');
        throw Exception('Failed to fetch patients');
      }
    } catch (e) {
      debugPrint('Error fetching patients: $e');
      rethrow;
    }
  }

  // Method to fetch weekly improvements by patient ID and map it to WeeklyImprovement model
  Future<List<WeeklyImprovement>> getWeeklyImprovementsByPatientId(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patients/weeklyimprovements/$patientId'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        // Check if the improvements key exists and map it to WeeklyImprovement model
        if (data.containsKey('improvements')) {
          List<dynamic> improvementsData = data['improvements'];
          return improvementsData
              .map((json) => WeeklyImprovement.fromJson(json))
              .toList();
        } else {
          throw Exception('No improvements found for this patient');
        }
      } else {
        debugPrint('Failed to fetch weekly improvements with status code: ${response.statusCode}');
        throw Exception('Failed to fetch weekly improvements');
      }
    } catch (e) {
      debugPrint('Error fetching weekly improvements: $e');
      rethrow;
    }
  }
}
