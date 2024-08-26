import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    MaterialApp(
      home: ChatPage(),
    ),
  );
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<MessageItem> items = [];
  List<MessageItem> filteredItems = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/users'));

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = json.decode(response.body);
      setState(() {
        items = usersJson.map((userJson) => MessageItem(userJson['name'], 'Start conversation')).toList();
        filteredItems = items;
      });
    } else {
      print('Failed to load users');
    }
  }

  void filterList(String query) {
    setState(() {
      filteredItems = items
          .where((item) => item.sender.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                height: 40,
                width: 700,
                decoration: BoxDecoration(
                  color: const Color(0xFF96B0D7),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.white, fontSize: 19),
                          border: InputBorder.none,
                        ),
                        onChanged: filterList,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      userName: item.getSender(),
                                    ),
                                  ),
                                );
                              },
                              splashColor: Colors.white.withOpacity(0.4),
                              child: ListTile(
                                title: item.buildTitle(context),
                                subtitle: item.buildSubtitle(context),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract class ListItem {
  Widget buildTitle(BuildContext context);
  Widget buildSubtitle(BuildContext context);
}

class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);

  String getSender() => sender;

  @override
  Widget buildTitle(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          child: Icon(Icons.account_circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget buildSubtitle(BuildContext context) => const SizedBox.shrink();
}

class ChatScreen extends StatefulWidget {
  final String userName;

  const ChatScreen({super.key, required this.userName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> chatMessages = [];

  void _sendMessage() {
    String message = _messageController.text;
    setState(() {
      chatMessages.add(ChatMessage(
        sender: widget.userName,
        message: message,
        isMe: true,
      ));
    });
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
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
                              ? const Color.fromARGB(255, 202, 202, 202)
                              : const Color.fromARGB(255, 158, 158, 158),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          message.message,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
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

  ChatMessage({
    required this.sender,
    required this.message,
    required this.isMe,
  });
}
