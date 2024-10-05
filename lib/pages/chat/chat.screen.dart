import 'package:flutter/material.dart';
import 'package:sjq/services/chat/chat.service.dart';
import 'package:sjq/models/message.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatService chatService = ChatService();
  
  // Initialize messages with an empty Future
  Future<List<Message>> messages = Future.value([]); 
  String? loggedInUserId;

  @override
  void initState() {
    super.initState();
    _loadLoggedInUserId();
  }

  // Load logged-in user ID from SharedPreferences
  Future<void> _loadLoggedInUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUserId = prefs.getString('userId');
      if (loggedInUserId != null) {
        messages = chatService.getMessages(loggedInUserId!); // Fetch messages for the logged-in user
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Message>>(
                future: messages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading messages'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No messages available'));
                  } else {
                    final messageList = snapshot.data!;
                    return ListView.builder(
                      itemCount: messageList.length,
                      itemBuilder: (context, index) {
                        final message = messageList[index];
                        return ListTile(
                          title: Text(message.text),
                          subtitle: Text('Sender: ${message.sender}, Receiver: ${message.receiver}'),
                          trailing: Text(message.timestamp),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
