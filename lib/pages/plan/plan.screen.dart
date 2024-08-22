import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:sjq/themes/themes.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  bool isBreakfastDone = false;
  bool isLunchDone = false;
  bool isSnackDone = false;
  bool isDinnerDone = false;

  File? _breakfastImage;
  File? _lunchImage;
  File? _snackImage;
  File? _dinnerImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String mealType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        switch (mealType) {
          case 'BREAKFAST':
            _breakfastImage = File(pickedFile.path);
            break;
          case 'LUNCH':
            _lunchImage = File(pickedFile.path);
            break;
          case 'SNACK':
            _snackImage = File(pickedFile.path);
            break;
          case 'DINNER':
            _dinnerImage = File(pickedFile.path);
            break;
        }
      }
    });
  }

  Future<void> _takePhoto(String mealType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        switch (mealType) {
          case 'BREAKFAST':
            _breakfastImage = File(pickedFile.path);
            break;
          case 'LUNCH':
            _lunchImage = File(pickedFile.path);
            break;
          case 'SNACK':
            _snackImage = File(pickedFile.path);
            break;
          case 'DINNER':
            _dinnerImage = File(pickedFile.path);
            break;
        }
      }
    });
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
              mainDish: 'Omelette',
              extraMeals: ['Toast'],
              drinks: ['Orange Juice'],
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
              mainDish: 'Grilled Chicken',
              extraMeals: ['Steamed Vegetables', 'Rice'],
              drinks: ['Water'],
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
              mainDish: 'Fruit Salad',
              extraMeals: ['Yogurt', 'Granola Bar'],
              drinks: ['Smoothie'],
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
              mainDish: 'Salmon',
              extraMeals: ['Quinoa', 'Roasted Vegetables'],
              drinks: ['Herbal Tea'],
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
                  backgroundColor: WidgetStateProperty.all<Color>(
                    isDone? Colors.green : Colors.red,
                  ),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  elevation: WidgetStateProperty.all<double>(0), // Set elevation to 0
                ),
                onPressed: () {
                  onStatusChanged(!isDone);
                },
                child: Text(
                  isDone? 'Done' : 'In Progress',
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
                  backgroundColor: WidgetStateProperty.all<Color>(colorLightBlue),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
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
                  backgroundColor: WidgetStateProperty.all<Color>(colorLightBlue),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
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
