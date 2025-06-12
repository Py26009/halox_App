import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:halox_app/App_Utilities/app_utilities.dart';
import 'package:halox_app/App_Screens/Home Bottom Nav Screens/Device_Specific_Screen.dart';
import 'package:provider/provider.dart';
import 'package:halox_app/State Management/Provider State management/User Data Provider/Device Provider.dart';

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
  }

  @override
  void dispose() {
    _removeCurrentOverlay();
    super.dispose();
  }

  void _removeCurrentOverlay() {
    if (_currentOverlay != null) {
      _currentOverlay?.remove();
      _currentOverlay = null;
      setState(() {
        _isOverlayVisible = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilters.isEmpty) {
        _filteredDevices = List.from(Provider.of<ScheduleTickProvider>(context).getDevicesForRoom(_roomKey));
      } else {
        _filteredDevices = Provider.of<ScheduleTickProvider>(context).getDevicesForRoom(_roomKey)
            .where((device) => _selectedFilters.contains(device.type))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomKey = '${widget.homeName}_${widget.roomName}';
    final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context);
    final devicesToShow = scheduleTickProvider.getDevicesForRoom(roomKey);

    return WillPopScope(
      onWillPop: () async {
        if (_isOverlayVisible) {
          _removeCurrentOverlay();
          return false;
        }
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (_isOverlayVisible) {
                _removeCurrentOverlay();
              } else {
                Navigator.of(context).pop();
              }
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
                        ? "Filter cleared. Showing all ${_filteredDevices.length} device(s)."
                        : "Filter applied. Showing ${_filteredDevices.length} of ${_filteredDevices.length} device(s).";

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
        schedules: [],
      ),
      'Smart Fan': DeviceData(
        name: "Smart Fan",
        type: "Smart Fan",
        icon: FontAwesomeIcons.fan,
        color: Colors.blue,
        isOn: false,
        schedules: [],
      ),
      'Air Conditioner': DeviceData(
        name: "Air Conditioner",
        type: "Air Conditioner",
        icon: FontAwesomeIcons.snowflake,
        color: Colors.lightBlue,
        isOn: false,
        schedules: [],
      ),
      'Smart TV': DeviceData(
        name: "Smart TV",
        type: "Smart TV",
        icon: Icons.tv,
        color: Colors.black,
        isOn: false,
        schedules: [],
      ),
      'Smart Speaker': DeviceData(
        name: "Smart Speaker",
        type: "Smart Speaker",
        icon: Icons.speaker,
        color: Colors.purple,
        isOn: false,
        schedules: [],
      ),
      'Smart Plug': DeviceData(
        name: "Smart Plug",
        type: "Smart Plug",
        icon: Icons.power,
        color: Colors.green,
        isOn: false,
        schedules: [],
      ),
      'Smart Lock': DeviceData(
        name: "Smart Lock",
        type: "Smart Lock",
        icon: Icons.lock,
        color: Colors.brown,
        isOn: false,
        schedules: [],
      ),
      'Security Camera': DeviceData(
        name: "Security Camera",
        type: "Security Camera",
        icon: Icons.videocam,
        color: Colors.red,
        isOn: false,
        schedules: [],
      ),
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
                        final roomKey = '${widget.homeName}_${widget.roomName}';
                        final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
                        final devices = scheduleTickProvider.getDevicesForRoom(roomKey);
                        
                        // Check if device already exists
                        if (devices.any((d) => d.name == entry.value.name)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('This device already exists in the room.')),
                          );
                          return;
                        }
                        
                        scheduleTickProvider.addDevice(roomKey, entry.value);
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

  Widget _buildDevicesSection() {
    final roomKey = '${widget.homeName}_${widget.roomName}';
    final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context);
    List<DeviceData> devicesToShow = _selectedFilters.isEmpty
        ? scheduleTickProvider.getDevicesForRoom(roomKey)
        : scheduleTickProvider.getDevicesForRoom(roomKey)
            .where((device) => _selectedFilters.contains(device.type))
            .toList();

    if (devicesToShow.isEmpty) {
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
              'No devices added by you yet,',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click on + button to add devices',
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

        return DeviceCard(
          device: device,
          onToggle: (isOn) {
            final updatedDevice = DeviceData(
              name: device.name,
              type: device.type,
              icon: device.icon,
              color: device.color,
              isOn: isOn,
              schedules: device.schedules,
            );
            final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
            scheduleTickProvider.updateDevice(roomKey, updatedDevice);
          },
          onDelete: () {
            _deleteDevice(device.name);
          },
          userName: widget.userName,
          roomName: widget.roomName,
          homeName: widget.homeName,
        );
      }).toList(),
    );
  }

  void _deleteDevice(String deviceName) {
    final roomKey = '${widget.homeName}_${widget.roomName}';
    final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
    scheduleTickProvider.removeDevice(roomKey, deviceName);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$deviceName has been deleted',
          style: GoogleFonts.poppins(),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class DeviceData {
  final String name;
  final String type;
  final IconData icon;
  final Color color;
  bool isOn;
  final List<Map<String, dynamic>> schedules;

  DeviceData({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.isOn,
    this.schedules = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'icon': icon.codePoint,
      'color': color.value,
      'isOn': isOn,
      'schedules': schedules,
    };
  }

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    try {
      final iconCodePoint = json['icon'] as int;
      IconData iconData;
      
      // Map common device icon code points to their corresponding icons
      switch (iconCodePoint) {
        case 0xe1e7: // lightbulb
          iconData = Icons.lightbulb;
          break;
        case 0xe1e8: // air
          iconData = Icons.air;
          break;
        case 0xe1e9: // ac_unit
          iconData = Icons.ac_unit;
          break;
        case 0xe1ea: // tv
          iconData = Icons.tv;
          break;
        case 0xe1eb: // speaker
          iconData = Icons.speaker;
          break;
        case 0xe1ec: // power
          iconData = Icons.power;
          break;
        case 0xe1ed: // lock
          iconData = Icons.lock;
          break;
        case 0xe1ee: // videocam
          iconData = Icons.videocam;
          break;
        case 0xe1ef: // thermostat
          iconData = Icons.thermostat;
          break;
        case 0xe1f0: // curtains
          iconData = Icons.curtains;
          break;
        default:
          iconData = Icons.devices;
      }

      return DeviceData(
        name: json['name'] as String,
        type: json['type'] as String,
        icon: iconData,
        color: Color(json['color'] as int),
        isOn: json['isOn'] as bool,
        schedules: (json['schedules'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      );
    } catch (e) {
      return DeviceData(
        name: json['name'] as String,
        type: json['type'] as String,
        icon: Icons.devices,
        color: Color(json['color'] as int),
        isOn: json['isOn'] as bool,
        schedules: (json['schedules'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      );
    }
  }
}

class DeviceCard extends StatefulWidget {
  final DeviceData device;
  final Function(bool) onToggle;
  final VoidCallback onDelete;
  final String userName;
  final String roomName;
  final String homeName;

  const DeviceCard({
    Key? key,
    required this.device,
    required this.onToggle,
    required this.onDelete,
    required this.userName,
    required this.roomName,
    required this.homeName,
  }) : super(key: key);

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  void _showDeleteOption() {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Device',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete ${widget.device.name}?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDeviceDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceSpecificScreen(
          device: widget.device,
          userName: widget.userName,
          roomName: widget.roomName,
          homeName: widget.homeName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug print for schedules
    print('Device: \'${widget.device.name}\' schedules: \'${widget.device.schedules}\'');
    return GestureDetector(
      onTap: _navigateToDeviceDetail,
      child: Container(
        decoration: BoxDecoration(
          color: widget.device.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.device.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.device.icon,
                  color: widget.device.color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.device.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Switch(
              value: widget.device.isOn,
              onChanged: widget.onToggle,
              activeColor: widget.device.color,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.device.isOn ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.device.isOn ? 'Connected' : 'Disconnected',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (widget.device.schedules.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceDetailScreen extends StatefulWidget {
  final DeviceData device;
  final Function(bool) onToggle;

  const DeviceDetailScreen({
    Key? key,
    required this.device,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.device.name,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.device.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.device.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    widget.device.icon,
                    size: 48,
                    color: widget.device.isOn ? widget.device.color : Colors.grey,
                  ),
                  Switch(
                    value: widget.device.isOn,
                    onChanged: widget.onToggle,
                    activeColor: widget.device.color,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Device Information",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow("Device Type", widget.device.type),
            _buildInfoRow("Status", widget.device.isOn ? "Connected" : "Disconnected"),
            _buildInfoRow("Last Updated", "Just now"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}