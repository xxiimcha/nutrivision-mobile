import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sjq/models/contact.model.dart';

class ChatService {
  Future<List<Contact>> getContacts(String nameQuery) async {
    final jsonString = await rootBundle.loadString('assets/data/contacts.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    late List<Contact> contacts;
    final completer = Completer<List<Contact>>();

    // Create a Timer to complete the Completer after the random delay
    //  This is just to show loading screen
    // Generate a random duration between 0 and 1 seconds
    final random = Random();
    const maxSeconds = 2;
    final delaySeconds = random.nextInt(maxSeconds + 1);

    Timer(Duration(seconds: delaySeconds), () {
      contacts = jsonList.map((json) => Contact.fromJson(json)).toList();
      if (nameQuery.isNotEmpty) {
        debugPrint(nameQuery);
        contacts = contacts
            .where((contact) =>
                contact.name.toLowerCase().contains(nameQuery.toLowerCase()))
            .toList();
      }
      debugPrint('Contacts: ${contacts.toSet()}');
      completer.complete(contacts);
    });

    return completer.future;
  }
}
