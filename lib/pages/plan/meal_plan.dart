import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';  // For formatting dates
import 'package:sjq/themes/themes.dart'; // Import your theme styles

class PlanScreen extends StatefulWidget {
  final String patientId; // Patient ID passed from the previous screen

  const PlanScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  Map<String, dynamic> mealPlan = {};
  bool isLoading = true;
  DateTime currentWeekStart = DateTime.now(); // Keep track of the week's starting Monday
  int? expandedPanelIndex; // Track which panel is expanded

  @override
  void initState() {
    super.initState();
    currentWeekStart = _getMondayOfCurrentWeek(DateTime.now()); // Initialize with current Monday
    _loadMealPlan(); // Load the meal plan when the screen is initialized
  }

  // Method to get the Monday of the current week
  DateTime _getMondayOfCurrentWeek(DateTime date) {
    final int daysToSubtract = date.weekday - DateTime.monday;
    return date.subtract(Duration(days: daysToSubtract));
  }

  // Format date to 'yyyy-MM-dd'
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Navigate to the previous week
  void _previousWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 7));
      _loadMealPlan(); // Reload meal plan for the new week
    });
  }

  // Navigate to the next week
  void _nextWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
      _loadMealPlan(); // Reload meal plan for the new week
    });
  }

  Future<void> _loadMealPlan() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        print('Error: User ID not found in SharedPreferences.');
        return;
      }

      // Fetch the meal plan for the selected patient and week
      String weekStart = _formatDate(currentWeekStart); // Get the Monday's date
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/mealplans/${widget.patientId}?week=$weekStart'),
        headers: {'Content-Type': 'application/json'},
      );

      // Print the response
      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic>) {
          setState(() {
            mealPlan = responseData;
            isLoading = false;
          });
        } else {
          // Handle case where data format isn't as expected
          setState(() {
            mealPlan = {}; // Empty if no valid meal plan
            isLoading = false;
          });
        }
      } else {
        print('Failed to load meal plan: ${response.reasonPhrase}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading meal plan: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime weekEnd = currentWeekStart.add(const Duration(days: 6)); // End of the week (Sunday)

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorLightBlue,
        title: const Text("Meal Plan", style: headingS),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousWeek,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Text(
                  '${_formatDate(currentWeekStart)} to ${_formatDate(weekEnd)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                ElevatedButton(
                  onPressed: _nextWeek,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildAccordion(), // Use Accordion to display each day's meals
                  ),
          ),
        ],
      ),
    );
  }

  // Build Accordion for each day
  Widget _buildAccordion() {
  List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  return ExpansionPanelList.radio(
    initialOpenPanelValue: expandedPanelIndex,
    children: daysOfWeek.asMap().entries.map((entry) {
      int index = entry.key;
      String day = entry.value;
      Map<String, dynamic>? meals = mealPlan[day]; // Access meals for the day

      return ExpansionPanelRadio(
        value: index,
        headerBuilder: (BuildContext context, bool isExpanded) {
          return ListTile(
            title: Text(
              day,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        },
        body: meals != null
            ? _buildMealPlanForDay(meals)
            : const Padding(
                padding: EdgeInsets.all(10),
                child: Text('No meal plan for this day', style: TextStyle(color: Colors.grey)),
              ),
      );
    }).toList(),
  );
}


  // Build meal plan cards for a day (breakfast, lunch, dinner)
  Widget _buildMealPlanForDay(Map<String, dynamic> meals) {
    return Column(
      children: ['breakfast', 'lunch', 'dinner'].map((mealType) {
        // Check if the meal exists for the day and display the meal card
        if (meals.containsKey(mealType) && meals[mealType] != null && meals[mealType]['approved'] == true) {
          return _buildMealCard(mealType, meals[mealType]);
        } else {
          // Handle case where there's no data for a meal or it isn't approved
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$mealType: No approved meal',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }
      }).toList(),
    );
  }


  Widget _buildMealCard(String mealType, Map<String, dynamic> mealData) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 5,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                mealType.toUpperCase(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: mealData['approved'] == true ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  mealData['approved'] == true ? 'DONE' : 'IN PROGRESS',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildMealRow("Main dish", mealData['mainDish']),
          _buildMealRow("Drinks", mealData['drinks']),
          _buildMealRow("Vitamins", mealData['vitamins']),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}


  Widget _buildMealRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value ?? 'N/A')),
      ],
    );
  }
}
