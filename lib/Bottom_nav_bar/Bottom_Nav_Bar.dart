import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:halox_app/App_Screens/Schedule%20Screen.dart';
import 'package:halox_app/App_Screens/Settings%20Screen/Settings_Screen.dart';
import 'package:halox_app/App_Screens/Statistics_Screen.dart';
import 'package:halox_app/App_Screens/Home%20Bottom%20Nav%20Screens/firstScreen.dart';
import 'package:halox_app/App_Utilities/app_utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';




class BottomNavBar extends StatefulWidget {
  final String fullName;
  final String? Occupation;
  final String phoneNumb;
  final String email;
  final String homeName;
  BottomNavBar({required this.fullName, required this.email, required this.phoneNumb, this.Occupation, required this.homeName});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    super.initState();
    _saveHomeName();
  }

  void _saveHomeName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("home_name", widget.homeName);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      FirstScreen(homeName: widget.homeName, userName: widget.fullName,),
      StatisticsScreen(),
      ScheduleScreen(),
      SettingsScreen(
        fullName: widget.fullName,
        email: widget.email,
        phoneNumb: widget.phoneNumb,
        occupation: widget.Occupation,
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedLabelStyle: mTextStyle18(),
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryBlueColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 32,), label: 'Home',),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart, size: 32,), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.cable, size: 32,), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.settings, size: 32,), label: 'Settings'),
        ],
      ),
    );
  }
}