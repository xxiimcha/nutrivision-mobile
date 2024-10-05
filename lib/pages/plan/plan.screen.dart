import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sjq/themes/themes.dart';
import 'package:intl/intl.dart'; // For formatting dates

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
  DateTime selectedDate = DateTime.now(); // Initialize with current date
  String selectedWeek = ''; // To track the selected week for meal plans

  @override
  void initState() {
    super.initState();
    selectedWeek = _getWeekOfYear(selectedDate); // Set the current week
    _loadMealPlan(); // Load initial meal plan
  }

  Future<void> _loadMealPlan() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        print('Error: User ID not found in SharedPreferences.');
        return;
      }

      // Fetch the patient record
      final patientResponse = await http.get(
        Uri.parse('http://localhost:5000/api/patients/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (patientResponse.statusCode != 200) {
        print('Failed to load patient record: ${patientResponse.reasonPhrase}');
        return;
      }

      final patientData = jsonDecode(patientResponse.body);
      final patientId = patientData['_id'];

      // Fetch the meal plan for this patient and the selected week
      // Make sure selectedWeek is formatted properly to match your DB format
      final mealPlanResponse = await http.get(
        Uri.parse('http://localhost:5000/api/mealplans/$patientId/$selectedWeek'),
        headers: {'Content-Type': 'application/json'},
      );

      if (mealPlanResponse.statusCode == 200) {
        final responseData = jsonDecode(mealPlanResponse.body);

        if (responseData != null && responseData.isNotEmpty) {
          setState(() {
            mealPlan = responseData as Map<String, dynamic>;
          });
        } else {
          setState(() {
            mealPlan = {};
          });
          print('No meal plans found for this week.');
        }
      } else {
        print('Failed to load meal plan: ${mealPlanResponse.reasonPhrase}');
      }
    } catch (e) {
      print('Error loading meal plan: $e');
    }
  }

  // Method to navigate to the previous week
  void _previousWeek() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 7));
      selectedWeek = _getWeekOfYear(selectedDate);
      _loadMealPlan(); // Load the meal plan for the previous week
    });
  }

  // Method to navigate to the next week
  void _nextWeek() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 7));
      selectedWeek = _getWeekOfYear(selectedDate);
      _loadMealPlan(); // Load the meal plan for the next week
    });
  }

  // Method to pick an image from the gallery and show preview modal
  Future<void> _pickImage(String mealType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _showPreviewModal(File(pickedFile.path), mealType);
    }
  }

  // Method to take a photo using the camera and show preview modal
  Future<void> _takePhoto(String mealType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _showPreviewModal(File(pickedFile.path), mealType);
    }
  }

  // Method to show the preview modal with options to upload or reselect
  void _showPreviewModal(File imageFile, String mealType) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            children: [
              Text(
                'Preview $mealType Image',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Image.file(
                  imageFile,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the modal
                      _uploadImage(imageFile, mealType); // Upload the image
                    },
                    child: const Text('Upload Now'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the modal
                      _reselectImage(mealType); // Allow user to reselect the image
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Reselect Image'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to allow the user to reselect an image
  Future<void> _reselectImage(String mealType) async {
    _pickImage(mealType);
  }

  // Method to upload an image file to the server
  Future<void> _uploadImage(File image, String mealType) async {
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
        request.fields['mealType'] = mealType; // Pass the meal type

        final response = await request.send();

        if (response.statusCode == 200) {
          setState(() {
            switch (mealType) {
              case 'BREAKFAST':
                _breakfastImage = image;
                break;
              case 'LUNCH':
                _lunchImage = image;
                break;
              case 'SNACK':
                _snackImage = image;
                break;
              case 'DINNER':
                _dinnerImage = image;
                break;
            }
          });
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
  
  // Method to select a date using a calendar
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020), // Change this to your desired start date
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        selectedWeek = _getWeekOfYear(selectedDate); // Get the week based on the selected date
        _loadMealPlan(); // Reload meal plan for the selected week
      });
    }
  }

  // Helper function to calculate the day of the year
  int _getDayOfYear(DateTime date) {
    return int.parse(DateFormat("D").format(date));
  }

  // Helper function to get the week number of a given date
  String _getWeekOfYear(DateTime date) {
    final weekNumber = ((_getDayOfYear(date) - date.weekday + 10) / 7).floor();
    return 'Week $weekNumber, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorLightBlue,
        title: const Text("NUTRITIONAL PLAN", style: headingS),
        centerTitle: true,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              _selectDate(context); // Trigger the date picker
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousWeek,
                  child: const Text('Previous Week'),
                ),
                Text(
                  selectedWeek, // Display the current week
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _nextWeek,
                  child: const Text('Next Week'),
                ),
              ],
            ),
          ),
          Expanded(
            child: mealPlan.isNotEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: ExpansionPanelList.radio(
                      children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        String day = entry.value;
                        return ExpansionPanelRadio(
                          value: index, // Unique identifier for each panel
                          headerBuilder: (BuildContext context, bool isExpanded) {
                            return ListTile(
                              title: Text(
                                day,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                          body: Column(
                            children: [
                              _buildMealCard(
                                context: context,
                                day: day,
                                meal: 'BREAKFAST',
                                isDone: isBreakfastDone,
                                mainDish: mealPlan[day]?['breakfast']?['mainDish'] ?? 'N/A',
                                vitamins: [mealPlan[day]?['breakfast']?['vitamins'] ?? ''],
                                drinks: [mealPlan[day]?['breakfast']?['drinks'] ?? ''],
                                imageFile: _breakfastImage,
                                onUploadPhoto: () => _pickImage('BREAKFAST'),
                                onTakePhoto: () => _takePhoto('BREAKFAST'),
                                onStatusChanged: (status) {
                                  setState(() {
                                    isBreakfastDone = status;
                                  });
                                },
                              ),
                              _buildMealCard(
                                context: context,
                                day: day,
                                meal: 'LUNCH',
                                isDone: isLunchDone,
                                mainDish: mealPlan[day]?['lunch']?['mainDish'] ?? 'N/A',
                                vitamins: [mealPlan[day]?['lunch']?['vitamins'] ?? ''],
                                drinks: [mealPlan[day]?['lunch']?['drinks'] ?? ''],
                                imageFile: _lunchImage,
                                onUploadPhoto: () => _pickImage('LUNCH'),
                                onTakePhoto: () => _takePhoto('LUNCH'),
                                onStatusChanged: (status) {
                                  setState(() {
                                    isLunchDone = status;
                                  });
                                },
                              ),
                              _buildMealCard(
                                context: context,
                                day: day,
                                meal: 'SNACK',
                                isDone: isSnackDone,
                                mainDish: mealPlan[day]?['snack']?['mainDish'] ?? 'N/A',
                                vitamins: [mealPlan[day]?['snack']?['vitamins'] ?? ''],
                                drinks: [mealPlan[day]?['snack']?['drinks'] ?? ''],
                                imageFile: _snackImage,
                                onUploadPhoto: () => _pickImage('SNACK'),
                                onTakePhoto: () => _takePhoto('SNACK'),
                                onStatusChanged: (status) {
                                  setState(() {
                                    isSnackDone = status;
                                  });
                                },
                              ),
                              _buildMealCard(
                                context: context,
                                day: day,
                                meal: 'DINNER',
                                isDone: isDinnerDone,
                                mainDish: mealPlan[day]?['dinner']?['mainDish'] ?? 'N/A',
                                vitamins: [mealPlan[day]?['dinner']?['vitamins'] ?? ''],
                                drinks: [mealPlan[day]?['dinner']?['drinks'] ?? ''],
                                imageFile: _dinnerImage,
                                onUploadPhoto: () => _pickImage('DINNER'),
                                onTakePhoto: () => _takePhoto('DINNER'),
                                onStatusChanged: (status) {
                                  setState(() {
                                    isDinnerDone = status;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const Center(
                    child: Text(
                      'No meal plans found for the current or previous week',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard({
    required BuildContext context,
    required String day,
    required String meal,
    required bool isDone,
    required String mainDish,
    required List<String> vitamins,
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
                '$meal for $day',
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
          if (vitamins.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildBorderedText(
                'Vitamins: ${vitamins.join(', ')}',
                fontSize: 14,
              ),
            ),
          if (drinks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildBorderedText(
                'Drinks: ${drinks.join(', ')}',
                fontSize: 14),
            ),
          const SizedBox(height: 10),
          if (imageFile != null)
            Center(
              child: Image.file(
                imageFile!,
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
                  backgroundColor: MaterialStateProperty.all<Color>(colorLightBlue),
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
                  backgroundColor: MaterialStateProperty.all<Color>(colorLightBlue),
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
