import 'package:flutter/material.dart';
import 'package:sjq/services/chat/chat.service.dart';
import 'package:sjq/models/contact.model.dart';

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
    contacts = chatService.getContacts(); // Fetch contacts from the backend
  }

  onSearchQuery(String text) {
    setState(() {
      contacts = chatService.getContacts(); // Re-fetch contacts with search query
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TELEMEDICINE", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (text) => onSearchQuery(text),
              ),
            ),

            // Display the contact list
            Expanded(
              child: FutureBuilder<List<Contact>>(
                future: contacts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading contacts'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No contacts available'));
                  } else {
                    final contactList = snapshot.data!;
                    return ListView.builder(
                      itemCount: contactList.length,
                      itemBuilder: (context, index) {
                        final contact = contactList[index];
                        return ListTile(
                          title: Text(contact.name),
                          subtitle: Text("HELLO"),
                          onTap: () {
                            // Navigate to chat screen with selected contact
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  userName: contact.name, // Pass the contact name to ChatScreen
                                ),
                              ),
                            );
                          },
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

// ChatScreen to display the chat with the selected contact
class ChatScreen extends StatelessWidget {
  final String userName; // Passed from the ContactList

  const ChatScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName), // Display the contact's name
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                // Display chat messages here
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Conversation will appear here'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Handle sending message
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
