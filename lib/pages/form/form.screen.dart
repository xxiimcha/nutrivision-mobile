import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sjq/models/client.model.dart';
import 'package:sjq/services/user/user.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sjq/themes/themes.dart';
import 'patients_details.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {

  UserService userService = UserService();
  TextEditingController houseNumberController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController motherNameController = TextEditingController();
  TextEditingController patientNameController = TextEditingController();
  TextEditingController patientDobController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController dateOfWeighingController = TextEditingController();

  String selectedSex = 'Male'; // Default selection
  String weightForAge = 'Normal';
  String heightForAge = 'Normal';
  String weightForHeight = 'Normal';
  String nutritionStatus = 'Normal';
  String selectedZone = ''; // Zone selection

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Client> patients = []; // To store the list of patients
  bool showForm = false; // To toggle between the form and the list of patients

  final List<String> zones = [
    'Zone 1 - Kalayaan',
    'Zone 1 - Santol',
    'Zone 1 - Half Acacia',
    'Zone 1 - Half Narra',
    'Zone 2 - Half Acacia',
    'Zone 2 - Molave',
    'Zone 3 - Ilang-ilang',
    'Zone 3 - Jasmin',
    'Zone 3 - Camia',
    'Zone 3 - Guiho',
    'Zone 3 - Lower Guiho',
    'Zone 3 - Half Sampaguita',
    'Zone 3 - Half Acacia',
    'Zone 4 - Manga',
    'Zone 4 - Chico',
    'Zone 4 - Kamias',
    'Zone 4 - Bayabas',
    'Zone 4 - Half Banaba',
    'Zone 4 - Half Sampaguita',
    'Zone 5 - Half Manga',
    'Zone 5 - Half Tangile',
    'Zone 5 - Half Ipil',
    'Zone 5 - Half Acacia',
    'Zone 5 - Half Banaba',
    'Zone 6 - Half Narra',
    'Zone 6 - Half Tangile',
    'Zone 6 - Mabolo',
    'Zone 7 - Bliss',
    'Zone 8 - Macda'
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients(); // Load patient records when the screen is initialized
  }

  Future<void> _loadPatients() async {
    String? userId = await getUserId();
    if (userId != null) {
      List<Client> records = await userService.getPatientsByUserId(userId);
      setState(() {
        patients = records;
      });
    }
  }

  void _clearFormFields() {
    houseNumberController.clear(); // Clear house number
    streetController.clear(); // Clear street
    cityController.clear(); // Clear city
    motherNameController.clear();
    patientNameController.clear();
    patientDobController.clear();
    heightController.clear();
    weightController.clear();
    dateOfWeighingController.clear();
    
    setState(() {
      selectedZone = ''; // Reset zone selection
      weightForAge = 'Normal';
      heightForAge = 'Normal';
      weightForHeight = 'Normal';
      nutritionStatus = 'Normal';
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _calculateStatuses(); // Recalculate statuses after the date is picked
      });
    }
  }

  void _calculateStatuses() {
    double weight = double.tryParse(weightController.text) ?? 0;
    double height = double.tryParse(heightController.text) ?? 0;
    int ageInMonths = _calculateAgeInMonths();

    if (weight <= 0 || height <= 0 || ageInMonths == 0 || ageInMonths > 59) {
      setState(() {
        nutritionStatus = 'Unknown'; // Set Unknown if values are invalid
      });
      return;
    }

    // Calculate Weight-for-Age
    if (ageInMonths <= 1) {
      if (weight < 2.5) {
        weightForAge = 'Underweight';
      } else if (weight >= 2.5 && weight <= 4.5) {
        weightForAge = 'Normal';
      } else {
        weightForAge = 'Overweight';
      }
    } else if (ageInMonths <= 3) {
      if (weight < 4.5) {
        weightForAge = 'Underweight';
      } else if (weight >= 4.5 && weight <= 6.5) {
        weightForAge = 'Normal';
      } else {
        weightForAge = 'Overweight';
      }
    } else if (ageInMonths <= 6) {
      if (weight < 6) {
        weightForAge = 'Underweight';
      } else if (weight >= 6 && weight <= 8) {
        weightForAge = 'Normal';
      } else {
        weightForAge = 'Overweight';
      }
    } else if (ageInMonths <= 12) {
      if (weight < 7.5) {
        weightForAge = 'Underweight';
      } else if (weight >= 7.5 && weight <= 10.5) {
        weightForAge = 'Normal';
      } else {
        weightForAge = 'Overweight';
      }
    } else if (ageInMonths <= 24) {
      if (weight < 9) {
        weightForAge = 'Underweight';
      } else if (weight >= 9 && weight <= 12.5) {
        weightForAge = 'Normal';
      } else {
        weightForAge = 'Overweight';
      }
    } else if (ageInMonths <= 36) {
      if (weight < 11) {
        weightForAge = 'Underweight';
      } else if (weight >= 11 && weight <= 15) {
        weightForAge = 'Normal';
      } else {
        weightForAge = 'Overweight';
      }
    } else if (ageInMonths <= 48) {
      if (weight < 12.5) {
        weightForAge = 'Underweight';
      } else if (weight >= 12.5 && weight <= 18) {
        weightForAge = 'Normal';
      } else {
        weightForAge = 'Overweight';
      }
    } else if (ageInMonths <= 59) {
      if (weight < 13) {
        weightForAge = 'Underweight';
      } else if (weight >= 13 && weight <= 20) {
        weightForAge = 'Normal';
      } else {
        weightForAge = 'Overweight';
      }
    }

    // Calculate Weight-for-Height (simple ratio as an example)
    double weightToHeightRatio = weight / height;
    if (weightToHeightRatio < 0.15) {
      weightForHeight = 'Wasted';
    } else if (weightToHeightRatio >= 0.15 && weightToHeightRatio <= 0.20) {
      weightForHeight = 'Normal';
    } else {
      weightForHeight = 'Overweight';
    }

    // Final Nutrition Status: Malnourished, Normal, or Obese
    if (weightForAge == 'Underweight' || weightForHeight == 'Wasted') {
      nutritionStatus = 'Malnourished';
    } else if (weightForAge == 'Overweight' || weightForHeight == 'Overweight') {
      nutritionStatus = 'Obese';
    } else {
      nutritionStatus = 'Normal';
    }

    // Update UI
    setState(() {
      weightForAge = weightForAge;
      heightForAge = heightForAge;
      weightForHeight = weightForHeight;
      nutritionStatus = nutritionStatus;
    });
  }

  int _calculateAgeInMonths() {
    if (patientDobController.text.isEmpty) return 0;
    try {
      DateTime dob = DateTime.parse(patientDobController.text);
      DateTime now = DateTime.now();
      int ageInMonths = (now.year - dob.year) * 12 + now.month - dob.month;

      if (ageInMonths > 59) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Age exceeds 59 months.')),
        );
        return 0;
      }
      return ageInMonths;
    } catch (e) {
      return 0;
    }
  }

  double _calculateGoalWeight(int ageInMonths, double height) {
    // Define the weight ranges for different age groups
    if (ageInMonths <= 1) {
      return (2.5 + 4.5) / 2; // Average weight for birth to 1 month
    } else if (ageInMonths <= 3) {
      return (4.5 + 6.5) / 2; // Average weight for 1-3 months
    } else if (ageInMonths <= 6) {
      return (6 + 8) / 2; // Average weight for 3-6 months
    } else if (ageInMonths <= 12) {
      return (7.5 + 10.5) / 2; // Average weight for 6-12 months
    } else if (ageInMonths <= 24) {
      return (9 + 12.5) / 2; // Average weight for 1-2 years (12-24 months)
    } else if (ageInMonths <= 36) {
      return (11 + 15) / 2; // Average weight for 2-3 years (24-36 months)
    } else if (ageInMonths <= 48) {
      return (12.5 + 18) / 2; // Average weight for 3-4 years (36-48 months)
    } else if (ageInMonths <= 59) {
      return (13 + 20) / 2; // Average weight for 4-5 years (48-59 months)
    } else {
      return 0; // If age is outside valid range
    }
  }

  Future<void> saveButtonPressed(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      int ageInMonths = _calculateAgeInMonths();
      if (ageInMonths == 0 || ageInMonths > 59) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Age exceeds 59 months. Please enter a valid date of birth.')),
        );
        return;
      }

      String houseNumber = houseNumberController.text;
      String street = streetController.text;
      String city = cityController.text;
      String motherName = motherNameController.text;
      String patientName = patientNameController.text;
      String patientDob = patientDobController.text;
      String patientHeight = heightController.text;
      String patientSex = selectedSex;
      String patientWeight = weightController.text;
      String actualDate = dateOfWeighingController.text;
      String? userId = await getUserId(); // Get the current user's ID

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User ID not found')),
        );
        return;
      }

      // Calculate the full address by concatenating the input fields
      String fullAddress = "$houseNumber $street, $city, $selectedZone";

      // Calculate the goal weight based on age and height
      double goalWeight = _calculateGoalWeight(ageInMonths, double.tryParse(heightController.text) ?? 0);

      // Confirm and submit data
      Client newClient = Client(
        guardian: motherName,
        address: fullAddress, // Use the concatenated address
        name: patientName,
        dob: patientDob,
        gender: patientSex,
        height: patientHeight,
        weight: patientWeight,
        dateOfWeighing: actualDate,
        weightForAge: weightForAge,
        heightForAge: heightForAge,
        weightForHeight: weightForHeight,
        nutritionStatus: nutritionStatus,
        ageInMonths: ageInMonths,
        userId: userId, // Pass the userId to the client object
        goalWeight: goalWeight.toStringAsFixed(2), // Store the calculated goal weight
      );

      await userService.createEntry(newClient);
      _clearFormFields();
      _loadPatients(); // Reload the patient list after saving a new entry
      setState(() {
        showForm = false; // Show the patient list after saving
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client saved successfully!')),
      );
    }
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // Retrieve the stored userId
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorLightBlue,
        title: const Text("Patient Records", style: headingS),
        centerTitle: true,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: patients.isEmpty
            ? showForm
                ? _buildForm() // Show form if there are no records
                : Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showForm = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button color (blue)
                        foregroundColor: Colors.white, // Text color (white)
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Rounded corners
                        ),
                        elevation: 5, // Adds shadow to give a raised effect
                      ),
                      child: const Text(
                        "Add New Entry",
                        style: TextStyle(
                          fontSize: 18, // Larger text size
                          fontWeight: FontWeight.bold, // Bold text for emphasis
                        ),
                      ),
                    ),
                  )
            : showForm
                ? _buildForm() // Show form if user clicked "Add New Entry"
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Patient List",
                        style: headingS,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0), // Adds vertical spacing between items
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to the details screen when tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientDetailsScreen(patient: patients[index]),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 3, // Adds a subtle shadow for depth
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15), // Rounded corners for the card
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0), // Adds padding inside the card
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patients[index].name ?? 'Unknown Name',
                                        style: const TextStyle(
                                          fontSize: 18, // Increased font size for better readability
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue, // Blue text for the patient name
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showForm = true;
                            });
                          },
                          child: const Text("Add New Entry"),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Please fill out this form with the required details.", style: headingS),
            const SizedBox(height: 15),

            // House Number Field
            TextFormField(
              controller: houseNumberController,
              textCapitalization: TextCapitalization.words, // Capitalize first letter of each word
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the house number';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintStyle: paragraphS,
                hintText: 'HOUSE NUMBER',
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Street Field
            TextFormField(
              controller: streetController,
              textCapitalization: TextCapitalization.words, // Capitalize first letter of each word
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the street';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintStyle: paragraphS,
                hintText: 'STREET',
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // City Field
            TextFormField(
              controller: cityController,
              textCapitalization: TextCapitalization.words, // Capitalize first letter of each word
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the city';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintStyle: paragraphS,
                hintText: 'CITY',
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Zone Dropdown Field
            DropdownButtonFormField<String>(
              value: selectedZone.isEmpty ? null : selectedZone,
              onChanged: (value) {
                setState(() {
                  selectedZone = value!;
                });
              },
              items: zones.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                hintStyle: paragraphS,
                hintText: 'SELECT ZONE',
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: motherNameController,
              textCapitalization: TextCapitalization.words, // Capitalize first letter of each word
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the mother/caregiver\'s name';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintStyle: paragraphS,
                hintText: 'MOTHER/CAREGIVER NAME',
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Child's Name Field
            TextFormField(
              controller: patientNameController,
              textCapitalization: TextCapitalization.words, // Capitalize first letter of each word
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the child\'s name';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintStyle: paragraphS,
                hintText: 'CHILD\'S NAME',
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Child's Date of Birth Field
            GestureDetector(
              onTap: () => _selectDate(context, patientDobController),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: patientDobController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the child\'s date of birth';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintStyle: paragraphS,
                    hintText: 'DATE OF BIRTH (YYYY-MM-DD)',
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Gender Dropdown Field
            DropdownButtonFormField<String>(
              value: selectedSex,
              onChanged: (value) {
                setState(() {
                  selectedSex = value!;
                  _calculateStatuses();
                });
              },
              items: <String>['Male', 'Female'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                hintStyle: paragraphS,
                hintText: 'GENDER',
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Height Field
            TextFormField(
              controller: heightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (value) {
                _calculateStatuses(); // Recalculate statuses after height is input
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the height (in cm)';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintStyle: paragraphS,
                hintText: 'HEIGHT (CM)',
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                suffixText: 'CM',
              ),
            ),
            const SizedBox(height: 15),

            // Weight Field
            TextFormField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              onChanged: (value) {
                _calculateStatuses(); // Recalculate statuses after weight is input
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the weight (in kg)';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintStyle: paragraphS,
                hintText: 'WEIGHT (KG)',
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                suffixText: 'KG',
              ),
            ),
            const SizedBox(height: 15),

            // Actual Date of Weighing Field
            GestureDetector(
              onTap: () => _selectDate(context, dateOfWeighingController),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: dateOfWeighingController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the actual date of weighing';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintStyle: paragraphS,
                    hintText: 'ACTUAL DATE OF WEIGHING (YYYY-MM-DD)',
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button with blue background and white text
            Center(
              child: ElevatedButton(
                onPressed: () {
                  saveButtonPressed(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue background color
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Rounded corners
                  ),
                  elevation: 5, // Adds slight shadow effect
                ),
                child: const Text(
                  "SUBMIT",
                  style: TextStyle(
                    color: Colors.white, // White text color
                    fontSize: 16, // Adjusted text size
                    fontWeight: FontWeight.bold, // Bold text
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
