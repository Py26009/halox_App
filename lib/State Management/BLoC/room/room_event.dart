import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadRooms extends RoomEvent {
  final String homeName;

  const LoadRooms(this.homeName);

  @override
  List<Object?> get props => [homeName];
}

class AddRoom extends RoomEvent {
  final String homeName;
  final String roomName;
  final Color color;
  final IconData icon;

  const AddRoom({
    required this.homeName,
    required this.roomName,
    required this.color,
    required this.icon,
  });

  @override
  List<Object?> get props => [homeName, roomName, color, icon];
}

class RemoveRoom extends RoomEvent {
  final String homeName;
  final int index;

  const RemoveRoom({
    required this.homeName,
    required this.index,
  });

  @override
  List<Object?> get props => [homeName, index];
}

class RemoveHome extends RoomEvent {
  final String homeName;

  const RemoveHome(this.homeName);

  @override
  List<Object?> get props => [homeName];
}

class SwitchHome extends RoomEvent {
  final String homeName;

  const SwitchHome(this.homeName);

  @override
  List<Object?> get props => [homeName];
}

class AddHome extends RoomEvent {
  final String homeName;

  const AddHome(this.homeName);

  @override
  List<Object?> get props => [homeName];
} 