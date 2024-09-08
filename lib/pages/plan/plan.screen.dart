import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sjq/themes/themes.dart';
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  // Meal completion states
  bool isBreakfastDone = false;
  bool isLunchDone = false;
  bool isSnackDone = false;
  bool isDinnerDone = false;

  // Image files for each meal
  File? _breakfastImage;
  File? _lunchImage;
  File? _snackImage;
  File? _dinnerImage;

  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic> mealPlan = {};

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  // Method to load the meal plan
  Future<void> _loadMealPlan() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        // Fetch the patient record
        final patientResponse = await http.get(
          Uri.parse('http://localhost:5000/api/patients/$userId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (patientResponse.statusCode == 200) {
          final patientData = jsonDecode(patientResponse.body);
          final patientId = patientData['_id'];

          // Now fetch the meal plan for this patient
          final mealPlanResponse = await http.get(
            Uri.parse('http://localhost:5000/api/mealplans/$patientId'),
            headers: {'Content-Type': 'application/json'},
          );

          if (mealPlanResponse.statusCode == 200) {
            final List<dynamic> data = jsonDecode(mealPlanResponse.body);

            if (data.isNotEmpty) {
              // Assuming you want to use the first meal plan in the list
              setState(() {
                mealPlan = data.first as Map<String, dynamic>;
              });
            } else {
              print('No meal plans found for this patient.');
            }
          } else {
            print('Failed to load meal plan: ${mealPlanResponse.reasonPhrase}');
          }
        } else {
          print('Failed to load patient record: ${patientResponse.reasonPhrase}');
        }
      } else {
        print('User ID not found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading meal plan: $e');
    }
  }

  // Method to pick an image from the gallery
  Future<void> _pickImage(String mealType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        switch (mealType) {
          case 'BREAKFAST':
            _breakfastImage = File(pickedFile.path);
            _uploadImage(_breakfastImage!);
            break;
          case 'LUNCH':
            _lunchImage = File(pickedFile.path);
            _uploadImage(_lunchImage!);
            break;
          case 'SNACK':
            _snackImage = File(pickedFile.path);
            _uploadImage(_snackImage!);
            break;
          case 'DINNER':
            _dinnerImage = File(pickedFile.path);
            _uploadImage(_dinnerImage!);
            break;
        }
      }
    });
  }

  // Method to take a photo using the camera
  Future<void> _takePhoto(String mealType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        switch (mealType) {
          case 'BREAKFAST':
            _breakfastImage = File(pickedFile.path);
            _uploadImage(_breakfastImage!);
            break;
          case 'LUNCH':
            _lunchImage = File(pickedFile.path);
            _uploadImage(_lunchImage!);
            break;
          case 'SNACK':
            _snackImage = File(pickedFile.path);
            _uploadImage(_snackImage!);
            break;
          case 'DINNER':
            _dinnerImage = File(pickedFile.path);
            _uploadImage(_dinnerImage!);
            break;
        }
      }
    });
  }

  // Method to upload an image file to the server
  Future<void> _uploadImage(File image) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:5000/api/mealplans/upload'),
        );
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
        request.fields['userId'] = userId;

        final response = await request.send();

        if (response.statusCode == 200) {
          print('Image uploaded successfully');
        } else {
          print('Failed to upload image: ${response.statusCode}');
        }
      } else {
        print('User ID not found in SharedPreferences');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorLightBlue,
        title: const Text("NUTRITIONAL PLAN", style: headingS),
        centerTitle: true,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMealCard(
              context: context,
              meal: 'BREAKFAST',
              isDone: isBreakfastDone,
              mainDish: mealPlan['Monday']?['breakfast']?['mainDish'] ?? 'N/A',
              extraMeals: [mealPlan['Monday']?['breakfast']?['extras'] ?? ''],
              drinks: [mealPlan['Monday']?['breakfast']?['drinks'] ?? ''],
              imageFile: _breakfastImage,
              onUploadPhoto: () => _pickImage('BREAKFAST'),
              onTakePhoto: () => _takePhoto('BREAKFAST'),
              onStatusChanged: (status) {
                setState(() {
                  isBreakfastDone = status;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildMealCard(
              context: context,
              meal: 'LUNCH',
              isDone: isLunchDone,
              mainDish: mealPlan['Monday']?['lunch']?['mainDish'] ?? 'N/A',
              extraMeals: [mealPlan['Monday']?['lunch']?['extras'] ?? ''],
              drinks: [mealPlan['Monday']?['lunch']?['drinks'] ?? ''],
              imageFile: _lunchImage,
              onUploadPhoto: () => _pickImage('LUNCH'),
              onTakePhoto: () => _takePhoto('LUNCH'),
              onStatusChanged: (status) {
                setState(() {
                  isLunchDone = status;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildMealCard(
              context: context,
              meal: 'SNACK',
              isDone: isSnackDone,
              mainDish: mealPlan['Monday']?['snack']?['mainDish'] ?? 'N/A',
              extraMeals: [mealPlan['Monday']?['snack']?['extras'] ?? ''],
              drinks: [mealPlan['Monday']?['snack']?['drinks'] ?? ''],
              imageFile: _snackImage,
              onUploadPhoto: () => _pickImage('SNACK'),
              onTakePhoto: () => _takePhoto('SNACK'),
              onStatusChanged: (status) {
                setState(() {
                  isSnackDone = status;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildMealCard(
              context: context,
              meal: 'DINNER',
              isDone: isDinnerDone,
              mainDish: mealPlan['Monday']?['dinner']?['mainDish'] ?? 'N/A',
              extraMeals: [mealPlan['Monday']?['dinner']?['extras'] ?? ''],
              drinks: [mealPlan['Monday']?['dinner']?['drinks'] ?? ''],
              imageFile: _dinnerImage,
              onUploadPhoto: () => _pickImage('DINNER'),
              onTakePhoto: () => _takePhoto('DINNER'),
              onStatusChanged: (status) {
                setState(() {
                  isDinnerDone = status;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard({
    required BuildContext context,
    required String meal,
    required bool isDone,
    required String mainDish,
    required List<String> extraMeals,
    required List<String> drinks,
    required File? imageFile,
    required Function() onUploadPhoto,
    required Function() onTakePhoto,
    required Function(bool) onStatusChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF96B0D7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meal,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    isDone ? Colors.green : Colors.red,
                  ),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  elevation: MaterialStateProperty.all<double>(0),
                ),
                onPressed: () {
                  onStatusChanged(!isDone);
                },
                child: Text(
                  isDone ? 'Done' : 'In Progress',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildBorderedText(
            'Main Dish: $mainDish',
            fontSize: 16,
          ),
          if (extraMeals.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildBorderedText(
                'Extra Meals: ${extraMeals.join(', ')}',
                fontSize: 14,
              ),
            ),
          if (drinks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildBorderedText(
                'Drinks: ${drinks.join(', ')}',
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 10),
          if (imageFile != null)
            Center(
              child: Image.file(
                imageFile,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          if (imageFile == null)
            const Text(
              'No image selected.',
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: onUploadPhoto,
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text(
                  'Upload Photo',
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(colorLightBlue),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onTakePhoto,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text(
                  'Take Photo',
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(colorLightBlue),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBorderedText(String text, {required double fontSize}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: TextStyle(color: Colors.black, fontSize: fontSize),
        ),
      ),
    );
  }
}
