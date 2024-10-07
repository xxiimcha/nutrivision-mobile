import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TelemedMobile extends StatefulWidget {
  final String userId;

  TelemedMobile({required this.userId});

  @override
  _TelemedMobileState createState() => _TelemedMobileState();
}

class _TelemedMobileState extends State<TelemedMobile> {
  IO.Socket? socket;
  String? roomUrl;

  @override
  void initState() {
    super.initState();
    socket = IO.io('http://localhost:5000', IO.OptionBuilder().setTransports(['websocket']).build());

    socket!.emit('register-user', widget.userId);

    socket!.on('incoming-call', (data) {
      setState(() {
        roomUrl = data['roomUrl'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Telemedicine")),
      body: roomUrl != null
          ? WebView(
              initialUrl: roomUrl,
              javascriptMode: JavascriptMode.unrestricted,
            )
          : Center(child: Text('No incoming calls')),
    );
  }
}
