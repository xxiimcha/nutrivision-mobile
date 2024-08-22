import 'package:flutter/material.dart';
import 'package:sjq/themes/themes.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification", style: headingM),
        backgroundColor: colorLightBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Today', style: headingM),
              ),
              MessageItemNotification(
                message: "Aliah Ann Bribon replied to your message.",
                time: "30 mins ago",
              ),
              MessageItemNotification(
                message: "Yoon Jeonghan replied to your message",
                time: "1 hour ago",
              ),
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Yesterday', style: headingM)),
              MessageItemNotification(
                message: "Admin changed the meal for April 04.",
                time: "Mon at 10:00 AM",
              ),
              MessageItemNotification(
                message: "Yoon Jeonghan replied to your message",
                time: "Mon at 7:00 AM",
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('March 10', style: headingM),
              ),
              MessageItemNotification(
                message: "Admin changed the meal for April 04.",
                time: "Sun at 10:30 AM",
              ),
              MessageItemNotification(
                message: "Yoon Jeonghan replied to your message",
                time: "Sun at 10:00 AM",
              ),
              MessageItemNotification(
                message: "Admin updated the meal for May.",
                time: "Sun at 9:30 AM",
              ),
              MessageItemNotification(
                message: "Yoon Jeonghan replied to your message",
                time: "Sun at 8:00 AM",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageItemNotification extends StatelessWidget {
  final String message;
  final String time;

  const MessageItemNotification({
    super.key,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(message, style: paragraphM),
      subtitle: Text(time, style: paragraphS),
    );
  }
}
