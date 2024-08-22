import 'package:flutter/material.dart';
import 'package:sjq/models/contact.model.dart';
import 'package:sjq/navigator.dart';
import 'package:sjq/pages/pages.dart';
import 'package:sjq/themes/themes.dart';

class ContactListViewer extends StatelessWidget {
  const ContactListViewer({super.key, required this.contacts});
  final Future<List<Contact>> contacts;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Contact>>(
      future: contacts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No Contacts'),
            );
          }
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ContactCard(contact: snapshot.data![index]);
              });
        }
      },
    );
  }
}

class ContactCard extends StatelessWidget {
  const ContactCard({
    super.key,
    required this.contact,
  });

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorBlue),
      ),
      child: ListTile(
        onTap: () {
          AppNavigator().to(context, ChatScreen(userName: contact.name));
        },
        leading: const CircleAvatar(
          child: Icon(Icons.account_circle),
        ),
        title: Text(contact.name, style: paragraphL),
        subtitle: const Text("Start conversation", style: paragraphS),
      ),
    );
  }
}
