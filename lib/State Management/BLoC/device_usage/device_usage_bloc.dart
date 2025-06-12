import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'device_usage_event.dart';
import 'device_usage_state.dart';

class DeviceUsageBloc extends Bloc<DeviceUsageEvent, DeviceUsageState> {
  final SharedPreferences prefs;
  static const String _usageKey = 'device_usage_data';

  DeviceUsageBloc({required this.prefs}) : super(DeviceUsageState.initial()) {
    on<LoadDeviceUsage>(_onLoadDeviceUsage);
    on<IncrementDeviceUsage>(_onIncrementDeviceUsage);
  }

  void _onLoadDeviceUsage(LoadDeviceUsage event, Emitter<DeviceUsageState> emit) {
    try {
      final usageData = prefs.getString(_usageKey);
      if (usageData != null) {
        final Map<String, dynamic> decoded = json.decode(usageData);
        final Map<String, int> deviceUsageCount = Map<String, int>.from(decoded);
        emit(state.copyWith(deviceUsageCount: deviceUsageCount));
      } else {
        // Initialize with default devices if no data exists
        final defaultUsage = {
          'Smart Light': 1,
          'Smart Fan': 1,
          'Air Conditioner': 1,
          'Smart TV': 1,
        };
        emit(state.copyWith(deviceUsageCount: defaultUsage));
        _saveDeviceUsage(defaultUsage);
      }
    } catch (e) {
      emit(state.copyWith(deviceUsageCount: {}));
    }
  }

  void _onIncrementDeviceUsage(IncrementDeviceUsage event, Emitter<DeviceUsageState> emit) {
    final updatedUsage = Map<String, int>.from(state.deviceUsageCount);
    updatedUsage[event.deviceType] = (updatedUsage[event.deviceType] ?? 0) + 1;
    emit(state.copyWith(deviceUsageCount: updatedUsage));
    _saveDeviceUsage(updatedUsage);
  }

  void _saveDeviceUsage(Map<String, int> usage) {
    prefs.setString(_usageKey, json.encode(usage));
  }
} 