import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'call_page.dart';

class CallIncomingScreen extends StatefulWidget {
  final String callerName;
  final String callerRole;
  final String channelName;
  final String token;

  const CallIncomingScreen({
    super.key,
    required this.callerName,
    required this.callerRole,
    required this.channelName,
    required this.token,
  });

  @override
  State<CallIncomingScreen> createState() => _CallIncomingScreenState();
}

class _CallIncomingScreenState extends State<CallIncomingScreen>
    with TickerProviderStateMixin {
  late AnimationController _namePulseController;
  late AnimationController _buttonScaleController;

  final String apiUrl = 'https://your-api.com/api/calls/status'; // ✅ Replace this

  @override
  void initState() {
    super.initState();

    _namePulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _namePulseController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  Future<void> _sendDeclineSignal() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'channelName': widget.channelName,
          'status': 'declined',
          // Optionally add userId if needed by your API
        }),
      );
      debugPrint('✅ Decline signal sent: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ Failed to send decline signal: $e');
    }
  }

  void _onAcceptCall() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CallPage(
          channelName: widget.channelName,
          token: widget.token,
        ),
      ),
    );
  }

  void _onDeclineCall() async {
    await _sendDeclineSignal();
    Navigator.pop(context); // dismiss the screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white10,
              child: Icon(Icons.person, size: 60, color: Colors.white70),
            ),
            const SizedBox(height: 30),

            // Pulsing Caller Name
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.05).animate(
                CurvedAnimation(parent: _namePulseController, curve: Curves.easeInOut),
              ),
              child: Text(
                widget.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 10),
            Text(
              widget.callerRole,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Decline button
                ScaleTransition(
                  scale: _buttonScaleController,
                  child: FloatingActionButton(
                    heroTag: 'decline',
                    backgroundColor: Colors.red,
                    onPressed: _onDeclineCall,
                    child: const Icon(Icons.call_end, size: 30),
                  ),
                ),

                // Accept button
                ScaleTransition(
                  scale: _buttonScaleController,
                  child: FloatingActionButton(
                    heroTag: 'accept',
                    backgroundColor: Colors.green,
                    onPressed: _onAcceptCall,
                    child: const Icon(Icons.call, size: 30),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
