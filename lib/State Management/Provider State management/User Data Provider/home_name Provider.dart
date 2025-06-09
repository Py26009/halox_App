import 'package:flutter/cupertino.dart';

class HomeNameProvider with ChangeNotifier {
  String _homeName = "Default Home";

  String get homeName => _homeName;

  void setHomeName(String name) {
    _homeName = name;
    notifyListeners();
  }
}