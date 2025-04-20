import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sjq/constant/constant.dart';
import 'package:sjq/navigator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart'; // To get the basename of the file.
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  String _fullName = '';
  String _initialFirstName = '';
  String _initialLastName = '';
  String _initialEmail = '';
  String _initialContact = '';
  String _initialUsername = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

Future<void> _loadUserData() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      final response = await http.get(Uri.parse('$BASE_URL/users/$userId'));
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        if (mounted) { // Check if the widget is still mounted
          setState(() {
            fullNameController.text = userData['username'] ?? '';
            firstNameController.text = userData['firstName'] ?? '';
            lastNameController.text = userData['lastName'] ?? '';
            emailController.text = userData['email'] ?? '';
            contactController.text = userData['contact'] ?? '';

            _initialFirstName = userData['firstName'] ?? '';
            _initialLastName = userData['lastName'] ?? '';
            _initialEmail = userData['email'] ?? '';
            _initialContact = userData['contact'] ?? '';
            _initialUsername = userData['username'] ?? '';

            _fullName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
          });
        }
      }
    }
  } catch (e) {
    debugPrint('Error loading user data: $e');
  }
}
  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _openFilePicker() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

void saveChanges(BuildContext context) async {
  if (firstNameController.text == _initialFirstName &&
      lastNameController.text == _initialLastName &&
      emailController.text == _initialEmail &&
      contactController.text == _initialContact &&
      fullNameController.text == _initialUsername &&
      _image == null) { // Add check for image here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No changes detected')),
    );
    return;
  }

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      final url = Uri.parse('$BASE_URL/users/$userId');
      
      // Create a multipart request
      final request = http.MultipartRequest("PUT", url);

      // Add text fields
      request.fields['username'] = fullNameController.text;
      request.fields['firstName'] = firstNameController.text;
      request.fields['lastName'] = lastNameController.text;
      request.fields['email'] = emailController.text;
      request.fields['contact'] = contactController.text;

      // Add the image if it exists
      if (_image != null) {
        final mimeTypeData = lookupMimeType(_image!.path)!.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo', // this should match your backend's field name
            _image!.path,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
            filename: basename(_image!.path),
          ),
        );
      }

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );
        Timer(const Duration(seconds: 1), () {
          AppNavigator().pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save changes')),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving changes: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: const Color.fromARGB(255, 15, 56, 169),
        iconTheme: const IconThemeData(color: Colors.white), // Change back arrow color to white
      ),
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
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
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
                                  child: const Text('Take a Photo', style: TextStyle(color: Colors.blueAccent)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _openFilePicker();
                                  },
                                  child: const Text('Choose from Gallery', style: TextStyle(color: Colors.blueAccent)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
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
              Text(
                _fullName,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Edit your personal information',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFFE8F0FE), // Light background for the form
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
                      _buildTextField(emailController, 'Input new email'),
                      const SizedBox(height: 15),
                      const Text("First Name", style: TextStyle(fontWeight: FontWeight.w600)),
                      _buildTextField(firstNameController, 'Input new first name'),
                      const SizedBox(height: 15),
                      const Text("Last Name", style: TextStyle(fontWeight: FontWeight.w600)),
                      _buildTextField(lastNameController, 'Input new last name'),
                      const SizedBox(height: 15),
                      const Text("Username", style: TextStyle(fontWeight: FontWeight.w600)),
                      _buildTextField(fullNameController, 'Input new username'),
                      const SizedBox(height: 15),
                      const Text("Contact", style: TextStyle(fontWeight: FontWeight.w600)),
                      _buildTextField(contactController, 'Input new contact'),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => saveChanges(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 15, 56, 169), // Consistent button color
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
      ),
    );
  }
}
