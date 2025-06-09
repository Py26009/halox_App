import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:halox_app/App_Utilities/app_utilities.dart';

// SOLUTION 1: Create a simple device storage service
class DeviceStorage {
  static final Map<String, List<DeviceData>> _roomDevices = {};

  static List<DeviceData> getDevicesForRoom(String roomKey) {
    return _roomDevices[roomKey] ?? [];
  }

  static void saveDevicesForRoom(String roomKey, List<DeviceData> devices) {
    _roomDevices[roomKey] = List.from(devices);
  }
}

class SpecificRoomScreen extends StatefulWidget {
  final String roomName;
  final String homeName;
  final String userName;

  const SpecificRoomScreen({
    Key? key,
    required this.roomName,
    required this.homeName,
    required this.userName,
  }) : super(key: key);

  @override
  State<SpecificRoomScreen> createState() => _SpecificRoomScreenState();
}

class _SpecificRoomScreenState extends State<SpecificRoomScreen> {
  // Store devices for this room
  List<DeviceData> _roomDevices = [];

  // Filter state
  Set<String> _selectedFilters = {};
  List<DeviceData> _filteredDevices = [];

  // Track overlay state - FIXED VERSION
  OverlayEntry? _currentOverlay;
  bool _isOverlayVisible = false; // Added flag to properly track visibility

  // Available device types for filtering
  final List<String> _deviceTypes = [
    'Smart Light',
    'Smart Fan',
    'Air Conditioner',
    'Smart TV',
    'Smart Speaker',
    'Smart Plug',
    'Smart Lock',
    'Security Camera',
    'Thermostat',
    'Smart Curtains',
    'Others'
  ];

  // SOLUTION 2: Create unique room key for storage
  String get _roomKey => '${widget.homeName}_${widget.roomName}';

  @override
  void initState() {
    super.initState();
    // SOLUTION 3: Load devices from storage on init
    _loadDevices();
  }

  // SOLUTION 4: Load devices from storage
  void _loadDevices() {
    _roomDevices = DeviceStorage.getDevicesForRoom(_roomKey);
    _applyFilter();
  }

  // SOLUTION 5: Save devices to storage
  void _saveDevices() {
    DeviceStorage.saveDevicesForRoom(_roomKey, _roomDevices);
  }

  @override
  void dispose() {
    _removeCurrentOverlay();
    super.dispose();
  }

