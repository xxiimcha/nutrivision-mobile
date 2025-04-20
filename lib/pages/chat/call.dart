import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class CallWebView extends StatefulWidget {
  final String roomLink;

  const CallWebView({required this.roomLink, super.key});

  @override
  State<CallWebView> createState() => _CallWebViewState();
}

class _CallWebViewState extends State<CallWebView> {
  late InAppWebViewController webViewController;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request camera and microphone permissions
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Room'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(Uri.parse(widget.roomLink).toString()), // Use WebUri here
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          webViewController = controller;
        },
        onPermissionRequest: (InAppWebViewController controller, PermissionRequest permissionRequest) async {
          // Request camera and microphone permissions if they are not granted
          final cameraStatus = await Permission.camera.request();
          final microphoneStatus = await Permission.microphone.request();

          // Check if both permissions are granted
          bool isGranted = cameraStatus.isGranted && microphoneStatus.isGranted;

          // Return response based on updated permission status using PermissionResponse
          return PermissionResponse(
            resources: permissionRequest.resources,
            action: isGranted ? PermissionResponseAction.GRANT : PermissionResponseAction.DENY,
          );
        },
      ),
    );
  }
}
