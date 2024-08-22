import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sjq/navigator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fullNameController.text = 'Yoon Hannie';
    ageController.text = '5';
    emailController.text = "example@gmail.com";
    contactController.text = "09876543210";
  }

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> _openFilePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

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
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: _image == null
                        ? Image.asset(
                            "assets/avatar/default-profile.png",
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            _image!,
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    bottom: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: const Text('Choose Image'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _openCamera();
                                  },
                                  child: const Text('Take a Photo',
                                      style:
                                          TextStyle(color: Colors.blueAccent)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _openFilePicker();
                                  },
                                  child: const Text('Choose from Gallery',
                                      style:
                                          TextStyle(color: Colors.blueAccent)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.photo_camera,
                            color: Colors.black54,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                'Yoon Hannie', // Replace 'Username' with the actual username
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 25),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Edit your personal information', // Replace 'Username' with the actual username
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF96B0D7),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Email"),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: 'Input new email',
                          fillColor:
                              Colors.white, // Set background color to white
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 15), // Adjust the vertical padding
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20), // Set circular border radius
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("Username"),
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          hintText: 'Input new username',
                          fillColor:
                              Colors.white, // Set background color to white
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 15), // Adjust the vertical padding
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20), // Set circular border radius
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text("Contact"),
                      TextField(
                        controller: contactController,
                        decoration: const InputDecoration(
                          hintText: 'Input new contact',
                          fillColor:
                              Colors.white, // Set background color to white
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 15), // Adjust the vertical padding
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20), // Set circular border radius
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
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