  void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
    _isOverlayVisible = false; // Reset the flag
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilters.isEmpty) {
        _filteredDevices = List.from(_roomDevices);
      } else {
        _filteredDevices = _roomDevices
            .where((device) => _selectedFilters.contains(device.type))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press (both hardware and software)
        if (_isOverlayVisible) {
          _removeCurrentOverlay();
          return false; // Don't pop the route
        }
        return true; // Allow normal navigation
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Simplified: Let WillPopScope handle the logic
              Navigator.maybePop(context);
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0, top: 11.0),
              child: Row(
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
                      onTap: () => _showOptionsMenu(),
                      child: const Icon(Icons.more_vert, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showDeviceOptions(context),
          backgroundColor: AppColors.primaryBlueColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                "Hey ${widget.userName}, ",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Text(
                'You are in ${widget.roomName} of ${widget.homeName}',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All Devices",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  if (_selectedFilters.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Filtered (${_selectedFilters.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(child: _buildDevicesSection()),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    _removeCurrentOverlay(); // Remove any existing overlay first

    _currentOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () => _removeCurrentOverlay(),
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              top: kToolbarHeight + 40,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text("Settings"),
                        onTap: () {
                          _removeCurrentOverlay();
                          // Handle settings
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text("Filter"),
                        onTap: () {
                          _removeCurrentOverlay();
                          _showFilterDialog();
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

    Overlay.of(context).insert(_currentOverlay!);
    _isOverlayVisible = true; // Set the flag when overlay is shown
  }

  void _showFilterDialog() {
    Set<String> tempSelectedFilters = Set.from(_selectedFilters);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filter Devices",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (tempSelectedFilters.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          tempSelectedFilters.clear();
                        });
                      },
                      child: Text(
                        "Clear All",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Select device types to filter:",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _deviceTypes.length,
                        itemBuilder: (context, index) {
                          final deviceType = _deviceTypes[index];
                          final isSelected = tempSelectedFilters.contains(deviceType);

                          return CheckboxListTile(
                            title: Text(
                              deviceType,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  tempSelectedFilters.add(deviceType);
                                } else {
                                  tempSelectedFilters.remove(deviceType);
                                }
                              });
                            },
                            activeColor: AppColors.primaryBlueColor,
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilters = Set.from(tempSelectedFilters);
                      _applyFilter();
                    });
                    Navigator.pop(context);

                    String message = _selectedFilters.isEmpty
                        ? "Filter cleared. Showing all ${_roomDevices.length} device(s)."
                        : "Filter applied. Showing ${_filteredDevices.length} of ${_roomDevices.length} device(s).";

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlueColor,
                  ),
                  child: Text(
                    "Apply Filter",
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeviceOptions(BuildContext context) {
    final Map<String, DeviceData> deviceOptions = {
      'Smart Light': DeviceData(
        name: "Smart Light",
        type: "Smart Light",
        icon: Icons.lightbulb,
        color: Colors.yellow,
        isOn: false,
      ),
      'Smart Fan': DeviceData(
        name: "Smart Fan",
        type: "Smart Fan",
        icon: FontAwesomeIcons.fan,
        color: Colors.blue,
        isOn: false,
      ),
      'Air Conditioner': DeviceData(
        name: "Air Conditioner",
        type: "Air Conditioner",
        icon: FontAwesomeIcons.snowflake,
        color: Colors.lightBlue,
        isOn: false,
      ),
      'Smart TV': DeviceData(
        name: "Smart TV",
        type: "Smart TV",
        icon: Icons.tv,
        color: Colors.black,
        isOn: false,
      ),
      'Smart Speaker': DeviceData(
        name: "Smart Speaker",
        type: "Smart Speaker",
        icon: Icons.speaker,
        color: Colors.purple,
        isOn: false,
      ),
      'Smart Plug': DeviceData(
        name: "Smart Plug",
        type: "Smart Plug",
        icon: Icons.power,
        color: Colors.green,
        isOn: false,
      ),
      'Smart Lock': DeviceData(
        name: "Smart Lock",
        type: "Smart Lock",
        icon: Icons.lock,
        color: Colors.brown,
        isOn: false,
      ),
      'Security Camera': DeviceData(
        name: "Security Camera",
        type: "Security Camera",
        icon: Icons.videocam,
        color: Colors.red,
        isOn: false,
      ),
      'Thermostat': DeviceData(
        name: "Thermostat",
        type: "Thermostat",
        icon: Icons.thermostat,
        color: Colors.orange,
        isOn: false,
      ),
      'Smart Curtains': DeviceData(
        name: "Smart Curtains",
        type: "Smart Curtains",
        icon: Icons.curtains,
        color: Colors.indigo,
        isOn: false,
      ),
      "Others": DeviceData(
          name: "Others",
          type: "Others",
          icon: Icons.devices_other_sharp,
          color: Colors.grey,
          isOn: false
      )
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
                "Select Device to Add",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: deviceOptions.entries.map((entry) {
                    return ListTile(
                      title: Text(entry.key),
                      leading: Icon(entry.value.icon, color: entry.value.color),
                      onTap: () {
                        Navigator.pop(context);
                        _showDeviceNameDialog(context, entry.value);
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

  void _showDeviceNameDialog(BuildContext context, DeviceData device) {
    TextEditingController _controller = TextEditingController(text: device.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Name Your Device"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Device Name",
              hintText: "Enter device name",
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

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Device name cannot be empty.')),
                  );
                  return;
                }

                if (_roomDevices.any((d) => d.name.toLowerCase() == newName.toLowerCase())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Device name already exists. Choose a different name.')),
                  );
                  return;
                }

                setState(() {
                  _roomDevices.add(DeviceData(
                    name: newName,
                    type: device.type,
                    icon: device.icon,
                    color: device.color,
                    isOn: false,
                  ));
                  // SOLUTION 7: Save devices after adding
                  _saveDevices();
                  _applyFilter();
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$newName added successfully!')),
                );
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDevicesSection() {
    List<DeviceData> devicesToShow = _filteredDevices;

    if (devicesToShow.isEmpty && _roomDevices.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No devices match the current filter.",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your filter settings.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (_roomDevices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No devices added yet.",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Click on '+' icon to add your first device.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: devicesToShow.asMap().entries.map((entry) {
        int filteredIndex = entry.key;
        DeviceData device = entry.value;
        int originalIndex = _roomDevices.indexOf(device);

        return DeviceCard(
          device: device,
          onToggle: (isOn) {
            setState(() {
              _roomDevices[originalIndex].isOn = isOn;
              // SOLUTION 8: Save devices after toggling
              _saveDevices();
              _applyFilter();
            });
          },
          onDelete: () {
            setState(() {
              _roomDevices.removeAt(originalIndex);
              // SOLUTION 9: Save devices after deletion
              _saveDevices();
              _applyFilter();
            });
          },
        );
      }).toList(),
    );
  }
}

class DeviceData {
  final String name;
  final String type;
  final IconData icon;
  final Color color;
  bool isOn;

  DeviceData({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isOn,
  });
}

class DeviceCard extends StatefulWidget {
  final DeviceData device;
  final Function(bool) onToggle;
  final VoidCallback onDelete;

  const DeviceCard({
    Key? key,
    required this.device,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  void _showDeleteOption() {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

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
              left: offset.dx + size.width / 2 - 50,
              top: offset.dy - 60,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      if (!isRemoved) {
                        overlayEntry?.remove();
                        isRemoved = true;
                      }
                      widget.onDelete();
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

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showDeleteOption,
      child: Container(
        decoration: BoxDecoration(
          color: widget.device.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.device.color.withOpacity(0.3),
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
                  widget.device.icon,
                  size: 32,
                  color: widget.device.isOn ? widget.device.color : Colors.grey,
                ),
                Switch(
                  value: widget.device.isOn,
                  onChanged: widget.onToggle,
                  activeColor: widget.device.color,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.device.name,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: widget.device.isOn ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.device.isOn ? "Connected" : "Disconnected",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}