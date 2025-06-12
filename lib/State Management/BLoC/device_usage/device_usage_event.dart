import 'package:equatable/equatable.dart';

abstract class DeviceUsageEvent extends Equatable {
  const DeviceUsageEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeviceUsage extends DeviceUsageEvent {}

class IncrementDeviceUsage extends DeviceUsageEvent {
  final String deviceType;

  const IncrementDeviceUsage(this.deviceType);

  @override
  List<Object?> get props => [deviceType];
} 