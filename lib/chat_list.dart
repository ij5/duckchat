import 'dart:io';

import 'package:flutter/material.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key, required this.socket}) : super(key: key);

  final Socket socket;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  void initState(){
    super.initState();
    // widget.socket.write({
    //   'action': 'update-rooms',
    // });
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Text("Hello World!"),
    );
  }
}