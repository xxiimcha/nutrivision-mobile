import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';  // For formatting dates
import 'package:sjq/themes/themes.dart';

class PlanScreen extends StatefulWidget {
  final String patientId; // Patient ID passed from the previous screen

  const PlanScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  Map<String, dynamic> mealPlan = {};
  bool isLoading = true;
  DateTime currentWeekStart = DateTime.now();  // Keep track of the week's starting Monday

  @override
  void initState() {
    super.initState();
    currentWeekStart = _getMondayOfCurrentWeek(DateTime.now());  // Initialize with current Monday
    _loadMealPlan();  // Load the meal plan when the screen is initialized
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
      _loadMealPlan();  // Reload meal plan for the new week
    });
  }

  // Navigate to the next week
  void _nextWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
      _loadMealPlan();  // Reload meal plan for the new week
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
      String weekStart = _formatDate(currentWeekStart);  // Get the Monday's date
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/mealplans/${widget.patientId}?week=$weekStart'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic>) {
          setState(() {
            mealPlan = responseData;
            isLoading = false;
          });
        } else {
          setState(() {
            mealPlan = {};
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
    DateTime weekEnd = currentWeekStart.add(const Duration(days: 6));  // End of the week (Sunday)

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
                : mealPlan.isEmpty
                    ? const Center(
                        child: Text(
                          'No approved meal plans yet for the selected patient.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: mealPlan.keys.map((day) {
                            final meals = mealPlan[day];
                            return _buildMealPlanCard(day, meals);
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanCard(String day, dynamic meals) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 10),
            if (meals is Map<String, dynamic>)
              Column(
                children: ['breakfast', 'lunch', 'dinner'].map((mealType) {
                  final mealData = meals[mealType];
                  return mealData != null && mealData['approved'] == true
                      ? _buildMealRow(mealType, mealData)
                      : const SizedBox.shrink();  // Show only approved meals
                }).toList(),
              )
            else
              const Text('No approved meals available for this day'),
          ],
        ),
      ),
    );
  }

  Widget _buildMealRow(String mealType, Map<String, dynamic> mealData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${mealType[0].toUpperCase()}${mealType.substring(1)}: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          Expanded(
            child: Text(
              'Main Dish: ${mealData['mainDish'] ?? 'N/A'}, Drinks: ${mealData['drinks'] ?? 'N/A'}, Vitamins: ${mealData['vitamins'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
