import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sjq/constant/constant.dart';
import 'reset_password_page.dart';

class OtpVerificationPage extends StatelessWidget {
  final String email;
  const OtpVerificationPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    // Separate controllers for each OTP box
    final otpController1 = TextEditingController();
    final otpController2 = TextEditingController();
    final otpController3 = TextEditingController();
    final otpController4 = TextEditingController();

    Future<void> verifyOtp(BuildContext context) async {
      if (formKey.currentState!.validate()) {
        final otp = otpController1.text +
            otpController2.text +
            otpController3.text +
            otpController4.text;

        try {
          // Make HTTP request to verify OTP
          final response = await http.post(
            Uri.parse('$BASE_URL/auth/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'otp': otp}),
          );

          if (response.statusCode == 200) {
            // Navigate to reset password page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(email: email),
              ),
            );
          } else {
            // Handle server errors
            final errorResponse = json.decode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorResponse['message'] ?? 'Invalid OTP')),
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
      backgroundColor: const Color(0xFFF5F7FA), // Light background color for a clean look
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              "Email Verification",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "A verification code has been sent to your email address. Please enter the code below to verify.",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF616161),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Enter 4-digit code sent to:",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Form(
              key: formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _otpBox(context, otpController1),
                  _otpBox(context, otpController2),
                  _otpBox(context, otpController3),
                  _otpBox(context, otpController4),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: GestureDetector(
                onTap: () {
                  // Handle resend OTP logic
                },
                child: const Text(
                  "Resend Code?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A73E8),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => verifyOtp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Verify",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OTP input box widget with modern styling
  Widget _otpBox(BuildContext context, TextEditingController controller) {
    return SizedBox(
      width: 60,
      height: 60,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(10),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1.5, color: Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Color(0xFF1A73E8)),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1.5, color: Colors.redAccent),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return ' ';
          }
          return null;
        },
      ),
    );
  }
}
