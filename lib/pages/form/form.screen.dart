import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sjq/models/client.model.dart';
import 'package:sjq/services/user/user.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sjq/themes/themes.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  UserService userService = UserService();
  TextEditingController addressController = TextEditingController();
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _clearFormFields() {
    addressController.clear();
    motherNameController.clear();
    patientNameController.clear();
    patientDobController.clear();
    heightController.clear();
    weightController.clear();
    dateOfWeighingController.clear();
    setState(() {
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF96B0D7),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF96B0D7),
            ).copyWith(secondary: const Color(0xFF96B0D7)),
          ),
          child: child!,
        );
      },
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

    if (weight < 2.5) {
      weightForAge = 'Underweight';
    } else {
      weightForAge = 'Normal';
    }

    if (height < 45) {
      heightForAge = 'Stunted';
    } else {
      heightForAge = 'Normal';
    }

    if (weight / (height * height) > 25) {
      weightForHeight = 'Obese';
    } else if (weight / (height * height) < 18.5) {
      weightForHeight = 'Wasted';
    } else {
      weightForHeight = 'Normal';
    }

    nutritionStatus = (weightForAge == 'Normal' && heightForAge == 'Normal' && weightForHeight == 'Normal')
        ? 'Normal'
        : 'Malnourished';

    setState(() {});
  }

  int _calculateAgeInMonths() {
    if (patientDobController.text.isEmpty) return 0;
    try {
      DateTime dob = DateTime.parse(patientDobController.text);
      DateTime now = DateTime.now();
      int ageInMonths = (now.year - dob.year) * 12 + now.month - dob.month;
      return ageInMonths;
    } catch (e) {
      print("Error parsing date: $e");
      return 0;
    }
  }

  Future<void> saveButtonPressed(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String address = addressController.text;
      String motherName = motherNameController.text;
      String patientName = patientNameController.text;
      String patientDob = patientDobController.text;
      String patientHeight = heightController.text;
      String patientSex = selectedSex;
      String patientWeight = weightController.text;
      String actualDate = dateOfWeighingController.text;
      int ageInMonths = _calculateAgeInMonths();

      String? userId = await getUserId(); // Get the current user's ID

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: User ID not found'),
          ),
        );
        return;
      }

      Client newClient = Client(
        guardian: motherName,
        address: address,
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
      );

      await userService.createEntry(newClient);

      _clearFormFields();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client saved successfully!'),
        ),
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('New Client Information'),
            content: Text('Name: ${newClient.name}\n'
                'Guardian: ${newClient.guardian}\n'
                'Date of Birth: ${newClient.dob}\n'
                'Height: ${newClient.height}\n'
                'Sex: ${newClient.gender}\n'
                'Weight: ${newClient.weight}\n'
                'Actual Date of Weighing: ${newClient.dateOfWeighing}\n'
                'Age in Months: ${newClient.ageInMonths}\n' // Display ageInMonths
                'Weight-for-Age: ${newClient.weightForAge}\n'
                'Height-for-Age: ${newClient.heightForAge}\n'
                'Weight-for-Height: ${newClient.weightForHeight}\n'
                'Nutrition Status: ${newClient.nutritionStatus}\n'
                'User ID: ${newClient.userId}'), // Display the userId
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
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
        title: const Text("DATA ENTRY", style: headingS),
        centerTitle: true,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Please Fill out this form with the required details.",
                  style: headingS,
                ),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ADDRESS OR LOCATION OF RESIDENCE", style: paragraphS),
                    TextFormField(
                      controller: addressController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the address';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintStyle: paragraphS,
                        hintText: 'STREET OR BLOCK#/PUROK OR LANDMARK',
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "NAME OF MOTHER OR CAREGIVER",
                      style: paragraphS,
                    ),
                    TextFormField(
                      controller: motherNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the mother or caregiver name';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintStyle: paragraphS,
                        hintText: 'SURNAME, FIRST NAME',
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("FULL NAME OF CHILD", style: paragraphS),
                    TextFormField(
                      controller: patientNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the full name of the child';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintStyle: paragraphS,
                        hintText: 'SURNAME, FIRST NAME',
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("PATIENT DATE OF BIRTH", style: paragraphS),
                              GestureDetector(
                                onTap: () => _selectDate(context, patientDobController),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: patientDobController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select the date of birth';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      hintStyle: paragraphS,
                                      hintText: 'YYYY-MM-DD',
                                      fillColor: Colors.white,
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 15,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("SEX", style: paragraphS),
                              DropdownButtonFormField<String>(
                                value: selectedSex,
                                onChanged: (value) {
                                  setState(() {
                                    selectedSex = value!;
                                    _calculateStatuses(); // Recalculate statuses after sex is selected
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
                                  hintText: 'Select Sex',
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 15,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("PATIENT HEIGHT", style: paragraphS),
                              TextFormField(
                                controller: heightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*.?\d{0,2}')),
                                ],
                                onChanged: (value) {
                                  _calculateStatuses(); // Recalculate statuses after height is input
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the patient height';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintStyle: paragraphS,
                                  hintText: 'ENTER HEIGHT: CM',
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 15,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  suffixText: 'CM',
                                  suffixStyle: paragraphS,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("PATIENT WEIGHT", style: paragraphS),
                              TextFormField(
                                controller: weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*.?\d{0,2}')),
                                ],
                                onChanged: (value) {
                                  _calculateStatuses(); // Recalculate statuses after weight is input
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter the patient weight';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintStyle: paragraphS,
                                  hintText: 'ENTER WEIGHT: KG',
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 15,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  suffixText: 'KG',
                                  suffixStyle: paragraphS,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("ACTUAL DATE OF WEIGHING", style: paragraphS),
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
                            hintText: 'YYYY-MM-DD',
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildReadOnlyField('Weight-for-Age', weightForAge),
                    const SizedBox(height: 10),
                    _buildReadOnlyField('Height-for-Age', heightForAge),
                    const SizedBox(height: 10),
                    _buildReadOnlyField('Weight-for-Height', weightForHeight),
                    const SizedBox(height: 10),
                    _buildReadOnlyField('Nutrition Status', nutritionStatus),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            saveButtonPressed(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorBlue,
                          ),
                          child: const Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 20,
                            ),
                            child: Text(
                              "SUBMIT",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: paragraphS),
        TextFormField(
          readOnly: true,
          initialValue: value,
          decoration: const InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
