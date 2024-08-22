import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: ChatPage(
        items: [
          MessageItem(
            'Aliah Ann Bribon',
            'Start conversation',
          ),
          MessageItem(
            'Karylle Corpuz',
            'Start conversation',
          ),
          MessageItem(
            'Ervin Fajardo',
            'Start conversation',
          ),
          MessageItem(
            'Patrick Marcelino',
            'Start conversation',
          ),
           MessageItem(
            'Choi Seungcheol',
            'Start conversation',
          ),
          MessageItem(
            'Yoon Jeonghan',
            'Start conversation',
          ),
          MessageItem(
            'Hong Jisoo',
            'Start conversation',
          ),
          MessageItem(
            'Moon Junhui',
            'Start conversation',
          ),
          MessageItem(
            'Kwon Soonyoung',
            'Start conversation',
          ),
          MessageItem(
            'Jeon Wonwoo',
            'Start conversation',
          ),
          MessageItem(
            'Lee Jihoon',
            'Start conversation',
          ),
          MessageItem(
            'Xu Myungho',
            'Start conversation',
          ),
          MessageItem(
            'Kim Mingyu',
            'Start conversation',
          ),
          MessageItem(
            'Lee Seokmin',
            'Start conversation',
          ),
          MessageItem(
            'Boo Seungkwan',
            'Start conversation',
          ),
          MessageItem(
            'Chwe Hansol',
            'Start conversation',
          ),
          MessageItem(
            'Lee Chan',
            'Start conversation',
          ),
        ],
      ),
    ),
  );
}

class ChatPage extends StatefulWidget {
  final List<ListItem> items;

  const ChatPage({super.key, required this.items});

  @override
  // ignore: library_private_types_in_public_api
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late List<ListItem> filteredItems;

  @override
  void initState() {
    filteredItems = widget.items;
    super.initState();
  }

  void filterList(String query) {
    setState(() {
      filteredItems = widget.items
          .where((item) => (item as MessageItem)
              .sender
              .toLowerCase()
              .contains(query.toLowerCase()))
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10), // Adjust horizontal padding here
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Align vertically
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                          hintText: 'Search',
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 19),
                          border: InputBorder.none,
                        ),
                        onChanged: filterList,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8), // Add space below the search container
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
                                // Handle tap to navigate to chat screen for selected user
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      userName:
                                          (item as MessageItem).getSender(),
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
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
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
        padding: const EdgeInsets.all(8.0),
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
                              ? const Color.fromARGB(255, 202, 202, 202)
                              : const Color.fromARGB(255, 158, 158, 158),
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
