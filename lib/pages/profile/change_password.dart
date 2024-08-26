import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sjq/navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  void saveChanges(BuildContext context) async {
    // Get the userId from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found. Please log in again.'),
        ),
      );
      return;
    }

    // Validate input
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password and confirmation do not match.'),
        ),
      );
      return;
    }

    try {
      // Log request details
      print('Attempting to change password for user ID: $userId');
      print('Current Password: ${currentPasswordController.text}');
      print('New Password: ${newPasswordController.text}');
      
      // Prepare API request
      final response = await http.put(
        Uri.parse('http://localhost:5000/api/users/$userId/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currentPassword': currentPasswordController.text,
          'newPassword': newPasswordController.text,
        }),
      );

      // Log response details
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
          ),
        );

        Timer(const Duration(seconds: 1), () {
          AppNavigator().pop(context);
        });
      } else if (response.statusCode == 400) {
        // Assuming the backend returns 400 for incorrect current password
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect current password.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to change password. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      // Log any errors
      print('Error during password change: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              const Row(
                children: [
                  Text(
                    'Change your password',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF96B0D7)),
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Current Password"),
                      TextField(
                        controller: currentPasswordController,
                        obscureText: !showCurrentPassword,
                        decoration: InputDecoration(
                          hintText: 'Input current password',
                          suffixIcon: IconButton(
                            icon: Icon(showCurrentPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                showCurrentPassword = !showCurrentPassword;
                              });
                            },
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 15),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("New Password"),
                      TextField(
                        controller: newPasswordController,
                        obscureText: !showNewPassword,
                        decoration: InputDecoration(
                          hintText: 'Input new password',
                          suffixIcon: IconButton(
                            icon: Icon(showNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                showNewPassword = !showNewPassword;
                              });
                            },
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 15),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("Confirm Password"),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !showConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Confirm new password',
                          suffixIcon: IconButton(
                            icon: Icon(showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                showConfirmPassword = !showConfirmPassword;
                              });
                            },
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 15),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: double.infinity),
                          ElevatedButton(
                            onPressed: () {
                              saveChanges(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Padding(
                              padding: EdgeInsetsDirectional.symmetric(
                                  horizontal: 20),
                              child: Text(
                                "SAVE",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
