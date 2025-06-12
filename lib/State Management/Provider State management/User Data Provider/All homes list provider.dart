import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoomData {
  final String title;
  final Color color;
  final IconData icon;

  RoomData(this.title, this.color, this.icon);
}

class RoomDataProvider extends ChangeNotifier {
  final Map<String, List<RoomData>> _homeRooms = {};

  List<RoomData> getRoomsForHome(String homeName) {
    return _homeRooms[homeName] ?? [];
  }

  void addRoom(String homeName, RoomData room) {
    if (!_homeRooms.containsKey(homeName)) {
      _homeRooms[homeName] = [];
    }
    _homeRooms[homeName]!.add(room);
    notifyListeners();
  }

  void removeRoom(String homeName, int index) {
    if (_homeRooms.containsKey(homeName)) {
      _homeRooms[homeName]!.removeAt(index);
      notifyListeners();
    }
  }

  void removeHome(String homeName) {
    _homeRooms.remove(homeName);
    notifyListeners();
  }
}

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