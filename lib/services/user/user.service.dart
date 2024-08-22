import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sjq/models/client.model.dart';

class UserService {
  // Save user form here. for now, just print them. but you can use firebase here instead
  Future<void> createEntry(Client client) async {
    Timer(const Duration(seconds: 2), () {
      debugPrint(client.toString());
    });
  }
}
