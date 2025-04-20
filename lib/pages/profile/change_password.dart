import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sjq/constant/constant.dart';
import 'package:sjq/navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

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

  bool hasUpperLowerCase = false;
  bool hasNumberOrSymbol = false;
  bool isLongEnough = false;
  bool noSpacesOrPipes = true;
  bool passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    setState(() {
      final password = newPasswordController.text;
      hasUpperLowerCase = password.contains(RegExp(r'^(?=.*[a-z])(?=.*[A-Z])'));
      hasNumberOrSymbol = password.contains(RegExp(r'(?=.*\d)|(?=.*[@$!%*#?&])'));
      isLongEnough = password.length >= 8;
      noSpacesOrPipes = !password.contains(' ') && !password.contains('|');
      passwordsMatch = password == confirmPasswordController.text;
    });
  }

  bool isValidPassword(String password) {
    return hasUpperLowerCase &&
        hasNumberOrSymbol &&
        isLongEnough &&
        noSpacesOrPipes;
  }

  void saveChanges(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Please log in again.')),
      );
      return;
    }

    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (!passwordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password and confirmation do not match.')),
      );
      return;
    }

    if (!isValidPassword(newPasswordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid password criteria.')),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$BASE_URL/users/$userId/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currentPassword': currentPasswordController.text,
          'newPassword': newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')),
        );
        Timer(const Duration(seconds: 1), () {
          AppNavigator().pop(context);
        });
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect current password.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to change password. Please try again later.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildPasswordChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChecklistItem('Include lower and upper characters', hasUpperLowerCase),
        _buildChecklistItem('Include at least 1 number or symbol', hasNumberOrSymbol),
        _buildChecklistItem('Be at least 8 characters long', isLongEnough),
        _buildChecklistItem('Cannot contain spaces or "|" symbol', noSpacesOrPipes),
        _buildChecklistItem('Passwords match', passwordsMatch),
      ],
    );
  }

  Widget _buildChecklistItem(String text, bool conditionMet) {
    return Row(
      children: [
        Icon(
          conditionMet ? Icons.check : Icons.close,
          color: conditionMet ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: conditionMet ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password", style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: const Color(0xFF1A276C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Change your password',
                style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFFf0f4f8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Current Password", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildPasswordField(currentPasswordController, showCurrentPassword, (value) {
                        setState(() {
                          showCurrentPassword = !showCurrentPassword;
                        });
                      }),
                      const SizedBox(height: 15),
                      const Text("New Password", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildPasswordField(newPasswordController, showNewPassword, (value) {
                        setState(() {
                          showNewPassword = !showNewPassword;
                        });
                      }),
                      const SizedBox(height: 15),
                      const Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildPasswordField(confirmPasswordController, showConfirmPassword, (value) {
                        setState(() {
                          showConfirmPassword = !showConfirmPassword;
                        });
                      }),
                      const SizedBox(height: 20),
                      _buildPasswordChecklist(),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _canSave() ? () {
                            saveChanges(context);
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text("SAVE", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
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

  Widget _buildPasswordField(TextEditingController controller, bool obscureText, Function onPressed) {
    return TextField(
      controller: controller,
      obscureText: !obscureText,
      decoration: InputDecoration(
        hintText: 'Enter password',
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () => onPressed(controller.text),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              );
            }

            bool _canSave() {
              return hasUpperLowerCase &&
                  hasNumberOrSymbol &&
                  isLongEnough &&
                  noSpacesOrPipes &&
                  passwordsMatch;
            }
          }