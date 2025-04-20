import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sjq/constant/constant.dart';
import 'dart:convert';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();

    Future<void> sendPasswordReset(BuildContext context) async {
      if (formKey.currentState!.validate()) {
        try {
          // Make HTTP request to send OTP
          final response = await http.post(
            Uri.parse('$BASE_URL/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': emailController.text}),
          );

          if (response.statusCode == 200) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationPage(email: emailController.text),
              ),
            );
          } else {
            // Handle server errors
            final errorResponse = json.decode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorResponse['message'] ?? 'Error sending reset link')),
            );
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('An error occurred. Please try again.')),
          );
        }
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background image with blur effect
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/cembo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black.withOpacity(0.6), // Dark transparent overlay for better contrast
            ),
          ),
          // Positioned back button at the top left
          Positioned(
            top: 40, // Adjust this value based on your needs
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  // Logo Section
                  SizedBox(
                    height: 200, 
                    width: 200,
                    child: Image.asset('images/logo2.png'), // Adjusted logo size for better positioning
                  ),
                  const SizedBox(height: 40), // Add spacing after logo
                  
                  // Form Section
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        // Email input field with rounded border
                        TextFormField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white), // White input text color
                          decoration: InputDecoration(
                            labelText: 'Enter your email',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1), // Semi-transparent fill
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.redAccent),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // Send Reset Link Button
                        ElevatedButton(
                          onPressed: () => sendPasswordReset(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            shadowColor: Colors.blueAccent.withOpacity(0.5), // Modern shadow effect
                            elevation: 5,
                          ),
                          child: const Text(
                            'Send Reset Link',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
