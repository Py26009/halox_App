import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'room_event.dart';
import 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final SharedPreferences prefs;
  static const String _roomsKey = 'rooms_data';

  RoomBloc({required this.prefs}) : super(RoomState.initial()) {
    on<LoadRooms>(_onLoadRooms);
    on<AddRoom>(_onAddRoom);
    on<RemoveRoom>(_onRemoveRoom);
    on<RemoveHome>(_onRemoveHome);
    on<SwitchHome>(_onSwitchHome);
    on<AddHome>(_onAddHome);
  }

  void _onLoadRooms(LoadRooms event, Emitter<RoomState> emit) {
    try {
      final roomsJson = prefs.getString(_roomsKey);
      if (roomsJson != null) {
        final Map<String, dynamic> decodedRooms = jsonDecode(roomsJson);
        final Map<String, List<RoomData>> rooms = {};
        
        decodedRooms.forEach((homeName, roomsList) {
          rooms[homeName] = (roomsList as List)
              .map((room) => RoomData.fromJson(room as Map<String, dynamic>))
              .toList();
        });

        emit(state.copyWith(
          rooms: rooms,
          currentHome: event.homeName,
        ));
      } else {
        // Initialize with empty rooms for the current home
        emit(state.copyWith(
          rooms: {event.homeName: []},
          currentHome: event.homeName,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load rooms: $e'));
    }
  }

  void _onAddRoom(AddRoom event, Emitter<RoomState> emit) {
    try {
      // Create a new map to ensure state change detection
      final updatedRooms = Map<String, List<RoomData>>.from(state.rooms);
      
      // Initialize empty list for new homes
      if (!updatedRooms.containsKey(event.homeName)) {
        updatedRooms[event.homeName] = [];
      }

      // Create new room
      final newRoom = RoomData(
        title: event.roomName,
        color: event.color,
        icon: event.icon,
      );

      // Add room to the list
      updatedRooms[event.homeName] = List<RoomData>.from(updatedRooms[event.homeName]!)..add(newRoom);

      // Save to SharedPreferences first
      final roomsJson = jsonEncode(updatedRooms.map(
        (key, value) => MapEntry(key, value.map((room) => room.toJson()).toList()),
      ));
      prefs.setString(_roomsKey, roomsJson);

      // Then emit new state
      emit(state.copyWith(
        rooms: updatedRooms,
        currentHome: event.homeName,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add room: $e'));
    }
  }

  void _onRemoveRoom(RemoveRoom event, Emitter<RoomState> emit) {
    try {
      // Create a new map to ensure state change detection
      final updatedRooms = Map<String, List<RoomData>>.from(state.rooms);
      
      if (updatedRooms.containsKey(event.homeName)) {
        // Create a new list to ensure state change detection
        final updatedRoomList = List<RoomData>.from(updatedRooms[event.homeName]!);
        updatedRoomList.removeAt(event.index);
        updatedRooms[event.homeName] = updatedRoomList;

        // Save to SharedPreferences first
        final roomsJson = jsonEncode(updatedRooms.map(
          (key, value) => MapEntry(key, value.map((room) => room.toJson()).toList()),
        ));
        prefs.setString(_roomsKey, roomsJson);

        // Then emit new state
        emit(state.copyWith(
          rooms: updatedRooms,
          currentHome: event.homeName,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to remove room: $e'));
    }
  }

  void _onRemoveHome(RemoveHome event, Emitter<RoomState> emit) {
    try {
      final updatedRooms = Map<String, List<RoomData>>.from(state.rooms);
      updatedRooms.remove(event.homeName);
      emit(state.copyWith(rooms: updatedRooms));

      // Save to SharedPreferences
      final roomsJson = jsonEncode(updatedRooms.map(
        (key, value) => MapEntry(key, value.map((room) => room.toJson()).toList()),
      ));
      prefs.setString(_roomsKey, roomsJson);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to remove home: $e'));
    }
  }

  void _onSwitchHome(SwitchHome event, Emitter<RoomState> emit) {
    try {
      final updatedRooms = Map<String, List<RoomData>>.from(state.rooms);
      if (!updatedRooms.containsKey(event.homeName)) {
        updatedRooms[event.homeName] = [];
      }
      emit(state.copyWith(
        rooms: updatedRooms,
        currentHome: event.homeName,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to switch home: $e'));
    }
  }

  void _onAddHome(AddHome event, Emitter<RoomState> emit) {
    try {
      final updatedRooms = Map<String, List<RoomData>>.from(state.rooms);
      updatedRooms[event.homeName] = [];
      
      emit(state.copyWith(
        rooms: updatedRooms,
        currentHome: event.homeName,
      ));

      // Save to SharedPreferences
      final roomsJson = jsonEncode(updatedRooms.map(
        (key, value) => MapEntry(key, value.map((room) => room.toJson()).toList()),
      ));
      prefs.setString(_roomsKey, roomsJson);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add home: $e'));
    }
  }
} 