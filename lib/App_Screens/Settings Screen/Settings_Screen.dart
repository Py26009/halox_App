import 'package:flutter/material.dart';
import 'package:halox_app/App_Screens/Settings%20Screen/FEEDBACK%20AND%20SUPPORT/feedback_and_Support.dart';
import 'package:halox_app/Bottom_nav_bar/Bottom_Nav_Bar.dart';
import 'package:provider/provider.dart';
import '../../App_Utilities/app_utilities.dart';
import '../../State Management/Provider State management/User Data Provider/home_name Provider.dart';
import 'Account_Family Screens/Account and family Screen.dart';
import 'My Places Screen.dart';

class SettingsScreen extends StatelessWidget {
  final String fullName;
  final String email;
  final String phoneNumb;
  final String? occupation;

  const SettingsScreen({
    required this.fullName,
    required this.email,
    required this.phoneNumb,
    this.occupation,


  }) ;

  @override
  Widget build(BuildContext context) {
    final homeName = context.watch<HomeNameProvider>().homeName;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>BottomNavBar(
            fullName: fullName,
            email: email,
            phoneNumb: phoneNumb,
            Occupation: occupation,
            homeName: homeName,
          ))),
        ),
        title:  Padding(
          padding: const EdgeInsets.only(top: 11.0),
          child: Text(
            'Settings',
           style: mTextStyle24(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/150?img=5',
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name and Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          fullName,
                          style: mTextStyle18(),
                        ),
                        const SizedBox(height: 4),
                        Text(
                         email,
                          style: mTextStyle14(mColor: Colors.grey.shade600)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // General Section
            Text(
              'GENERAL',
              style: mTextStyle18(mFontWeight: FontWeight.w500)
            ),
            const SizedBox(height: 16),

            buildSettingsGroup([
              SettingsItem(
                icon: Icons.person_outline,
                title: 'Account and Family',
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Account_FamilyScreen(
                    fullName: fullName,
                    Occupation: occupation,
                    phone: phoneNumb,
                    email: email,
                  )));
                },
              ),
              SettingsItem(
                icon: Icons.home,
                title: 'My Home',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MyPlacesScreen()));
                },
              ),
              SettingsItem(
                icon: Icons.door_front_door_outlined,
                title: 'My Rooms',
                onTap: () {
                },
              ),
              SettingsItem(
                icon: Icons.devices,
                title: 'My Devices',
                onTap: () {
                  // Handle logout tap
                  showLogoutDialog(context);
                },
              ),
              SettingsItem(
                icon: Icons.logout,
                title: 'Log Out',
                titleColor: Colors.red,
                onTap: () {
                  // Handle delete account tap
                  showLogoutDialog(context);
                },
              ),
            ]),

            const SizedBox(height: 30),

            // Others Selection
            Text("OTHERS",
                style: mTextStyle18(mFontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            buildSettingsGroup([
              SettingsItem(icon: Icons.book,
                  title: "User Manual", onTap: (){}
              ),
              SettingsItem(icon: Icons.share,
                  title: "Tell your friends", onTap: (){}
              ),
              SettingsItem(icon: Icons.shop,
                  title: "Shop more products", onTap: (){}
              ),
              SettingsItem(icon: Icons.fingerprint,
                  title: "Bio-metric Lock", onTap: (){}
              ),
            ]),
            const SizedBox(height: 30),

            // Feedback Section
            Text(
              'FEEDBACK AND SUPPORT',
              style: mTextStyle18(mFontWeight: FontWeight.w500)
            ),
            const SizedBox(height: 16),

            buildSettingsGroup([
              SettingsItem(
                icon: Icons.warning_amber_outlined,
                title: 'Report a bug',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>FeedbackAndSupportScreen(title: "Report a bug", ques: "issue")));
                },
              ),
              SettingsItem(
                icon: Icons.help_center,
                title: 'Help and Support',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>FeedbackAndSupportScreen(title: "Help and Support", ques: "Question")));
                },
              ),

            ]),

            const SizedBox(height: 100), // Extra space for bottom navigation
          ],
        ),
      ),
    );
  }

  /// List format for all settings options
  Widget buildSettingsGroup(List<SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          SettingsItem item = entry.value;
          bool isLast = index == items.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                leading: Icon(
                  item.icon,
                  color: item.titleColor ?? Colors.grey.shade700,
                  size: 24,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: item.titleColor ?? Colors.grey.shade900,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
                onTap: item.onTap,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 64,
                  endIndent: 20,
                  color: Colors.grey.shade200,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }


  /// On log out Dialog Box
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement logout logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlueColor),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }


}

class SettingsItem {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  SettingsItem({
    required this.icon,
    required this.title,
    this.titleColor,
    required this.onTap,
  });
}
