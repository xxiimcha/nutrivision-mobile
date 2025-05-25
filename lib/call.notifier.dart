import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../pages/chat/call.dart'; // Your WebView for Agora call

class CallNotifier extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? userId;
  IO.Socket? socket;
  bool _isDialogShowing = false;
  BuildContext? _context;

  CallNotifier() {
    _init();
  }

  Future<void> _init() async {
    await _retrieveUserId();
    if (userId != null) {
      _initSocket();
    } else {
      debugPrint('User ID not available.');
    }
  }

  // Attach context to show dialogs later
  void attachContext(BuildContext context) {
    _context = context;
  }

  Future<void> _retrieveUserId() async {
    userId = await _secureStorage.read(key: 'userId');
    notifyListeners();
  }

  void _initSocket() {
    socket = IO.io(
      'https://nv-backend-ca1w.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket']) // important for Flutter
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      debugPrint('Socket connected: ${socket!.id}');
      socket!.emit('register-user', userId);
    });

    socket!.on('disconnect', (_) {
      debugPrint('Socket disconnected');
    });

    socket!.on('incoming-call', (data) {
      if (!_isDialogShowing && _context != null) {
        final String roomLink = data['roomLink'];
        final String callerId = data['callerId'];
        final String callType = data['callType'] ?? 'video';

        debugPrint('Incoming $callType call from $callerId');
        _isDialogShowing = true;

        showCallDialog(_context!, roomLink);
      }
    });
  }

  void resetDialogState() {
    _isDialogShowing = false;
  }

  void disposeSocket() {
    socket?.disconnect();
    socket?.destroy();
  }

  @override
  void dispose() {
    disposeSocket();
    super.dispose();
  }
}

void showCallDialog(BuildContext context, String roomLink) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Incoming Call'),
        content: const Text('You have an incoming video call.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Decline'),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CallNotifier>().resetDialogState();
            },
          ),
          ElevatedButton(
            child: const Text('Accept'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallWebView(roomLink: roomLink),
                ),
              );
            },
          ),
        ],
      );
    },
  ).then((_) {
    if (context.mounted) {
      context.read<CallNotifier>().resetDialogState();
    }
  });
}
