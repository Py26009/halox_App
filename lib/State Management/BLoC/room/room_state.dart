import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class RoomData {
  final String title;
  final Color color;
  final IconData icon;

  const RoomData({
    required this.title,
    required this.color,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'color': color.value,
    'icon': icon.codePoint,
  };

  factory RoomData.fromJson(Map<String, dynamic> json) {
    try {
      final iconCodePoint = json['icon'] as int;
      IconData iconData;
      
      // Map common icon code points to their corresponding icons
      switch (iconCodePoint) {
        case 0xe1db: // bed
          iconData = Icons.bed;
          break;
        case 0xe1e0: // chair
          iconData = Icons.chair;
          break;
        case 0xe1e1: // kitchen
          iconData = Icons.kitchen;
          break;
        case 0xe1e2: // bathtub
          iconData = Icons.bathtub;
          break;
        case 0xe1e3: // computer
          iconData = Icons.computer;
          break;
        case 0xe1e4: // garage
          iconData = Icons.garage;
          break;
        case 0xe1e5: // weekend
          iconData = Icons.weekend;
          break;
        case 0xe1e6: // door_front_door
          iconData = Icons.door_front_door;
          break;
        default:
          iconData = Icons.home;
      }

      return RoomData(
        title: json['title'] as String,
        color: Color(json['color'] as int),
        icon: iconData,
      );
    } catch (e) {
      return RoomData(
        title: json['title'] as String,
        color: Color(json['color'] as int),
        icon: Icons.home,
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomData &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          color == other.color &&
          icon == other.icon;

  @override
  int get hashCode => title.hashCode ^ color.hashCode ^ icon.hashCode;
}

class RoomState extends Equatable {
  final Map<String, List<RoomData>> rooms;
  final String currentHome;
  final bool isLoading;
  final String? error;

  const RoomState({
    required this.rooms,
    required this.currentHome,
    this.isLoading = false,
    this.error,
  });

  factory RoomState.initial() {
    return const RoomState(
      rooms: {},
      currentHome: '',
    );
  }

  RoomState copyWith({
    Map<String, List<RoomData>>? rooms,
    String? currentHome,
    bool? isLoading,
    String? error,
  }) {
    return RoomState(
      rooms: rooms ?? this.rooms,
      currentHome: currentHome ?? this.currentHome,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<RoomData> get currentRooms => rooms[currentHome] ?? [];

  @override
  List<Object?> get props => [rooms, currentHome, isLoading, error];
} 