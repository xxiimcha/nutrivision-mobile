import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sjq/constant/constant.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home.screen.dart';
import 'package:sjq/pages/auth/forgot_password_page.dart';
import 'package:sjq/themes/themes.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> _formKey;
  final TextEditingController usernameOrEmailController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.usernameOrEmailController,
    required this.passwordController,
  }) : _formKey = formKey;

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> loginDetails = {
        'identifier': usernameOrEmailController.text,
        'password': passwordController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('$BASE_URL/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(loginDetails),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          // ✅ Store userId in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final userId = responseData['userId'];
          await prefs.setString('userId', userId);

          // ✅ Send FCM token to backend
          await _sendFcmTokenIfNeeded(userId);

          // ✅ Navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          final errorResponse = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorResponse['msg'] ?? 'Invalid credentials')),
          );
        }
      } catch (error) {
        debugPrint('Login error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } else {
      debugPrint('Form validation failed');
    }
  }

Future<void> _sendFcmTokenIfNeeded(String userId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? savedToken = prefs.getString('fcmToken');

    String? currentToken = await FirebaseMessaging.instance.getToken();
    debugPrint('📲 Current FCM Token: $currentToken');

    if (currentToken == null) {
      debugPrint('❌ No FCM token available.');
      return;
    }

    if (savedToken == currentToken) {
      debugPrint('ℹ️ Token already saved. Skipping.');
    } else {
      final response = await http.post(
        Uri.parse('$BASE_URL/tokens/save-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'token': currentToken}),
      );

      if (response.statusCode == 200) {
        await prefs.setString('fcmToken', currentToken);
        debugPrint('✅ FCM token saved successfully.');
      } else {
        debugPrint('⚠️ Server rejected FCM token: ${response.body}');
      }
    }

    // Ensure token is updated in the future too
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (newToken != savedToken) {
        debugPrint('🔁 Token refreshed: $newToken');
        final res = await http.post(
          Uri.parse('$BASE_URL/tokens/save-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'userId': userId, 'token': newToken}),
        );
        if (res.statusCode == 200) {
          await prefs.setString('fcmToken', newToken);
          debugPrint('✅ Refreshed token updated on server.');
        }
      }
    });
  } catch (e) {
    debugPrint('❌ Token sending failed: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InputText(
            controller: usernameOrEmailController,
            label: "Username or Email",
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter username or email';
              } else if (value.length < 5) {
                return 'Must be at least 5 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          PasswordInputText(
            controller: passwordController,
            label: "Password",
            icon: Icons.lock,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Text Input Field
class InputText extends StatelessWidget {
  const InputText({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: paragraphM.copyWith(color: Colors.black),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        labelText: label,
        labelStyle: paragraphM,
        prefixIcon: Icon(icon),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      validator: validator,
    );
  }
}

// Password Input Field
class PasswordInputText extends StatefulWidget {
  const PasswordInputText({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;

  @override
  _PasswordInputTextState createState() => _PasswordInputTextState();
}

class _PasswordInputTextState extends State<PasswordInputText> {
  bool _isHidden = true;

  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isHidden,
      style: paragraphM.copyWith(color: Colors.black),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        labelText: widget.label,
        labelStyle: paragraphM,
        prefixIcon: Icon(widget.icon),
        suffixIcon: IconButton(
          icon: Icon(
            _isHidden ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: _toggleVisibility,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      validator: widget.validator,
    );
  }
}
