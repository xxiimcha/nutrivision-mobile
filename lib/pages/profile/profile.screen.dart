import 'package:flutter/material.dart';
import 'package:sjq/constant/constant.dart';
import 'package:sjq/navigator.dart';
import 'package:sjq/pages/profile/profile_buttons.dart';
import 'package:sjq/themes/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = ''; // Variable to hold the full name

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when screen is initialized
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        final response = await http.get(Uri.parse('$BASE_URL/users/$userId'));

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          setState(() {
            _fullName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load user data: ${response.reasonPhrase}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();


  Future<void> _logout() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      final response = await http.post(
        Uri.parse('$BASE_URL/users/$userId/logout'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'status': 'offline'}),
      );

      if (response.statusCode == 200) {
        await prefs.clear(); // Clear shared preferences
        await secureStorage.deleteAll(); // Clear secure storage
        AppNavigator().toLoginScreen(context); // Navigate to login screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log out: ${response.reasonPhrase}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error during logout: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Make the background color white
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 60),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    "assets/avatar/default-profile.png",
                    width: MediaQuery.of(context).size.width * 0.4, // Responsive image size
                    height: MediaQuery.of(context).size.width * 0.4, // Responsive image size
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _fullName.isNotEmpty ? _fullName : 'Loading...',
                  style: headingM.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: const [
                       BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset:   Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Profile", style: headingS),
                      const SizedBox(height: 10),
                      CustomButton(
                        title: "Personal Information",
                        onPressed: () {
                          AppNavigator().toEditProfileScreen(context);
                        },
                        icon: Icons.person,
                        color: Colors.blue[50]!,
                      ),
                 
                      const SizedBox(height: 25),
                      const Text("Security", style: paragraphM),
                      const SizedBox(height: 10),
                      CustomButton(
                        title: "Change Password",
                        onPressed: () {
                          AppNavigator().toChangePassword(context);
                        },
                        icon: Icons.lock,
                        color: Colors.red[50]!,
                      ),
                      const SizedBox(height: 20),
                      const AboutButton(),
                      const SizedBox(height: 25),
                      CustomButton(
                        title: "Logout",
                        onPressed: _logout,
                        icon: Icons.logout,
                        color: Colors.orange[50]!,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.icon,
    required this.color,
  });

  final String title;
  final Function() onPressed;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.black87),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: paragraphM.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
