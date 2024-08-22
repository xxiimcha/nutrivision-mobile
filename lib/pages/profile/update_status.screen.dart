import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter
import 'package:sjq/navigator.dart';

class UpdateStatusScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const UpdateStatusScreen({Key? key});

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  final TextEditingController patientHeightController = TextEditingController();
  final TextEditingController patientWeightController = TextEditingController();

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

  void showInvalidInputAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Invalid Input"),
          content: const Text("Please enter digits only."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutritional Status"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 150),
              const Padding(
                padding: EdgeInsets.only(left: 0),
                child: Text(
                  'Update your status',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF96B0D7),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("PATIENT HEIGHT"),
                      TextField(
                        controller: patientHeightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) {
                          if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                            showInvalidInputAlert(context);
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'ENTER HEIGHT',
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
                          suffixStyle: TextStyle(
                            fontSize: 16, // Adjust the font size if necessary
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("PATIENT WEIGHT"),
                      TextField(
                        controller: patientWeightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) {
                          if (!RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                            showInvalidInputAlert(context);
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'ENTER WEIGHT',
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
                          suffixStyle: TextStyle(
                            fontSize: 16, // Adjust the font size if necessary
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: 130, // Adjust the width as needed
                          child: ElevatedButton(
                            onPressed: () {
                              saveChanges(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            ),
                            child: const Text(
                              "SAVE",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
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
