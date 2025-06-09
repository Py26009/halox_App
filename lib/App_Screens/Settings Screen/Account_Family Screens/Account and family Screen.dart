import 'package:flutter/material.dart';
import 'package:halox_app/App_Screens/Settings%20Screen/Account_Family%20Screens/My%20Profile%20Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../App_Utilities/app_utilities.dart';
import '../../../Widgets/widgets.dart';
import 'Forgot password Screen.dart';

class Account_FamilyScreen extends StatefulWidget {
  final String fullName;
  final String ? Occupation;
  final String email;
  final String phone;

  Account_FamilyScreen({required this.email, required this.fullName, required this.phone, this.Occupation});

  @override
  State<Account_FamilyScreen> createState() => _Account_FamilyScreenState();
}

class _Account_FamilyScreenState extends State<Account_FamilyScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 11.0),
          child: Text("Account and Family"),
        ),
        backgroundColor: Colors.grey.shade50,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Image.asset("assets/images/family_image.jpg"),
              const SizedBox(height: 31,),
              buildSettingsGroup([
                SettingsItem(
                    icon: Icons.person,
                    title: 'My Profile',
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(
                        fullName: widget.fullName,
                        occupation: widget.Occupation,
                        phoneNumb: widget.phone,
                        email: widget.email,
                      )));
                    },
                ),
                SettingsItem(
                  icon: Icons.lock,
                  title: 'Change Password',
                  onTap: (){
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetPasswordScreen()));
                  },
                ),
                SettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: (){
                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>Account_FamilyScreen()));
                  },
                ),
                SettingsItem(
                  icon: Icons.group,
                  title: 'Family Members',
                  onTap: (){
                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>Account_FamilyScreen()));
                  },
                ),
                SettingsItem(
                  icon: Icons.delete,
                  title: 'Delete Account',
                  titleColor: Colors.red,
                  onTap: (){
                    _showDeleteAccountDialog(context);
                  },
                ),

              ]),
            ],
          ),
        ),
      ),
    );
  }
}





/// Delete Account Dialogue Box

void _showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to log Out your account? ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete account logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlueColor),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}