import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:halox_app/App_Screens/Settings%20Screen/Account_Family%20Screens/Forgot%20password%20Screen.dart';
import 'package:halox_app/App_Screens/Home%20Bottom%20Nav%20Screens/firstScreen.dart';
import 'package:halox_app/Bottom_nav_bar/Bottom_Nav_Bar.dart';

import '../App_Utilities/app_utilities.dart';
import '../Widgets/widgets.dart';
import 'Sign_up Page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPassVisible = false;
  bool isRememberMe = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              reverse: true,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo and Welcome Text
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/halox_logo.png',
                              height: size.height * 0.15,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Welcome Back!",
                              style: mTextStyle18(
                                mFontWeight: FontWeight.w600,
                                mColor: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Expanded login form
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sign in to Your Account",
                                style: mTextStyle24(
                                  mFontWeight: FontWeight.w500,
                                  mColor: AppColors.primaryBlueColor,
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Email
                              Text("Email", style: mTextStyle14()),
                              CustomTextField(
                                controller: emailController,
                                hintText: "abc@gmail.com",
                                prefixIcon: Icons.email_outlined,
                                fillColor: Colors.white60,
                              ),
                              const SizedBox(height: 20),

                              // Password
                              Text("Password", style: mTextStyle14()),
                              CustomTextField(
                                controller: passwordController,
                                obscureText: !isPassVisible,
                                hintText: "********",
                                prefixIcon: Icons.lock,
                                suffixIcon: isPassVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off_outlined,
                                onSuffixTap: () {
                                  setState(() {
                                    isPassVisible = !isPassVisible;
                                  });
                                },
                                fillColor: Colors.white60,
                              ),
                              const SizedBox(height: 14),

                              // Remember Me + Forgot Password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4)),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        value: isRememberMe,
                                        onChanged: (value) {
                                          setState(() {
                                            isRememberMe = value ?? false;
                                          });
                                        },
                                      ),
                                      Text("Remember Me", style: mTextStyle14()),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetPasswordScreen()));
                                    },
                                    child: Text("Forgot Password?",
                                        style: mTextStyle14(mColor: Colors.red)),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Sign in button
                             blueContainer(text: "SIGN IN",
                             onTap: (){
                               Navigator.push(context, MaterialPageRoute(builder: (context)=>BottomNavBar(
                                 fullName:  '',
                                 email: emailController.text,
                                 phoneNumb: '',
                                 Occupation: null,
                                 homeName: "",
                               )));
                             }),

                              const SizedBox(height: 25),

                              // Google sign-in
                              googleBar(
                                text: "Sign in with Google",
                                imgUrl: "assets/icons/google.svg",
                              ),

                              const SizedBox(height: 25),

                              // Sign up prompt
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("New user?", style: mTextStyle14()),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SignUpPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Create an account",
                                      style: mTextStyle14(
                                        mColor: AppColors.primaryBlueColor,
                                        mFontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
    );
  }
  }

// Custom Google login bar widget
Widget googleBar({required String text, String? imgUrl, VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imgUrl != null) ...[
            SvgPicture.asset(imgUrl, height: 20, width: 20),
            SizedBox(width: 10),
          ],
          Text(
            text,
            style: mTextStyle14(mFontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}