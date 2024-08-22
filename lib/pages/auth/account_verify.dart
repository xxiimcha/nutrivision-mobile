import 'package:flutter/material.dart';
import 'http_service.dart'; // Import the HTTP service

class VerifyEmailPage extends StatefulWidget {
  final String email;
  final HttpService httpService;

  const VerifyEmailPage({Key? key, required this.email, required this.httpService}) : super(key: key);

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final TextEditingController _otpController = TextEditingController();

  void _onConfirm() async {
    try {
      final otp = _otpController.text;
      final response = await widget.httpService.verifyOtp(widget.email, otp);

      print('OTP verification response: $response');

      if (response['success']) {
        // Handle successful verification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email verified successfully!')),
        );
        // Navigate to the next page or main app
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify OTP: ${response['message']}')),
        );
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify OTP: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Verify your email",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "A verification email has been sent to your email address. Please check your email to verify your account.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Please enter the 4 digit code sent to ${widget.email}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                try {
                  await widget.httpService.sendOtp(widget.email);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('OTP resent to ${widget.email}')),
                  );
                } catch (e) {
                  print('Error resending OTP: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to resend OTP: $e')),
                  );
                }
              },
              child: Text(
                "RESEND CODE?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _onConfirm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "CONFIRM",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
