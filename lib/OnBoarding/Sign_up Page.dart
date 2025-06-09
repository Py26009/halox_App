import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:halox_app/OnBoarding/Basic_details.dart';
import 'package:halox_app/OnBoarding/LoginPage.dart';
import 'package:halox_app/Widgets/widgets.dart';
import 'package:flutter/cupertino.dart';

import '../App_Utilities/app_utilities.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reEnterPassController = TextEditingController();

  bool isPassVisible = false;
  bool isRePassVisible = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(

      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Top Illustration with border radius
            Container(
              decoration: BoxDecoration(
                color: Colors.white
              ),
              child:Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 34),
                child: Text(" Save time, money and energy", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primaryBlueColor),textAlign: TextAlign.center,),
              ) ,
            ),

            // Bottom Sheet (Form)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Text(
                            "Let's get started!",
                            style: mTextStyle26(mColor: AppColors.primaryBlueColor),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 30,
                            width: 30,
                            child: Image.network(
                              "https://img.icons8.com/?size=96&id=19209&format=png",
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Name
                      Text("Name", style: mTextStyle14()),
                      CustomTextField(
                        controller: _nameController,
                        hintText: "Enter your name",
                        prefixIcon: Icons.person_outline,
                        fillColor: Colors.white60,
                      ),
                      const SizedBox(height: 15),

                      // Email
                      Text("Email", style: mTextStyle14()),
                      CustomTextField(
                        controller: _emailController,
                        hintText: "abc@gmail.com",
                        prefixIcon: Icons.email_outlined,
                        fillColor: Colors.white60,
                      ),
                      const SizedBox(height: 15),

                      // Password
                      Text("Password", style: mTextStyle14()),
                      CustomTextField(
                        controller: _passController,
                        hintText: "******",
                        obscureText: !isPassVisible,
                        prefixIcon: Icons.lock,
                        fillColor: Colors.white60,
                        suffixIcon: isPassVisible
                            ? Icons.visibility
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () {
                          setState(() {
                            isPassVisible = !isPassVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // Re-enter Password
                      Text("Re-enter Password", style: mTextStyle14()),
                      CustomTextField(
                        controller: _reEnterPassController,
                        hintText: "******",
                        obscureText: !isRePassVisible,
                        prefixIcon: Icons.lock_open,
                        fillColor: Colors.white60,
                        suffixIcon: isRePassVisible
                            ? Icons.visibility
                            : Icons.visibility_off_outlined,
                        onSuffixTap: () {
                          setState(() {
                            isRePassVisible = !isRePassVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 25),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>BasicDetailsScreen(
                              name: _nameController.text,
                              email: _emailController.text,
                            )));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlueColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            "SIGN UP",
                            style: mTextStyle16(
                                mColor: Colors.white, mFontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign up with google
                      googleBar(
                        text: "Sign in with Google",
                        imgUrl: "assets/icons/google.svg",
                      ),
                      const SizedBox(height: 20),


                      // Already a user?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already a user?", style: mTextStyle14()),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => LoginPage()),
                              );
                            },
                            child: Text(
                              "Sign In",
                              style: mTextStyle14(
                                  mColor: AppColors.primaryBlueColor,
                                  mFontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
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
  }
}
