import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../App_Utilities/app_utilities.dart';
import '../../State Management/BLoC/room/room_event.dart';
import '../../State Management/BLoC/room/room_state.dart';
import '../../State Management/Provider State management/User Data Provider/All homes list provider.dart';
import '../../State Management/Provider State management/User Data Provider/home_name Provider.dart';
import '../../State Management/BLoC/room/room_bloc.dart';
import '../../State Management/BLoC/device_usage/device_usage_bloc.dart';
import '../../State Management/BLoC/device_usage/device_usage_state.dart';
import '../../State Management/BLoC/device_usage/device_usage_event.dart';
import '../../State Management/Provider State management/User Data Provider/Device Provider.dart';
import 'Specific room Screen.dart';

/// FirstScreen is the main screen that displays all rooms in the current home.
/// It provides functionality to:
/// - View all rooms in a grid layout
/// - Add new rooms
/// - Control devices in rooms
/// - Manage room settings
class FirstScreen extends StatefulWidget {
  /// The name of the current home being displayed
  final String homeName;
  
  /// The name of the current user
  final String userName;
  
  FirstScreen({required this.homeName, required this.userName});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  /// Controller for home name input in add home dialog
  TextEditingController hName = TextEditingController();
  
  /// Error text for home name validation
  String? errorText;

  /// Currently selected device type filter
  String? selectedDeviceFilter;

  /// Map of device types with their icons and colors
  final Map<String, Map<String, dynamic>> deviceTypes = {
    'All Devices': {
      'icon': Icons.devices,
      'color': Colors.blue,
    },
    'Smart Light': {
      'icon': Icons.lightbulb_outline,
      'color': Colors.amber,
    },
    'Smart Fan': {
      'icon': Icons.air,
      'color': Colors.blue,
    },
    'Air Conditioner': {
      'icon': Icons.ac_unit,
      'color': Colors.lightBlue,
    },
    'Smart TV': {
      'icon': Icons.tv,
      'color': Colors.black,
    },
    'Smart Speaker': {
      'icon': Icons.speaker,
      'color': Colors.purple,
    },
    'Smart Plug': {
      'icon': Icons.power,
      'color': Colors.green,
    },
    'Smart Lock': {
      'icon': Icons.lock,
      'color': Colors.brown,
    },
    'Security Camera': {
      'icon': Icons.videocam,
      'color': Colors.red,
    },
    'Thermostat': {
      'icon': Icons.thermostat,
      'color': Colors.orange,
    },
    'Smart Curtains': {
      'icon': Icons.curtains,
      'color': Colors.indigo,
    },
  };

