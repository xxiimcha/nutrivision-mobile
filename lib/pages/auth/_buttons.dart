import 'package:flutter/material.dart';
import 'package:sjq/navigator.dart';
import 'package:sjq/themes/themes.dart';
import 'http_service.dart';

class SignupButton extends StatelessWidget {
  SignupButton({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final HttpService httpService = HttpService(); // Initialize the HTTP service

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            final response = await httpService.signUp(
              usernameController.text,
              emailController.text,
              passwordController.text,
            );
            print('Response: $response'); // Log the response
            if (response['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Sign up successful!'),
              ));
              Navigator.pop(context); // Navigate back to login page
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(response['message'] ?? 'Failed to sign up'),
              ));
            }
          } catch (e) {
            print('Error: $e'); // Log the error
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Failed to sign up'),
            ));
          }
        }
      },
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(colorBlue),
      ),
      child: Text(
        'SIGN UP',
        style: paragraphM.copyWith(color: Colors.white),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  LoginButton({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.usernameOrEmailController,
    required this.passwordController,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final TextEditingController usernameOrEmailController;
  final TextEditingController passwordController;
  final HttpService httpService = HttpService(); // Initialize the HTTP service

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            final response = await httpService.login(
              usernameOrEmailController.text,
              passwordController.text,
            );
            if (response['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Login successful!'),
              ));
              AppNavigator().toHome(context); // Navigate to home page
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Invalid credentials'),
              ));
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Failed to log in'),
            ));
          }
        }
      },
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color(0xFF0000FF)), // Replace with your theme color
      ),
      child: Text(
        'LOGIN',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Implement your logic here for the "Forgot Password" functionality
        // For example, you can navigate to a reset password screen
      },
      child: Text(
        "Forgot Password",
        style: paragraphS.copyWith(color: Colors.black),
      ),
    );
  }
}
