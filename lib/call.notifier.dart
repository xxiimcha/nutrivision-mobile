import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sjq/constant/constant.dart';
import 'dart:convert'; // For decoding the JSON response
import 'pages/chat/call.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Add this for secure storage

class CallNotifier extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Instance of secure storage
  String? userId; // User ID will be retrieved from storage
  Timer? _pollingTimer;
  bool _isDialogShowing = false; // Track the dialog state

  CallNotifier() {
    _retrieveUserId(); // Fetch user ID upon initialization
  }

  // Method to retrieve the user ID from storage
  Future<void> _retrieveUserId() async {
    userId = await _secureStorage.read(key: 'userId'); // Adjust key as needed
    notifyListeners(); // Notify listeners that userId has been updated
  }

  Future<void> startPolling(BuildContext context) async {
    // Wait for userId to be retrieved
    await _retrieveUserId();

    if (userId == null) {
      debugPrint('User ID is not available. Polling cannot start.');
      return;
    }

    debugPrint('Polling started for user: $userId');

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_isDialogShowing) return;

      final incomingCall = await checkForIncomingCall(userId!);

      if (incomingCall != null && incomingCall.containsKey('roomLink')) {
        final String roomLink = incomingCall['roomLink']!;
        final String callId = incomingCall['_id'];
        debugPrint('Room link fetched: $roomLink');
        
        // Check if the context is still mounted before showing the dialog
        if (context.mounted) {
          showCallDialog(context, roomLink, callId);
          _isDialogShowing = true;
        }
      }
    });
  }

  // Function to call the API and check for incoming calls
  Future<Map<String, dynamic>?> checkForIncomingCall(String userId) async {
    try {
      final response = await http.get(Uri.parse('$BASE_URL/calls/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> calls = json.decode(response.body);
        if (calls.isNotEmpty) {
          return calls.first; // Return the first call
        }
      } else {
        debugPrint('Error fetching calls: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error making API request: $e');
    }

    return null; // Return null if no calls found or an error occurred
  }

  // Stop polling when necessary
  void stopPolling() {
    debugPrint('Polling stopped for user: $userId');
    _pollingTimer?.cancel();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  // Reset the flag when the dialog is dismissed
  void resetDialogState() {
    _isDialogShowing = false;
  }
}

// Function to update the call status
Future<bool> updateCallStatus(String callId, String status) async {
  try {
    final response = await http.post(
      Uri.parse('$BASE_URL/calls/$callId/status'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('Call status updated to $status');
      return true;
    } else {
      debugPrint('Failed to update call status: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error updating call status: $e');
  }

  return false; // Return false if the status update failed
}

void showCallDialog(BuildContext context, String roomLink, String callId) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Incoming Call'),
        content: const Text('You have an incoming call.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Decline'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              debugPrint('Call Declined');
              bool success = await updateCallStatus(callId, 'declined');
              if (success) {
                // Wait for the dialog to close completely before restarting polling
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (context.mounted) { // Check if the context is still valid
                    final callNotifier = context.read<CallNotifier>();
                    callNotifier.resetDialogState(); // Reset the dialog flag
                    callNotifier.startPolling(context); // Restart polling with context
                  }
                });
              }
            },
          ),
          ElevatedButton(
            child: const Text('Accept'),
            onPressed: () async {
              bool statusUpdated = await updateCallStatus(callId, 'accepted');

              if (statusUpdated) {
                Navigator.of(context).pop(); // Close the dialog
                // Open the call room link in WebView
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallWebView(roomLink: roomLink),
                  ),
                );
              } else {
                debugPrint('Failed to update call status.');
              }
            },
          ),
        ],
      );
    },
  ).then((_) {
    if (context.mounted) { // Ensure context is valid
      final callNotifier = context.read<CallNotifier>();
      callNotifier.resetDialogState(); // Reset the dialog flag when dialog is closed
    }
  });
}
