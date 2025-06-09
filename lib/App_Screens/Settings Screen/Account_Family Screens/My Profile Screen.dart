import 'package:flutter/material.dart';
import 'package:halox_app/App_Utilities/app_utilities.dart';
import 'package:provider/provider.dart';

import '../../../State Management/Provider State management/User Data Provider/User Data Provider.dart';

class ProfilePage extends StatefulWidget {
  final String fullName;
  final String email;
  final String phoneNumb;
  final String? occupation;

  const ProfilePage({
    required this.fullName,
    required this.email,
    required this.phoneNumb,
    this.occupation,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;

  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController occupationController;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    fullNameController = TextEditingController(text: widget.fullName);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phoneNumb);
    occupationController = TextEditingController(text: widget.occupation);
  }
  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    occupationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlueColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isEditing = true;
            fullNameController.clear();
            emailController.clear();
            phoneController.clear();
            occupationController.clear();
          });
        },
        backgroundColor: AppColors.primaryBlueColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            height: mediaQuery.size.height * 0.32,
            decoration: BoxDecoration(
              color: AppColors.primaryBlueColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(200),
                bottomRight: Radius.circular(200),
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                ),
                SizedBox(height: 12),
                Text(
                  "My Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildPrefilledTextField(Icons.person, "Full Name", fullNameController, isEditing),
                    SizedBox(height: 16),
                    buildPrefilledTextField(Icons.email, "Email", emailController, false),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text(
                        "You can't change your registered email.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    buildPrefilledTextField(Icons.phone, "Phone", phoneController, isEditing),
                    SizedBox(height: 16),
                    buildPrefilledTextField(Icons.work, "Occupation", occupationController, isEditing),
                    SizedBox(height: 30),
                    if (isEditing)
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isEditing = true;
                            });
                            final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                            profileProvider.updateProfile(
                              fullName: fullNameController.text,
                              email: emailController.text,
                              phoneNumb: phoneController.text,
                              occupation: occupationController.text,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Changes saved Successfully")));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlueColor,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildPrefilledTextField(IconData icon, String label, TextEditingController controller, bool enabled) {
  return TextField(
    controller: controller,
    enabled: enabled,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey.shade700),
      labelText: label,
      labelStyle: TextStyle(fontWeight: FontWeight.w500),
      filled: true,
      fillColor: Colors.grey.shade100,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blue.shade300),
      ),
    ),
  );
}

