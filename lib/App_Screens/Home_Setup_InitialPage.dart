import 'package:flutter/material.dart';
import 'package:halox_app/App_Utilities/app_utilities.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Bottom_nav_bar/Bottom_Nav_Bar.dart';
import '../State Management/Provider State management/User Data Provider/home_name Provider.dart';

class HomeSetupInitialPage extends StatefulWidget {
  final String fullName;
  final String ? Occupation;
  final String  email;
  final String phoneNumb;

  HomeSetupInitialPage({required this.phoneNumb, required this.email, required this.fullName, this.Occupation});

  @override
  State<HomeSetupInitialPage> createState() => _HomeSetupInitialPageState();
}

class _HomeSetupInitialPageState extends State<HomeSetupInitialPage> {

  TextEditingController roomNameController = TextEditingController(text: "Default Home");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 11,),
          Image.network("https://th.bing.com/th/id/OIP.U_yJUqgdrZvxtPhDbLfZpwHaE8?w=350&h=191&c=7&r=0&o=5&dpr=1.3&pid=1.7"),
          SizedBox(height: 11,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text("You've set up your account. Now set up your home.", style: mTextStyle24(mFontWeight: FontWeight.w700),textAlign: TextAlign.center,),
          ),
          SizedBox(height: 21,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text("We have created a default Home, you can either re-name it or simply continue.",style: mTextStyle16(mFontWeight: FontWeight.w300),textAlign: TextAlign.center ),
          ),
          SizedBox(height: 41,),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (){
                      showDialog(
                        context: context,
                        builder: (context) {
                         // TextEditingController roomNameController = TextEditingController(text: "Default Room");
                          return AlertDialog(
                            title: Text("Rename Home"),
                            content: TextField(
                              controller: roomNameController,
                              decoration: InputDecoration(hintText: "Enter your Home name"),
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
                                  String newRoomName = roomNameController.text.trim();
                                  if (newRoomName.isNotEmpty) {
                                    // Do something with newRoomName, e.g., update state or call an API
                                    print("New Room Name: $newRoomName");
                                  }
                                  Navigator.of(context).pop(); // Close dialog
                                },
                                child: Text("Save"),
                              ),
                            ],
                          );
                        },
                      );
                      },
                    child: Text("Re-name", style: mTextStyle18(mColor: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlueColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: (){
                      final homeName = roomNameController.text.trim();
                      if (homeName.isNotEmpty) {
                        context.read<HomeNameProvider>().setHomeName(homeName);
                      }
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => BottomNavBar(
                          fullName: widget.fullName,
                          Occupation: widget.Occupation,
                          email: widget.email,
                          phoneNumb: widget.phoneNumb,
                          homeName: roomNameController.text,
                        ),
                      ));
                    },
                    child: Text("Continue", style: mTextStyle18(),),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
