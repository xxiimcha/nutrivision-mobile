import 'package:flutter/material.dart';
import 'package:sjq/pages/auth/_buttons.dart';
import 'package:sjq/themes/themes.dart';
import '../home/home.screen.dart'; // Import the HomeScreen

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> _formKey;
  final TextEditingController usernameOrEmailController;
  final TextEditingController passwordController;

  LoginForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.usernameOrEmailController,
    required this.passwordController,
  }) : _formKey = formKey;

  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Directly navigate to the HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // Debugging: Log validation failure
      print('Form validation failed');
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
                return 'Username or Email must be at least 5 characters';
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
              } else if (value.length < 8) {
                return 'Password must be at least 8 characters';
              } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$').hasMatch(value)) {
                return 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character';
              }
              return null;
            },
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [ForgotPasswordButton()],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _login(context),
            child: Text("Login"),
          ),
        ],
      ),
    );
  }
}

// Input Text Class
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

// Password Input Text Class with Toggle Visibility
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
