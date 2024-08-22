// ignore_for_file: use_key_in_widget_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sjq/navigator.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  void saveChanges(BuildContext context) {
    // Add logic to save changes here

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully!'),
      ),
    );

    Timer(const Duration(seconds: 1), () {
      // Navigate to Welcome page
      AppNavigator().pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutritional Status"),
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
                          fillColor:
                              Colors.white, // Set background color to white
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 15), // Adjust the vertical padding
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                  20), // Set circular border radius
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
                          fillColor:
                              Colors.white, // Set background color to white
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 15), // Adjust the vertical padding
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                  20), // Set circular border radius
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
                          fillColor:
                              Colors.white, // Set background color to white
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 15), // Adjust the vertical padding
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                  20), // Set circular border radius
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