  @override
  void initState() {
    super.initState();
    // Initialize home name and load rooms when screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HomeNameProvider>(context, listen: false);
      final homeListProvider = Provider.of<HomeListProvider>(context, listen: false);
      provider.setHomeName(widget.homeName);
      homeListProvider.setInitialHome(widget.homeName);
      
      // Load rooms for the initial home
      context.read<RoomBloc>().add(LoadRooms(widget.homeName));
    });
  }

  /// Shows a dropdown menu of available homes for switching
  void _showHomeDropdown() {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    final homeList = Provider.of<HomeListProvider>(context, listen: false).homeList;
    final homeNameProvider = Provider.of<HomeNameProvider>(context, listen: false);

    OverlayEntry? entry;
    bool isRemoved = false;

    entry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          if (!isRemoved) {
            entry?.remove();
            isRemoved = true;
          }
        },
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              top: offset.dy + 60,
              right: 80,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: homeList.map((home) {
                      return ListTile(
                        title: Text(home),
                        onTap: () {
                          homeNameProvider.setHomeName(home);
                          context.read<RoomBloc>().add(SwitchHome(home));
                          if (!isRemoved) {
                            entry?.remove();
                            isRemoved = true;
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(entry);
  }

  /// Action menu
  OverlayEntry? _menuOverlay;

  void _toggleTopMenu() {
    if (_menuOverlay != null) {
      _menuOverlay!.remove();
      _menuOverlay = null;
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _menuOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _menuOverlay?.remove();
          _menuOverlay = null;
        },
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),

            Positioned(
              top: offset.dy + 60,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _menuItem("Add Home", () {
                        _menuOverlay?.remove();
                        _menuOverlay = null;
                        _showAddHomeDialog();
                      }),
                      const Divider(height: 1),
                      _menuItem("Delete Home", () {
                        _menuOverlay?.remove();
                        _menuOverlay = null;
                        _showDeleteHomeDialog();
                      }),
                      _menuItem("Filter", () {
                        _menuOverlay?.remove();
                        _menuOverlay = null;
                        _showFilterDialog();
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_menuOverlay!);
  }

  void _showAddHomeDialog() {
    setState(() {
      errorText = null; // Reset error text
      hName.clear(); // Clear the text field
    });

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: Text("Name your new home"),
                  content: TextField(
                    controller: hName,
                    decoration: InputDecoration(
                      errorText: errorText,
                      hintText: "Enter home name",
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black12, width: 2),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String newHomeName = hName.text.trim();
                        if (newHomeName.isEmpty) {
                          setDialogState(() {
                            errorText = "This is required";
                          });
                        } else {
                          final homeListProvider = Provider.of<HomeListProvider>(context, listen: false);
                          final homeNameProvider = Provider.of<HomeNameProvider>(context, listen: false);
                          final roomBloc = context.read<RoomBloc>();

                          // Check if home already exists
                          if (homeListProvider.homeList.contains(newHomeName)) {
                            setDialogState(() {
                              errorText = "Home with this name already exists";
                            });
                          } else {
                            // Add new home to the list
                            homeListProvider.addHome(newHomeName);
                            roomBloc.add(AddHome(newHomeName));

                            print("New Home Name: $newHomeName");
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("New home added successfully"))
                            );
                            Navigator.of(context).pop(); // Close dialog
                            setState(() {}); // Refresh UI
                          }
                        }
                      },
                      child: Text("Save"),
                    ),
                  ],
                  titleTextStyle: mTextStyle16(mColor: Colors.black),
                );
              }
          );
        }
    );
  }

  void _showDeleteHomeDialog() {
    final homeListProvider = Provider.of<HomeListProvider>(context, listen: false);
    final roomBloc = context.read<RoomBloc>();

    if (homeListProvider.homeList.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete the last home'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final homeNameProvider = Provider.of<HomeNameProvider>(context, listen: false);
    String currentHome = homeNameProvider.homeName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Home'),
          content: Text('Are you sure you want to delete "$currentHome"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCurrentHome();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCurrentHome() {
    final homeListProvider = Provider.of<HomeListProvider>(context, listen: false);
    final homeNameProvider = Provider.of<HomeNameProvider>(context, listen: false);
    final roomBloc = context.read<RoomBloc>();
    String deletedHome = homeNameProvider.homeName;

    // Remove from providers
    homeListProvider.removeHome(deletedHome);
    roomBloc.add(RemoveHome(deletedHome));

    // Set new current home (first available home)
    if (homeListProvider.homeList.isNotEmpty) {
      String newCurrentHome = homeListProvider.homeList.first;
      homeNameProvider.setHomeName(newCurrentHome);
      roomBloc.add(SwitchHome(newCurrentHome));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$deletedHome has been deleted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _menuItem(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }

  /// Shows a bottom sheet with available room types for adding a new room
  void _showRoomOptions(BuildContext context) {
    /// Map of room types with their respective icons and colors
    final Map<String, Map<String, dynamic>> roomOptions = {
      'Bedroom': {
        'icon': Icons.bed,
        'color': Color(0xFF7C4DFF), // Vibrant purple
      },
      'Living Room': {
        'icon': Icons.chair,
        'color': Color(0xFF00BFA5), // Vibrant teal
      },
      'Kitchen': {
        'icon': Icons.kitchen,
        'color': Color(0xFFFF6B6B), // Vibrant coral
      },
      'Bathroom': {
        'icon': Icons.bathtub,
        'color': Color(0xFF4FC3F7), // Vibrant light blue
      },
      'Office': {
        'icon': Icons.computer,
        'color': Color(0xFF66BB6A), // Vibrant green
      },
      'Garage': {
        'icon': Icons.garage,
        'color': Color(0xFF78909C), // Vibrant blue grey
      },
      'Guest Room': {
        'icon': Icons.weekend,
        'color': Color(0xFFFFB74D), // Vibrant orange
      },
      'Lobby': {
        'icon': Icons.door_front_door,
        'color': Color(0xFF9575CD), // Vibrant deep purple
      },
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Room Type",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: roomOptions.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.key),
                      leading: Icon(
                        entry.value['icon'],
                        color: entry.value['color'],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showRoomNameDialog(context, entry.key, entry.value['color'], entry.value['icon']);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a dialog to enter a name for the new room
  void _showRoomNameDialog(BuildContext context, String roomType, Color color, IconData icon) {
    TextEditingController _controller = TextEditingController(text: roomType);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Name Your Room"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Room Name",
              hintText: "Enter room name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = _controller.text.trim();
                final currentHome = Provider.of<HomeNameProvider>(context, listen: false).homeName;
                final roomBloc = context.read<RoomBloc>();

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room name cannot be empty.')),
                  );
                  return;
                }

                // Check if room name already exists in current home
                if (roomBloc.state.rooms[currentHome]?.any((r) => r.title.toLowerCase() == newName.toLowerCase()) ?? false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Room name already exists in this home. Choose a different name.')),
                  );
                  return;
                }

                // Add the room and immediately trigger a state update
                roomBloc.add(AddRoom(
                  homeName: currentHome,
                  roomName: newName,
                  color: color,
                  icon: icon,
                ));

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$newName added successfully!')),
                );

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  /// Shows a filter dialog
  void _showFilterDialog() {
    final currentHome = Provider.of<HomeNameProvider>(context, listen: false).homeName;
    final rooms = context.read<RoomBloc>().state.rooms[currentHome] ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Device Type'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: deviceTypes.entries.map((entry) {
              return ListTile(
                leading: Icon(entry.value['icon'], color: entry.value['color']),
                title: Text(entry.key),
                onTap: () {
                  setState(() {
                    selectedDeviceFilter = entry.key;
                  });
                  Navigator.pop(context); // Close first dialog
                  if (entry.key == 'All Devices') {
                    setState(() {
                      selectedDeviceFilter = null;
                    });
                  } else {
                    _showRoomsWithDevice(entry.key); // Show second dialog
                  }
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedDeviceFilter = null;
              });
              Navigator.pop(context);
            },
            child: Text('Clear Filter'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRoomsWithDevice(String deviceType) {
    context.read<DeviceUsageBloc>().add(IncrementDeviceUsage(deviceType));
    
    final currentHome = Provider.of<HomeNameProvider>(context, listen: false).homeName;
    final rooms = context.read<RoomBloc>().state.rooms[currentHome] ?? [];
    final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
    
    // Filter rooms that have the selected device type
    final roomsWithDevice = rooms.where((room) {
      final roomKey = '${currentHome}_${room.title}';
      final devices = scheduleTickProvider.getDevicesForRoom(roomKey);
      return devices.any((device) => device.type == deviceType);
    }).toList();

    if (roomsWithDevice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No rooms found with $deviceType')),
      );
      setState(() {
        selectedDeviceFilter = null;
      });
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            deviceType,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: roomsWithDevice.map((room) {
                  final roomKey = '${currentHome}_${room.title}';
                  final devices = scheduleTickProvider.getDevicesForRoom(roomKey);
                  final device = devices.firstWhere((d) => d.type == deviceType);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          room.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: room.color,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: device.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: device.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: device.isOn ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    device.isOn ? "Connected" : "Disconnected",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: device.isOn,
                              onChanged: (value) {
                                // Update device state
                                final index = devices.indexOf(device);
                                if (index != -1) {
                                  setDialogState(() {
                                    devices[index].isOn = value;
                                  });
                                  scheduleTickProvider.updateDevice(roomKey, devices[index]);
                                  setState(() {}); // Refresh main screen
                                }
                              },
                              activeColor: device.color,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDeviceFilter = null;
                });
                Navigator.pop(context);
              },
              child: Text(
                'Clear Filter',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the grid of rooms for the current home
  Widget _buildMyRoomsSection() {
    return BlocBuilder<RoomBloc, RoomState>(
      builder: (context, state) {
        final currentHome = Provider.of<HomeNameProvider>(context).homeName;
        var currentRooms = state.rooms[currentHome] ?? [];
        final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context);

        // Filter rooms based on selected device type
        if (selectedDeviceFilter != null && selectedDeviceFilter != 'All Devices') {
          currentRooms = currentRooms.where((room) {
            final roomKey = '${currentHome}_${room.title}';
            final devices = scheduleTickProvider.getDevicesForRoom(roomKey);
            return devices.any((device) => device.type == selectedDeviceFilter);
          }).toList();
        }

        if (currentRooms.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    selectedDeviceFilter != null
                        ? "No rooms found with ${selectedDeviceFilter}"
                        : "No area is selected by you.",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedDeviceFilter != null
                        ? "Try selecting a different device type"
                        : "Click on '+' icon to select your area to proceed.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedDeviceFilter != null && selectedDeviceFilter != 'All Devices')
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(deviceTypes[selectedDeviceFilter]!['icon'],
                          color: deviceTypes[selectedDeviceFilter]!['color']),
                      const SizedBox(width: 8),
                      Text(
                        'Showing rooms with ${selectedDeviceFilter}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedDeviceFilter = null;
                          });
                        },
                        icon: Icon(Icons.clear, size: 16),
                        label: Text('Clear'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: List.generate(currentRooms.length, (index) {
                  final room = currentRooms[index];
                  return RoomCard(
                    title: room.title,
                    color: room.color,
                    imageAsset: room.icon,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpecificRoomScreen(
                            roomName: room.title,
                            homeName: currentHome,
                            userName: widget.userName,
                          ),
                        ),
                      );
                    },
                    onDelete: () {
                      context.read<RoomBloc>().add(RemoveRoom(
                        homeName: currentHome,
                        index: index,
                      ));
                    },
                    homeName: currentHome,
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoomOptions(context),
        backgroundColor: AppColors.primaryBlueColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 24, left: 20, top: 11.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            _buildTopBar(),
            const SizedBox(height: 20),
            _buildWelcomeSection(),
            const SizedBox(height: 30),
            Text("All Rooms", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            _buildMyRoomsSection(),
            const SizedBox(height: 30),
            _buildFrequentlyUsedDevices(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.menu, size: 28),
        Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xffD3D3D3),
              child: Icon(Icons.notifications_none, color: Colors.black),
            ),
            const SizedBox(width: 21),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xffD3D3D3),
              child: InkWell(
                onTap: _showHomeDropdown,
                child: const Icon(Icons.house_outlined, color: Colors.black),
              ),
            ),
            const SizedBox(width: 21),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xffD3D3D3),
              child: InkWell(
                onTap: _toggleTopMenu,
                child: const Icon(Icons.more_vert, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<HomeNameProvider>(
      builder: (context, homeNameProvider, child) {
        return Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=4'),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hi, ${widget.userName}",
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("You are at ${homeNameProvider.homeName}",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _buildFrequentlyUsedDevices() {
    return BlocBuilder<DeviceUsageBloc, DeviceUsageState>(
      builder: (context, state) {
        final deviceUsageCount = state.deviceUsageCount;
        final frequentDevices = deviceTypes.entries
            .where((entry) => deviceUsageCount.containsKey(entry.key))
            .toList()
          ..sort((a, b) => (deviceUsageCount[b.key] ?? 0).compareTo(deviceUsageCount[a.key] ?? 0));
        
        final topDevices = frequentDevices.take(4).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Frequently Used Devices",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Column(
              children: topDevices.map((entry) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: entry.value['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: entry.value['color'].withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.read<DeviceUsageBloc>().add(IncrementDeviceUsage(entry.key));
                      _showRoomsWithDevice(entry.key);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            entry.value['icon'],
                            color: entry.value['color'],
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _menuOverlay?.remove();
    super.dispose();
  }
}

/// RoomCard represents a single room in the grid layout.
/// It displays the room's name, icon, and color, and provides
/// quick access to room controls through long press.
class RoomCard extends StatelessWidget {
  /// The name of the room
  final String title;
  
  /// The color theme of the room
  final Color color;
  
  /// The icon representing the room type
  final IconData imageAsset;
  
  /// Callback when the room is tapped
  final VoidCallback onTap;
  
  /// Callback when the room is deleted
  final VoidCallback onDelete;
  
  /// The name of the home this room belongs to
  final String homeName;

  const RoomCard({
    Key? key,
    required this.title,
    required this.color,
    required this.imageAsset,
    required this.onTap,
    required this.onDelete,
    required this.homeName,
  }) : super(key: key);

  /// Shows a horizontal row of quick control buttons when the room is long pressed
  void _showQuickControls(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    OverlayEntry? overlayEntry;
    bool isRemoved = false;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height / 2,
        left: offset.dx + size.width / 2,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildControlButton(
                  context,
                  Icons.lightbulb_outline,
                  Colors.amber,
                  () {
                    if (!isRemoved) {
                      overlayEntry?.remove();
                      isRemoved = true;
                      _showLightsDialog(context);
                    }
                  },
                ),
                const SizedBox(width: 16),
                _buildControlButton(
                  context,
                  Icons.air,
                  Colors.blue,
                  () {
                    // Fan control functionality
                    if (!isRemoved) {
                      overlayEntry?.remove();
                      isRemoved = true;
                    }
                  },
                ),
                const SizedBox(width: 16),
                _buildControlButton(
                  context,
                  Icons.ac_unit,
                  Colors.lightBlue,
                  () {
                    // AC control functionality
                    if (!isRemoved) {
                      overlayEntry?.remove();
                      isRemoved = true;
                    }
                  },
                ),
                const SizedBox(width: 16),
                _buildControlButton(
                  context,
                  Icons.more_vert,
                  Colors.grey,
                  () {
                    if (!isRemoved) {
                      overlayEntry?.remove();
                      isRemoved = true;
                      _showMoreOptions(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  /// Builds a circular control button with the specified icon and color
  Widget _buildControlButton(BuildContext context, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  /// Shows a dialog with all smart lights in the room
  void _showLightsDialog(BuildContext context) {
    final roomKey = '${homeName}_$title';
    final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
    final devices = scheduleTickProvider.getDevicesForRoom(roomKey);
    final lights = devices.where((device) => device.type == 'Smart Light').toList();

    if (lights.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No smart lights found in this room')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Smart Lights in $title'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: lights.map((device) {
              return ListTile(
                leading: Icon(device.icon, color: device.color),
                title: Text(device.name),
                trailing: Switch(
                  value: device.isOn,
                  onChanged: (value) {
                    final index = lights.indexOf(device);
                    if (index != -1) {
                      lights[index].isOn = value;
                      scheduleTickProvider.updateDevice(roomKey, lights[index]);
                    }
                    Navigator.pop(context);
                    _showLightsDialog(context); // Refresh dialog
                  },
                  activeColor: device.color,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Shows a dropdown menu with additional options for the room
  void _showMoreOptions(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    OverlayEntry? overlayEntry;
    bool isRemoved = false;

    overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          if (!isRemoved) {
            overlayEntry?.remove();
            isRemoved = true;
          }
        },
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              top: offset.dy + 60,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.devices, color: Colors.blue),
                        title: Text("Show All Added Devices"),
                        onTap: () {
                          if (!isRemoved) {
                            overlayEntry?.remove();
                            isRemoved = true;
                            _showAllDevicesDialog(context);
                          }
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text("Delete Area"),
                        onTap: () {
                          if (!isRemoved) {
                            overlayEntry?.remove();
                            isRemoved = true;
                            _showDeleteConfirmation(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  /// Shows a dialog with all devices in the room
  void _showAllDevicesDialog(BuildContext context) {
    final roomKey = '${homeName}_$title';
    final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
    final devices = scheduleTickProvider.getDevicesForRoom(roomKey);

    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No devices found in this room')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('All Devices in $title'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: devices.map((device) {
              return ListTile(
                leading: Icon(device.icon, color: device.color),
                title: Text(device.name),
                subtitle: Text(device.type),
                trailing: Switch(
                  value: device.isOn,
                  onChanged: (value) {
                    final index = devices.indexOf(device);
                    if (index != -1) {
                      devices[index].isOn = value;
                      scheduleTickProvider.updateDevice(roomKey, devices[index]);
                    }
                    Navigator.pop(context);
                    _showAllDevicesDialog(context); // Refresh dialog
                  },
                  activeColor: device.color,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before deleting the room
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Area'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Get the current home name and room index
              final currentHome = homeName;
              final roomBloc = context.read<RoomBloc>();
              final rooms = roomBloc.state.rooms[currentHome] ?? [];
              final roomIndex = rooms.indexWhere((room) => room.title == title);
              
              if (roomIndex != -1) {
                // Remove the room using RoomBloc
                roomBloc.add(RemoveRoom(
                  homeName: currentHome,
                  index: roomIndex,
                ));
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title has been deleted')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showQuickControls(context),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  imageAsset,
                  size: 32,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}