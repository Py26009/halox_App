import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../App_Utilities/app_utilities.dart';
import '../../State Management/Provider State management/User Data Provider/All homes list provider.dart';
import '../../State Management/Provider State management/User Data Provider/home_name Provider.dart';
import 'Specific room Screen.dart';

class FirstScreen extends StatefulWidget {
  final String homeName;
  final String userName;
  FirstScreen({required this.homeName, required this.userName});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen>{

  TextEditingController hName = TextEditingController();
  String? errorText;

  // Store rooms per home - Map<HomeName, List<RoomData>>
  Map<String, List<RoomData>> _homeRooms = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HomeNameProvider>(context, listen: false);
      final homeListProvider = Provider.of<HomeListProvider>(context, listen: false);
      provider.setHomeName(widget.homeName);
      homeListProvider.setInitialHome(widget.homeName);

      // Initialize empty room list for the initial home if not exists
      if (!_homeRooms.containsKey(widget.homeName)) {
        _homeRooms[widget.homeName] = [];
      }
    });
  }

  // Get current home's rooms
  List<RoomData> get _currentHomeRooms {
    final currentHome = Provider.of<HomeNameProvider>(context, listen: false).homeName;
    return _homeRooms[currentHome] ?? [];
  }

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
              right: 80, // Adjust as per design
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
                          // Initialize empty room list for this home if not exists
                          if (!_homeRooms.containsKey(home)) {
                            _homeRooms[home] = [];
                          }

                          homeNameProvider.setHomeName(home);
                          setState(() {}); // Refresh UI to show rooms for selected home

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
                        // TODO: Handle Filter
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

                          // Check if home already exists
                          if (homeListProvider.homeList.contains(newHomeName)) {
                            setDialogState(() {
                              errorText = "Home with this name already exists";
                            });
                          } else {
                            // Add new home to the list
                            homeListProvider.addHome(newHomeName);
                            // Initialize empty room list for new home
                            _homeRooms[newHomeName] = [];
                            // Set the new home as current home
                            homeNameProvider.setHomeName(newHomeName);

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
    String deletedHome = homeNameProvider.homeName;

    setState(() {
      // Remove from provider
      homeListProvider.removeHome(deletedHome);

      // Remove rooms data for this home
      _homeRooms.remove(deletedHome);

      // Set new current home (first available home)
      if (homeListProvider.homeList.isNotEmpty) {
        String newCurrentHome = homeListProvider.homeList.first;
        homeNameProvider.setHomeName(newCurrentHome);

        // Initialize empty room list for new current home if not exists
        if (!_homeRooms.containsKey(newCurrentHome)) {
          _homeRooms[newCurrentHome] = [];
        }
      }
    });

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

  /// Categorization of rooms
  void _showRoomOptions(BuildContext context) {
    final Map<String, RoomData> roomOptions = {
      'Bed Room': RoomData("Bed Room", Colors.pinkAccent, Icons.bed),
      'Living Room': RoomData("Living Room", Colors.lightBlueAccent, Icons.chair),
      'Guest Room': RoomData("Guest Room", Colors.grey, Icons.bed_outlined),
      'Study Room': RoomData("Study Room", Colors.amberAccent, Icons.chair_alt),
      'Kitchen': RoomData("Kitchen", Colors.purpleAccent, Icons.kitchen),
      'Others': RoomData("Others", Colors.lightGreenAccent, Icons.other_houses),
    };

    /// Bottom Sheet for option for rooms
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
            children: roomOptions.entries.map((entry) {
              return ListTile(
                  title: Text(entry.key),
                  leading: const Icon(Icons.meeting_room),
                  onTap: () {
                    Navigator.pop(context);
                    // Allow all rooms to be added, regardless of type duplicates
                    _showRenameDialog(context, entry.value);
                  }
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Rename Dialog box
  void _showRenameDialog(BuildContext context, RoomData room) {
    TextEditingController _controller = TextEditingController(text: room.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rename Room"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: "Room Name"),
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

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Room name cannot be empty.')),
                  );
                  return;
                }

                // Check if room name already exists in current home
                if (_homeRooms[currentHome]?.any((r) => r.title.toLowerCase() == newName.toLowerCase()) ?? false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Room name already exists in this home. Choose a different name.')),
                  );
                  return;
                }

                if (!mounted) return; // Check widget still mounted before setState

                setState(() {
                  // Add room to current home's room list
                  if (_homeRooms[currentHome] == null) {
                    _homeRooms[currentHome] = [];
                  }
                  _homeRooms[currentHome]!.add(RoomData(newName, room.color, room.icon));
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMyRoomsSection() {
    final currentHome = Provider.of<HomeNameProvider>(context).homeName;
    final currentRooms = _homeRooms[currentHome] ?? [];

    if (currentRooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                "No area is selected by you.",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                "Click on '+' icon to select your area to proceed.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // GridView for added rooms in current home
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        shrinkWrap: true,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
                 children: currentRooms.asMap().entries.map((entry) {
                int index = entry.key;
              RoomData room = entry.value;
                  return RoomCard(
                title: room.title,
                  color: room.color,
                  imageAsset: room.icon,
                   onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>SpecificRoomScreen(roomName: "BedRoom", homeName: widget.homeName, userName: widget.userName)));
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
                setState(() {
                _homeRooms[currentHome]?.removeAt(index);
                    });
                    },
               );
                     }).toList(),
                )
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
        padding: const EdgeInsets.only( right: 24, left: 20, top: 11.0),
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

  @override
  void dispose() {
    _menuOverlay?.remove();
    super.dispose();
  }
}

// Keep the rest of your classes (RoomCard, _IconOption, etc.) unchanged
class RoomCard extends StatefulWidget {
  final String title;
  final Color color;
  final IconData imageAsset;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.title,
    required this.color,
    required this.imageAsset,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  OverlayEntry? _overlayEntry;
  bool _showDelete = false;
  Offset _cardOffset = Offset.zero;
  Size _cardSize = Size.zero;
  bool isLightOn = false;
  bool isFanOn = false;
  bool isAcOn = false;

  void _showOverlayBar() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    _cardOffset = renderBox.localToGlobal(Offset.zero);
    _cardSize = renderBox.size;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          entry.remove();
          _overlayEntry = null;
        },
        child: Stack(
          children: [
            // Transparent background to detect outside taps
            Positioned.fill(
              child: Container(color: Colors.transparent),
            ),

            // Icon bar
            Positioned(
              left: _cardOffset.dx,
              top: _cardOffset.dy - 60,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _IconOption(
                        icon: Icons.light,
                        label: "Light",
                        onTap: (){
                          setState(() {
                            isLightOn=!isLightOn;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _overlayEntry?.remove();
                            });
                          });
                        },
                        iColor: isLightOn? Colors.yellow: Colors.grey,
                      ),
                      const SizedBox(width: 20),
                      _IconOption(
                        icon: FontAwesomeIcons.fan,
                        label: "Fan",
                        onTap: (){
                          setState(() {
                            isFanOn=!isFanOn;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _overlayEntry?.remove();

                            });
                          });
                        },
                        iColor: isFanOn? Colors.yellow: Colors.grey ,),
                      const SizedBox(width: 20),
                      _IconOption(
                        icon: FontAwesomeIcons.snowflake,
                        label: "AC",
                        iColor: isAcOn?Colors.yellow: Colors.grey,
                        onTap: (){
                          setState(() {
                            isAcOn=!isAcOn;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _overlayEntry?.remove();
                            });
                          });
                        },),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showDelete = !_showDelete;
                          });
                          entry.markNeedsBuild();
                        },
                        child: const Icon(Icons.more_vert, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Delete Popup (conditionally shown)
            if (_showDelete)
              Positioned(
                left: _cardOffset.dx + _cardSize.width / 2,
                top: _cardOffset.dy - 120,
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        widget.onDelete();
                        entry.remove();
                        _overlayEntry = null;
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    overlay.insert(entry);
    _overlayEntry = entry;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: _showOverlayBar,
      child: Container(
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.imageAsset, size: 36, color: widget.color),
            const SizedBox(height: 8),
            Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }
}

class _IconOption extends StatelessWidget {
  final IconData icon;
  final Color iColor;
  final String label;
  VoidCallback ? onTap;

  _IconOption({required this.icon, required this.label, required this.onTap, required this.iColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
            onTap: onTap,
            child: Icon(icon, size: 28, color: iColor)),
        const SizedBox(height: 2),
        Text(label, style: mTextStyle14()),
      ],
    );
  }
}

class _DeviceItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DeviceItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

class RoomData {
  final String title;
  final Color color;
  final IconData icon;

  RoomData(this.title, this.color, this.icon);
}