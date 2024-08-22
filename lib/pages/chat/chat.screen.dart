import 'package:flutter/material.dart';
import 'package:sjq/models/contact.model.dart';
import 'package:sjq/pages/chat/_contact_list.dart';
import 'package:sjq/services/chat/chat.service.dart';
import 'package:sjq/themes/color.dart';
import 'package:sjq/themes/typography.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final formKey = GlobalKey<FormState>();
  ChatService chatService = ChatService();
  TextEditingController searchController = TextEditingController();
  late Future<List<Contact>> contacts;

  @override
  void initState() {
    super.initState();
    contacts = chatService.getContacts("");
  }

  onSearchQuery(String text) {
    setState(() {
      contacts = chatService.getContacts(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorLightBlue,
        title: const Text("TELEMEDECINE", style: headingS),
        centerTitle: true,
        elevation: 3,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 8), // Adjust horizontal padding here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8), // Add space above the search container
              Container(
                height: 40,
                width: 700,
                decoration: BoxDecoration(
                  color: const Color(0xFF96B0D7),
                  borderRadius: BorderRadius.circular(20), // Circular edges
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          controller: searchController,
                          style: paragraphM.copyWith(color: Colors.white),
                          onChanged: onSearchQuery,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            hintText: 'Search',
                            hintStyle: paragraphL.copyWith(color: Colors.white),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8), // Add space below the search container
              Expanded(
                child: ContactListViewer(
                  contacts: contacts,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String userName;

  const ChatScreen({super.key, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> chatMessages = []; // List to hold chat messages

  void _sendMessage() {
    String message = _messageController.text;
    setState(() {
      chatMessages.add(ChatMessage(
        // Append the new message at the end of the list
        sender: widget.userName,
        message: message,
        isMe: true, // Set the message sender as the current user
      ));
    });
    // Clear the text field after sending the message
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF96B0D7),
        title: Row(
          children: [
            const CircleAvatar(
              child: Icon(Icons.account_circle),
            ),
            const SizedBox(width: 8),
            Text(widget.userName),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // Reverse the ListView to start from the bottom
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final reversedIndex = chatMessages.length - 1 - index;
                  final message = chatMessages[reversedIndex];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Align(
                      alignment: message.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: message.isMe
                              ? const Color.fromARGB(255, 0, 167, 22)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(message.message,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0))),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String message;
  final bool isMe;

  ChatMessage(
      {required this.sender, required this.message, required this.isMe});
}
