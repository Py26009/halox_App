import 'package:flutter/material.dart';
import 'package:halox_app/App_Utilities/app_utilities.dart';
import 'package:halox_app/Widgets/widgets.dart';

import 'User_address_info.dart';

class BasicDetailsScreen extends StatefulWidget {
  final String name;
  final String email;
  BasicDetailsScreen({required this.name, required this.email});

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsState();
}

class _BasicDetailsState extends State<BasicDetailsScreen> {

  TextEditingController userNameController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userNameController.text = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic Information', style: mTextStyle24(),),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Step Progress
            _buildStepIndicator(),

            const SizedBox(height: 30),

            // Avatar with edit button
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: (){

                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Name TextField
            Text("Full Name"),
            CustomTextField(
              controller: userNameController,
             hintText: "Enter your name",
                prefixIcon: Icons.person,
              fillColor: Colors.white60,
            ),


            const SizedBox(height: 20),

            // Occupation TextField
            Text("Occupation (Optional)"),
            CustomTextField(
              controller: occupationController,
                hintText: "Enter your occupation",
                prefixIcon: Icons.work,
                fillColor: Colors.white60
            ),

            const SizedBox(height: 20),

            // Phone number TextField
            Text("Phone Number"),
            CustomTextField(
                controller: phoneController,
                hintText: "+91",
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
                fillColor: Colors.white60
            ),
            const SizedBox(height: 50),



            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>AddressInfoScreen(
                       fullName: widget.name,
                       Occupation: occupationController.text,
                       email: widget.email,
                       phoneNumb: phoneController.text,
                     )));
                    },
                    child: Text("Continue", style: mTextStyle16(mColor: Colors.white),),
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel", style: mTextStyle16(),),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(true),
        _buildStepLine(),
        _buildStepCircle(false),
        _buildStepLine(),
        _buildStepCircle(false),
      ],
    );
  }

  Widget _buildStepCircle(bool isActive) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primaryBlueColor : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 100,
      height: 2,
      color: Colors.grey.shade400,
    );
  }
}

