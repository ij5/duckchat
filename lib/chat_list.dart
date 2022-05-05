import 'dart:io';

import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  const ChatList({Key? key, required Socket socket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Text("Hello World!"),
    );
  }
}