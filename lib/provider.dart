import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class MainState with ChangeNotifier, DiagnosticableTreeMixin {
  late Socket _socket;
  Socket get socket => _socket;

  void setSocket(Socket sock){
    _socket = sock;
    notifyListeners();
  }
}