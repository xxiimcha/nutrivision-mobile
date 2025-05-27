import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import '../pages/chat/call.dart';
import '../pages/call/incoming.dart';
import '../constant/constant.dart';

class CallNotifier extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? userId;
  bool _isDialogShowing = false;
  BuildContext? _context;
  Timer? _pollingTimer;
  Timer? _timeoutTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  CallNotifier() {
    _init();
  }

  Future<void> _init() async {
    debugPrint('[CallNotifier] Initializing...');
    await _retrieveUserId();
    debugPrint('[CallNotifier] Retrieved userId: $userId');
    notifyListeners();
  }

  void attachContext(BuildContext context) {
    _context = context;
    debugPrint('[CallNotifier] Context attached.');
  }

  Future<void> _retrieveUserId() async {
    userId = await _secureStorage.read(key: 'userId');
    debugPrint('[CallNotifier] SecureStorage userId: $userId');
  }

  void startPolling(BuildContext context) {
    attachContext(context);
    if (_pollingTimer != null) {
      debugPrint('[CallNotifier] Polling already running.');
      return;
    }

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_isDialogShowing || _context == null || userId == null) {
        debugPrint('[CallNotifier] Skipping polling cycle.');
        return;
      }

      debugPrint('[CallNotifier] Polling for incoming calls...');

      try {
        final response = await http.get(
          Uri.parse('$BASE_URL/calls/pending?receiverId=$userId'),
          headers: {'Content-Type': 'application/json'},
        );

        debugPrint('[CallNotifier] Call response: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final String callId = data['_id'];
          final String channelName = data['roomLink'];
          final String callerId = data['callerId'];
          final String callType = data['callType'];

          debugPrint('[CallNotifier] Incoming $callType call from $callerId');

          String callerName = callerId;
          String callerRole = 'Unknown';

          try {
            final callerRes = await http.get(
              Uri.parse('$BASE_URL/admins/$callerId'),
              headers: {'Content-Type': 'application/json'},
            );

            if (callerRes.statusCode == 200) {
              final callerData = jsonDecode(callerRes.body);
              callerName =
                  '${callerData['firstName']?.trim() ?? ''} ${callerData['lastName']?.trim() ?? ''}'.trim();
              callerRole = callerData['role'] ?? 'Admin';

              debugPrint('[CallNotifier] Caller resolved: $callerName ($callerRole)');
            } else {
              debugPrint('[CallNotifier] Failed to fetch caller details.');
            }
          } catch (e) {
            debugPrint('[CallNotifier] Caller fetch error: $e');
          }

          _isDialogShowing = true;
          _playRingtone();

          _timeoutTimer = Timer(const Duration(seconds: 20), () async {
            if (_isDialogShowing) {
              debugPrint('[CallNotifier] Call timeout - marking missed');
              _stopRingtone();
              Navigator.pop(_context!);
              await _updateCallStatus(callId, 'missed');
              resetDialogState();
            }
          });

          Navigator.of(_context!).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => CallIncomingScreen(
                callerName: callerName,
                callerRole: callerRole,
                onAccept: () async {
                  debugPrint('[CallNotifier] Call accepted.');
                  _timeoutTimer?.cancel();
                  _stopRingtone();
                  Navigator.pop(_context!);
                  await _updateCallStatus(callId, 'accepted');

                  Navigator.push(
                    _context!,
                    MaterialPageRoute(
                      builder: (_) => CallWebView(roomLink: channelName),
                    ),
                  );
                },
                onDecline: () async {
                  debugPrint('[CallNotifier] Call declined.');
                  _timeoutTimer?.cancel();
                  _stopRingtone();
                  Navigator.pop(_context!);
                  await _updateCallStatus(callId, 'declined');
                  resetDialogState();
                },
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('[CallNotifier] Polling error: $e');
      }
    });

    debugPrint('[CallNotifier] Polling started.');
  }

  void stopPolling() {
    debugPrint('[CallNotifier] Stopping polling...');
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _updateCallStatus(String callId, String status) async {
    try {
      debugPrint('[CallNotifier] Updating call $callId to $status');
      final res = await http.put(
        Uri.parse('$BASE_URL/calls/$callId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );
      debugPrint('[CallNotifier] Status update response: ${res.statusCode}');
    } catch (e) {
      debugPrint('[CallNotifier] Status update failed: $e');
    }
  }

  void showIncomingCallDialog({
    required String callerId,
    required String channelName,
    required String token,
  }) {
    if (_isDialogShowing || _context == null) return;
    _isDialogShowing = true;
    _playRingtone();

    Navigator.of(_context!).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CallIncomingScreen(
          callerName: callerId,
          callerRole: 'Video Call',
          onAccept: () {
            _stopRingtone();
            Navigator.pop(_context!);
            Navigator.push(
              _context!,
              MaterialPageRoute(
                builder: (_) => CallWebView(roomLink: channelName),
              ),
            );
          },
          onDecline: () {
            _stopRingtone();
            Navigator.pop(_context!);
            resetDialogState();
          },
        ),
      ),
    );
  }

  void resetDialogState() {
    debugPrint('[CallNotifier] Resetting dialog state.');
    _isDialogShowing = false;
  }

  void _playRingtone() async {
    try {
      debugPrint('[CallNotifier] Playing ringtone...');
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/incoming.mp3'));
    } catch (e) {
      debugPrint('[CallNotifier] Ringtone error: $e');
    }
  }

  void _stopRingtone() async {
    debugPrint('[CallNotifier] Stopping ringtone...');
    await _audioPlayer.stop();
  }

  @override
  void dispose() {
    stopPolling();
    _stopRingtone();
    super.dispose();
  }
}
