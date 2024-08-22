import 'package:flutter/material.dart';
import 'package:sjq/navigator.dart';
import 'package:sjq/pages/profile/profile_buttons.dart';
import 'package:sjq/themes/themes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                    width: MediaQuery.of(context).size.width * 0.4, // Make the image size responsive
                    height: MediaQuery.of(context).size.width * 0.4, // Make the image size responsive
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Yoon Hannie', style: headingM),
                const SizedBox(height: 15),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(30),
                      topEnd: Radius.circular(30),
                    ),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Profile", style: headingS),
                        CustomButton(
                          title: "Personal Information",
                          onPressed: () {
                            AppNavigator().toEditProfileScreen(context);
                          },
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 5),
                        CustomButton(
                          title: "Nutritional Status",
                          onPressed: () {
                            AppNavigator().toUpdateNutritionStats(context);
                          },
                          icon: Icons.assignment_turned_in,
                        ),
                        const SizedBox(height: 15),
                        const Text("Security", style: paragraphM),
                        CustomButton(
                          title: "ChangePassword",
                          onPressed: () {
                            AppNavigator().toChangePassword(context);
                          },
                          icon: Icons.lock_person,
                        ),
                        const SizedBox(height: 10),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: double.infinity,
                            ),
                            AboutButton(),
                            SizedBox(height: 25),
                            LogoutButton()
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
  });

  final String title;
  final Function() onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
            child: Row(
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
          ),
          const Icon(Icons.chevron_right, color: Colors.black87),
        ],
      ),
    );
  }
}