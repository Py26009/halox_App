import 'package:flutter/cupertino.dart';

class HomeListProvider extends ChangeNotifier {
  List<String> _homeList = [];

  List<String> get homeList => _homeList;

  void addHome(String homeName) {
    _homeList.add(homeName);
    notifyListeners();
  }

  void setInitialHome(String homeName) {
    if (!_homeList.contains(homeName)) {
      _homeList.insert(0, homeName); // Ensure it's first
      notifyListeners();
    }
  }
  void removeHome(String homeName) {
    _homeList.remove(homeName);
    notifyListeners();
  }
}