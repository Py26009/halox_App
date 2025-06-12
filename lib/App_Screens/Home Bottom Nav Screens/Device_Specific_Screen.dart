import 'package:flutter/material.dart';
import 'package:halox_app/App_Screens/Home Bottom Nav Screens/Specific room Screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:halox_app/State Management/Provider State management/User Data Provider/Device Provider.dart';

class DeviceSpecificScreen extends StatefulWidget {
  final DeviceData device;
  final String userName;
  final String roomName;
  final String homeName;
  
  const DeviceSpecificScreen({
    super.key,
    required this.device,
    required this.userName,
    required this.roomName,
    required this.homeName,
  });

  @override
  State<DeviceSpecificScreen> createState() => _DeviceSpecificScreenState();
}

class _DeviceSpecificScreenState extends State<DeviceSpecificScreen> {
  late DeviceData _device;
  bool _isWarmTone = true; // true for warm, false for cold

  @override
  void initState() {
    super.initState();
    _device = widget.device;
    // Ensure we have the latest device data from the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomKey = '${widget.homeName}_${widget.roomName}';
      final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
      final devices = scheduleTickProvider.getDevicesForRoom(roomKey);
      final deviceIndex = devices.indexWhere((d) => d.name == _device.name);
      if (deviceIndex != -1) {
        setState(() {
          _device = devices[deviceIndex];
        });
      }
    });
  }

  String _getControlText() {
    switch (_device.type) {
      case 'Smart Light':
        return 'Tone Glow';
      case 'Smart Fan':
        return 'Speed';
      case 'Air Conditioner':
        return 'Temperature';
      case 'Smart TV':
        return 'Volume';
      case 'Smart Speaker':
        return 'Volume';
      case 'Smart Plug':
        return 'Power';
      case 'Smart Lock':
        return 'Security';
      case 'Security Camera':
        return 'Mode';
      case 'Thermostat':
        return 'Temperature';
      case 'Smart Curtains':
        return 'Position';
      default:
        return 'Control';
    }
  }

  void _toggleDevice(bool value) {
    setState(() {
      _device.isOn = value;
    });
    
    // Update the device state in the provider
    final roomKey = '${widget.homeName}_${widget.roomName}';
    final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
    final devices = scheduleTickProvider.getDevicesForRoom(roomKey);
    
    // Find and update the device
    final deviceIndex = devices.indexWhere((d) => d.name == _device.name);
    if (deviceIndex != -1) {
      final updatedDevice = DeviceData(
        name: _device.name,
        type: _device.type,
        icon: _device.icon,
        color: _device.color,
        isOn: value,
        schedules: List<Map<String, dynamic>>.from(_device.schedules),
      );
      scheduleTickProvider.updateDevice(roomKey, updatedDevice);
    }
  }

  void _toggleTone(bool value) {
    setState(() {
      _isWarmTone = value;
    });
  }

  void _showScheduleSheet() {
    if (!_device.isOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Device is turned off',
                      style: GoogleFonts.poppins(
                        color: Colors.red[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Please turn on the device to set a schedule.',
                      style: GoogleFonts.poppins(
                        color: Colors.red[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[50],
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        if (_device.type == 'Smart Light') {
          return _buildSmartLightScheduleSheet();
        }
        if (_device.type == 'Air Conditioner') {
          return _buildACScheduleSheet();
        }
        if (_device.type == 'Smart Fan') {
          return _buildFanScheduleSheet();
        }
        // Placeholder for other device types
        return Container(
          height: 200,
          child: Center(child: Text('Schedule UI for this device coming soon!')),
        );
      },
    );
  }

  void _showScheduleConflictDialog(BuildContext context, List<Map<String, dynamic>> existingSchedules, Map<String, dynamic> newSchedule, Function onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Schedule Conflict',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have ${existingSchedules.length} existing schedule${existingSchedules.length > 1 ? 's' : ''}:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: existingSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = existingSchedules[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_device.type == 'Smart Light') ...[
                          Text('Tone: ${schedule['tone']}'),
                          Text('On Time: ${schedule['onTime']}'),
                          Text('Off Time: ${schedule['offTime']}'),
                        ] else if (_device.type == 'Air Conditioner') ...[
                          Text('Mode: ${schedule['mode']}'),
                          Text('Temperature: ${schedule['temperature']}°C'),
                          Text('Off Time: ${schedule['offTime']}'),
                        ] else if (_device.type == 'Smart Fan') ...[
                          Text('Speed: ${schedule['speed']}'),
                          Text('Off Time: ${schedule['offTime']}'),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Remove the selected schedule and add the new one
                                final roomKey = '${widget.homeName}_${widget.roomName}';
                                final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
                                final updatedDevice = DeviceData(
                                  name: _device.name,
                                  type: _device.type,
                                  icon: _device.icon,
                                  color: _device.color,
                                  isOn: _device.isOn,
                                  schedules: List<Map<String, dynamic>>.from(_device.schedules)
                                    ..remove(schedule)
                                    ..add(newSchedule),
                                );
                                scheduleTickProvider.updateDevice(roomKey, updatedDevice);
                                
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
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
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (_device.type == 'Smart Light')
                                                Text('Tone: ${newSchedule['tone']}, Start time: ${newSchedule['onTime']}, End time: ${newSchedule['offTime']}', style: GoogleFonts.poppins())
                                              else if (_device.type == 'Air Conditioner')
                                                Text('${newSchedule['mode']} mode, ${newSchedule['temperature']}°C, Off time: ${newSchedule['offTime']}', style: GoogleFonts.poppins())
                                              else if (_device.type == 'Smart Fan')
                                                Text('Speed ${newSchedule['speed']}, Off time: ${newSchedule['offTime']}', style: GoogleFonts.poppins()),
                                              Text('Selected schedule has been replaced.', style: GoogleFonts.poppins()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Text(
                                'Replace This',
                                style: GoogleFonts.poppins(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'What would you like to do?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ],
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
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Create New Schedule',
              style: GoogleFonts.poppins(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void _showDuplicateScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Duplicate Schedule',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This schedule is already set. Please choose different settings or cancel.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  bool _isScheduleDuplicate(Map<String, dynamic> newSchedule) {
    return _device.schedules.any((existingSchedule) {
      if (_device.type == 'Smart Light') {
        return existingSchedule['tone'] == newSchedule['tone'] &&
               existingSchedule['onTime'] == newSchedule['onTime'] &&
               existingSchedule['offTime'] == newSchedule['offTime'];
      } else if (_device.type == 'Air Conditioner') {
        return existingSchedule['mode'] == newSchedule['mode'] &&
               existingSchedule['temperature'] == newSchedule['temperature'] &&
               existingSchedule['offTime'] == newSchedule['offTime'];
      } else if (_device.type == 'Smart Fan') {
        return existingSchedule['speed'] == newSchedule['speed'] &&
               existingSchedule['offTime'] == newSchedule['offTime'];
      }
      return false;
    });
  }

  Widget _buildSmartLightScheduleSheet() {
    DateTime now = DateTime.now();
    int selectedDay = now.day;
    int selectedMonth = now.month;
    int selectedYear = now.year;
    TimeOfDay onTime = TimeOfDay.now();
    TimeOfDay offTime = TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: TimeOfDay.now().minute);

    return StatefulBuilder(
      builder: (context, setSheetState) {
        final isAtCurrentMonthYear = (selectedMonth == now.month && selectedYear == now.year);
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: isAtCurrentMonthYear
                          ? null
                          : () {
                              setSheetState(() {
                                if (selectedMonth == 1) {
                                  selectedMonth = 12;
                                  selectedYear--;
                                } else {
                                  selectedMonth--;
                                }
                              });
                            },
                      color: isAtCurrentMonthYear ? Colors.grey[300] : Colors.black,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '${_monthName(selectedMonth)} $selectedYear',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Select the desired date',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: () {
                        setSheetState(() {
                          if (selectedMonth == 12) {
                            selectedMonth = 1;
                            selectedYear++;
                          } else {
                            selectedMonth++;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: DateUtils.getDaysInMonth(selectedYear, selectedMonth),
                    itemBuilder: (context, index) {
                      int day = index + 1;
                      DateTime date = DateTime(selectedYear, selectedMonth, day);
                      bool isSelected = selectedDay == day;
                      bool isPast = date.isBefore(DateTime(now.year, now.month, now.day));
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: isPast
                              ? null
                              : () {
                                  setSheetState(() {
                                    selectedDay = day;
                                  });
                                },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isSelected && !isPast ? Colors.blue : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day.toString().padLeft(2, '0'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: isPast
                                        ? Colors.grey[400]
                                        : isSelected
                                            ? Colors.white
                                            : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _weekdayShort(date.weekday),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isPast
                                        ? Colors.grey[400]
                                        : isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select the desired time',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _timePickerTile(
                        context: context,
                        label: 'On Time',
                        time: onTime,
                        onTap: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: onTime,
                          );
                          if (picked != null) {
                            setSheetState(() {
                              onTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _timePickerTile(
                        context: context,
                        label: 'Off Time',
                        time: offTime,
                        onTap: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: offTime,
                          );
                          if (picked != null) {
                            setSheetState(() {
                              offTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          String tone = _isWarmTone ? 'Warm' : 'Cold';
                          String onTimeStr = onTime.format(context);
                          String offTimeStr = offTime.format(context);
                          
                          final newSchedule = {
                            'onTime': onTimeStr,
                            'offTime': offTimeStr,
                            'tone': tone,
                          };

                          // Check for duplicate schedule
                          if (_isScheduleDuplicate(newSchedule)) {
                            _showDuplicateScheduleDialog(context);
                            return;
                          }

                          // Check for existing schedule
                          if (_device.schedules.isNotEmpty) {
                            _showScheduleConflictDialog(
                              context,
                              _device.schedules,
                              newSchedule,
                              () {
                                final roomKey = '${widget.homeName}_${widget.roomName}';
                                final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
                                final updatedDevice = DeviceData(
                                  name: _device.name,
                                  type: _device.type,
                                  icon: _device.icon,
                                  color: _device.color,
                                  isOn: _device.isOn,
                                  schedules: List<Map<String, dynamic>>.from(_device.schedules)..add(newSchedule),
                                );
                                scheduleTickProvider.updateDevice(roomKey, updatedDevice);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
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
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Tone: $tone, Start time: $onTimeStr, End time: $offTimeStr', style: GoogleFonts.poppins()),
                                              Text('New schedule added successfully.', style: GoogleFonts.poppins()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                            return;
                          }

                          // If no existing schedule, add new one
                          final roomKey = '${widget.homeName}_${widget.roomName}';
                          final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
                          final updatedDevice = DeviceData(
                            name: _device.name,
                            type: _device.type,
                            icon: _device.icon,
                            color: _device.color,
                            isOn: _device.isOn,
                            schedules: List<Map<String, dynamic>>.from(_device.schedules)..add(newSchedule),
                          );
                          scheduleTickProvider.updateDevice(roomKey, updatedDevice);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
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
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Tone: $tone, Start time: $onTimeStr, End time: $offTimeStr', style: GoogleFonts.poppins()),
                                        Text('Schedule set by you successfully.', style: GoogleFonts.poppins()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildACScheduleSheet() {
    final List<Map<String, dynamic>> moods = [
      {'label': 'Cool', 'icon': Icons.ac_unit},
      {'label': 'Heat', 'icon': Icons.waves},
      {'label': 'Wind', 'icon': Icons.toys},
      {'label': 'Auto', 'icon': Icons.autorenew},
    ];
    int selectedMood = 0;
    int temperature = 24;
    TimeOfDay offTime = TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: TimeOfDay.now().minute);

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set mood',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(moods.length, (index) {
                      final mood = moods[index];
                      final bool isSelected = selectedMood == index;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            selectedMood = index;
                          });
                        },
                        child: Container(
                          width: 70,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                mood['icon'],
                                color: isSelected ? Colors.white : Colors.grey[400],
                                size: 32,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                mood['label'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? Colors.white : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Temperature',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        iconSize: 32,
                        color: temperature > 16 ? Colors.blue : Colors.grey[300],
                        onPressed: temperature > 16
                            ? () {
                                HapticFeedback.lightImpact();
                                setSheetState(() {
                                  temperature--;
                                });
                              }
                            : null,
                      ),
                      Container(
                        width: 100,
                        alignment: Alignment.center,
                        child: Text(
                          '${temperature.toString().padLeft(2, '0')}°C',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        iconSize: 32,
                        color: temperature < 30 ? Colors.blue : Colors.grey[300],
                        onPressed: temperature < 30
                            ? () {
                                HapticFeedback.lightImpact();
                                setSheetState(() {
                                  temperature++;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Off time',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _timePickerTile(
                  context: context,
                  label: '',
                  time: offTime,
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: offTime,
                    );
                    if (picked != null) {
                      setSheetState(() {
                        offTime = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          final newSchedule = {
                            'mode': moods[selectedMood]['label'],
                            'temperature': temperature,
                            'offTime': offTime.format(context),
                          };

                          // Check for duplicate schedule
                          if (_isScheduleDuplicate(newSchedule)) {
                            _showDuplicateScheduleDialog(context);
                            return;
                          }

                          // Check for existing schedule
                          if (_device.schedules.isNotEmpty) {
                            _showScheduleConflictDialog(
                              context,
                              _device.schedules,
                              newSchedule,
                              () {
                                final roomKey = '${widget.homeName}_${widget.roomName}';
                                final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
                                final updatedDevice = DeviceData(
                                  name: _device.name,
                                  type: _device.type,
                                  icon: _device.icon,
                                  color: _device.color,
                                  isOn: _device.isOn,
                                  schedules: List<Map<String, dynamic>>.from(_device.schedules)..add(newSchedule),
                                );
                                scheduleTickProvider.updateDevice(roomKey, updatedDevice);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
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
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('${moods[selectedMood]['label']} mode, $temperature°C, Off time: ${offTime.format(context)}', style: GoogleFonts.poppins()),
                                              Text('New schedule added successfully.', style: GoogleFonts.poppins()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                            return;
                          }

                          // If no existing schedule, add new one
                          final roomKey = '${widget.homeName}_${widget.roomName}';
                          final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
                          final updatedDevice = DeviceData(
                            name: _device.name,
                            type: _device.type,
                            icon: _device.icon,
                            color: _device.color,
                            isOn: _device.isOn,
                            schedules: List<Map<String, dynamic>>.from(_device.schedules)..add(newSchedule),
                          );
                          scheduleTickProvider.updateDevice(roomKey, updatedDevice);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
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
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('${moods[selectedMood]['label']} mode, $temperature°C, Off time: ${offTime.format(context)}', style: GoogleFonts.poppins()),
                                        Text('Schedule set by you successfully.', style: GoogleFonts.poppins()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFanScheduleSheet() {
    int selectedSpeed = 0;
    TimeOfDay offTime = TimeOfDay(hour: (TimeOfDay.now().hour + 1) % 24, minute: TimeOfDay.now().minute);
    final List<String> speeds = ['1', '2', '3', '4'];

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set speed',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(speeds.length, (index) {
                      final bool isSelected = selectedSpeed == index;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            selectedSpeed = index;
                          });
                        },
                        child: Container(
                          width: 70,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                speeds[index],
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Off time',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _timePickerTile(
                  context: context,
                  label: '',
                  time: offTime,
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: offTime,
                    );
                    if (picked != null) {
                      setSheetState(() {
                        offTime = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          final newSchedule = {
                            'speed': speeds[selectedSpeed],
                            'offTime': offTime.format(context),
                          };

                          // Check for duplicate schedule
                          if (_isScheduleDuplicate(newSchedule)) {
                            _showDuplicateScheduleDialog(context);
                            return;
                          }

                          // Check for existing schedule
                          if (_device.schedules.isNotEmpty) {
                            _showScheduleConflictDialog(
                              context,
                              _device.schedules,
                              newSchedule,
                              () {
                                final roomKey = '${widget.homeName}_${widget.roomName}';
                                final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
                                final updatedDevice = DeviceData(
                                  name: _device.name,
                                  type: _device.type,
                                  icon: _device.icon,
                                  color: _device.color,
                                  isOn: _device.isOn,
                                  schedules: List<Map<String, dynamic>>.from(_device.schedules)..add(newSchedule),
                                );
                                scheduleTickProvider.updateDevice(roomKey, updatedDevice);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.08),
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
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
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Speed ${speeds[selectedSpeed]}, Off time: ${offTime.format(context)}', style: GoogleFonts.poppins()),
                                              Text('New schedule added successfully.', style: GoogleFonts.poppins()),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                            return;
                          }

                          // If no existing schedule, add new one
                          final roomKey = '${widget.homeName}_${widget.roomName}';
                          final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
                          final updatedDevice = DeviceData(
                            name: _device.name,
                            type: _device.type,
                            icon: _device.icon,
                            color: _device.color,
                            isOn: _device.isOn,
                            schedules: List<Map<String, dynamic>>.from(_device.schedules)..add(newSchedule),
                          );
                          scheduleTickProvider.updateDevice(roomKey, updatedDevice);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
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
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Speed ${speeds[selectedSpeed]}, Off time: ${offTime.format(context)}', style: GoogleFonts.poppins()),
                                        Text('Schedule set by you successfully.', style: GoogleFonts.poppins()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  String _weekdayShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  Widget _timePickerTile({
    required BuildContext context,
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  time.format(context),
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug print for schedules
    print('Device: \'${widget.device.name}\' schedules: \'${widget.device.schedules}\'');
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0, top: 21.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xffD3D3D3),
              child: Center(
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black, size: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Delete Device',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Delete Device',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          content: Text(
                            'Are you sure you want to delete ${_device.name}?',
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
                                // Get the room key
                                final roomKey = '${widget.homeName}_${widget.roomName}';
                                
                                // Get current devices for the room
                                final scheduleTickProvider = Provider.of<ScheduleTickProvider>(context, listen: false);
                                final devices = scheduleTickProvider.getDevicesForRoom(roomKey);
                                
                                // Remove the device
                                scheduleTickProvider.removeDevice(roomKey, _device.name);
                                
                                // Close dialogs and return to previous screen
                                Navigator.pop(context); // Close confirmation dialog
                                Navigator.pop(context); // Return to previous screen
                                
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${_device.name} has been deleted',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );

                                // Force refresh the previous screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SpecificRoomScreen(
                                      roomName: widget.roomName,
                                      homeName: widget.homeName,
                                      userName: widget.userName,
                                    ),
                                  ),
                                );
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
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              "Hey ${widget.userName},",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "You are using ${_device.name} of ${widget.roomName}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _device.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _device.color.withOpacity(0.3),
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
                        _device.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _device.isOn ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _device.isOn ? "Connected" : "Disconnected",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_device.schedules.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Scheduled',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: _device.isOn,
                    onChanged: _toggleDevice,
                    activeColor: _device.color,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 31),
            // Icon Container for all devices
            Center(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _isWarmTone 
                          ? _device.color.withOpacity(0.1)
                          : const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isWarmTone 
                            ? _device.color.withOpacity(0.3)
                            : Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _device.icon,
                      size: 80,
                      color: _isWarmTone ? _device.color : Colors.blue,
                    ),
                  ),
                  // Tone Control Section - Only for Smart Light
                  if (_device.type == 'Smart Light') ...[
                    const SizedBox(height: 21),
                    Text(
                      _getControlText(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 21),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isWarmTone ? _device.color.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _toggleTone(true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isWarmTone ? _device.color : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: Text(
                                    'Warm',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: _isWarmTone ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _toggleTone(false),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !_isWarmTone ? Colors.blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cold',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: !_isWarmTone ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 31),
                  // Set Schedule Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue,
                        width: 1,
                      ),
                    ),
                    child: TextButton(
                      onPressed: _showScheduleSheet,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Set Schedule',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
