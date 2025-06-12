import 'package:flutter/material.dart';
import 'package:halox_app/App_Screens/Home Bottom Nav Screens/Specific room Screen.dart';

class ScheduleTickProvider with ChangeNotifier {
  final Map<String, List<DeviceData>> _roomDevices = {};

  List<DeviceData> getDevicesForRoom(String roomKey) {
    return _roomDevices[roomKey] ?? [];
  }

  void setDevicesForRoom(String roomKey, List<DeviceData> devices) {
    _roomDevices[roomKey] = List.from(devices);
    notifyListeners();
  }

  void addDevice(String roomKey, DeviceData device) {
    final devices = _roomDevices[roomKey] ?? [];
    devices.add(device);
    _roomDevices[roomKey] = devices;
    notifyListeners();
  }

  void updateDevice(String roomKey, DeviceData device) {
    final devices = _roomDevices[roomKey] ?? [];
    final index = devices.indexWhere((d) => d.name == device.name);
    if (index != -1) {
      devices[index] = device;
      _roomDevices[roomKey] = devices;
      notifyListeners();
    }
  }

  void removeDevice(String roomKey, String deviceName) {
    final devices = _roomDevices[roomKey] ?? [];
    devices.removeWhere((d) => d.name == deviceName);
    _roomDevices[roomKey] = devices;
    notifyListeners();
  }

  void clearRoomDevices(String roomKey) {
    _roomDevices.remove(roomKey);
    notifyListeners();
  }
} 