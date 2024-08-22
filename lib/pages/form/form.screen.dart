import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sjq/models/client.model.dart';
import 'package:sjq/services/user/user.service.dart';
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
  TextEditingController patientHeightController = TextEditingController();
  TextEditingController patientWeightController = TextEditingController();
  TextEditingController actualDateController = TextEditingController();
  String selectedSex = 'Male'; // Default selection
  String indigenousChild = 'No'; // Default selection

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _clearFormFields() {
    addressController.clear();
    motherNameController.clear();
    patientNameController.clear();
    patientDobController.clear();
    patientHeightController.clear();
    patientWeightController.clear();
    actualDateController.clear();
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
              textTheme: ButtonTextTheme.primary, // Button text color
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF96B0D7), // Selected date background color
            ).copyWith(secondary: const Color(0xFF96B0D7)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  Future<void> saveButtonPressed(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Gather data from text controllers
      String address = addressController.text;
      String motherName = motherNameController.text;
      String patientName = patientNameController.text;
      String patientDob = patientDobController.text;
      String patientHeight = patientHeightController.text;
      String patientSex = selectedSex;
      String patientWeight = patientWeightController.text;
      String actualDate = actualDateController.text;

      Client newClient = Client(
        id: DateTime.now().millisecondsSinceEpoch,
        guardian: motherName,
        address: address,
        name: patientName,
        age: patientDob,
        gender: patientSex,
        height: patientHeight,
        weight: patientWeight,
        actualDate: actualDate,
        indigenousChild: indigenousChild == 'Yes',
      );

      // Save user here
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
                'Date of Birth: ${newClient.age}\n'
                'Height: ${newClient.height}\n'
                'Sex: ${newClient.gender}\n'
                'Weight: ${newClient.weight}\n'
                'Actual Date of Weighing: ${newClient.actualDate}\n'
                'Indigenous Preschool Child: ${newClient.indigenousChild ? 'Yes' : 'No'}'),
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
                        fillColor: Colors.white, // Set background color to white
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 15,
                        ), // Adjust the vertical padding
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20), // Set circular border radius
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
                        fillColor: Colors.white, // Set background color to white
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 15,
                        ), // Adjust the vertical padding
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20), // Set circular border radius
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
                    const SizedBox(height:10),
                     const Text("INDIGENOUS PRESCHOOL CHILD?", style: paragraphS),
                    DropdownButtonFormField<String>(
                      value: indigenousChild,
                      onChanged: (value) {
                        setState(() {
                          indigenousChild = value!;
                        });
                      },
                      items: <String>['Yes', 'No'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        hintStyle: paragraphS,
                        hintText: 'Select Yes or No',
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
                                      hintText: 'MM/DD/YYYY',
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
                                controller: patientHeightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*.?\d{0,2}')),
                                ],
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
                                  suffixStyle: paragraphS, // Style for the 'CM' text
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
                                controller: patientWeightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*.?\d{0,2}')),
                                ],
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
                                  suffixStyle: paragraphS, // Style for the 'KG' text
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
                      onTap: () => _selectDate(context, actualDateController),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: actualDateController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select the actual date of weighing';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintStyle: paragraphS,
                            hintText: 'MM/DD/YYYY',
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
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the children horizontally
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
}
