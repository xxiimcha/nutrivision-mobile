import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatelessWidget {
  final String roomUrl;

  WebViewContainer({required this.roomUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Join Call")),
      body: WebView(
        initialUrl: roomUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
