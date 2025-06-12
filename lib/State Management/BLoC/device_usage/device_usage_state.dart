import 'package:equatable/equatable.dart';

class DeviceUsageState extends Equatable {
  final Map<String, int> deviceUsageCount;

  const DeviceUsageState({
    this.deviceUsageCount = const {},
  });

  factory DeviceUsageState.initial() {
    return const DeviceUsageState();
  }

  DeviceUsageState copyWith({
    Map<String, int>? deviceUsageCount,
  }) {
    return DeviceUsageState(
      deviceUsageCount: deviceUsageCount ?? this.deviceUsageCount,
    );
  }

  @override
  List<Object?> get props => [deviceUsageCount];
} 