import 'dart:typed_data';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:dsgo/chat_list.dart';
import 'package:dsgo/friends.dart';
import 'package:dsgo/settings.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

enum _SelectedTab {friends, chat, settings}

class _HomeState extends State<Home> {
  late Socket socket;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> run() async {
    final SharedPreferences prefs = await _prefs;
    socket = await Socket.connect("10.42.0.1", 1818);
    print("Connected to: ${socket.remoteAddress.address}:${socket.remotePort}");
    socket.listen((Uint8List data){

    }, onError: (error){
      print(error);
      socket.destroy();
    }, onDone: (){
      print("server left.");
      socket.destroy();
    });

    var token = prefs.getString("token");
    if(token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    socket.write({
      'action': 'init'
    });

    setState(() {
      screens = [
        const Friends(),
        ChatList(socket: socket),
        const Settings(),
      ];  
    });
  }

  @override
  void initState(){
    run();
    super.initState();
  }

  late var _selectedTab = _SelectedTab.chat;
  
  List<Widget>? screens;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: DotNavigationBar(
        currentIndex: _SelectedTab.values.indexOf(_selectedTab),
        dotIndicatorColor: Colors.black,
        unselectedItemColor: Colors.grey[300],
        enablePaddingAnimation: false,
        onTap: (i){
          setState(() {
            _selectedTab = _SelectedTab.values[i];
          });
        },
        items: [
          DotNavigationBarItem(
            icon: const Icon(Icons.people),
            selectedColor: const Color.fromARGB(255, 92, 94, 255),
          ),
          DotNavigationBarItem(
            icon: const Icon(Icons.home_filled),
            selectedColor: const Color.fromARGB(255, 52, 72, 255),
          ),
          DotNavigationBarItem(
            icon: const Icon(Icons.settings),
            selectedColor: const Color.fromARGB(255, 235, 19, 255),
          )
        ],
      ),
      body: screens?[_selectedTab.index],
    );
  }
}