import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:halox_app/App_Screens/Home%20Bottom%20Nav%20Screens/firstScreen.dart';
import '../App_Utilities/app_utilities.dart';
import '../App_Utilities/validation_utils.dart';
import '../Widgets/widgets.dart';
import 'LoginPage.dart';
import 'Sign_up Page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPassVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FirstScreen(homeName: "", userName: "")),
      );
    }
  }

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
              decoration: const BoxDecoration(
                color: Colors.white
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 34),
                child: Text(
                  "Welcome back!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primaryBlueColor),
                  textAlign: TextAlign.center,
                ),
              ),
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
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Text(
                              "Sign In",
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

                        // Email
                        Text("Email", style: mTextStyle14()),
                        CustomTextField(
                          controller: _emailController,
                          hintText: "abc@gmail.com",
                          prefixIcon: Icons.email_outlined,
                          fillColor: Colors.white60,
                          validator: ValidationUtils.validateEmail,
                        ),
                        const SizedBox(height: 15),

                        // Password
                        Text("Password", style: mTextStyle14()),
                        CustomTextField(
                          controller: _passwordController,
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
                          validator: ValidationUtils.validatePassword,
                        ),
                        const SizedBox(height: 15),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password functionality
                            },
                            child: Text(
                              "Forgot Password?",
                              style: mTextStyle14(
                                mColor: AppColors.primaryBlueColor,
                                mFontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlueColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              "SIGN IN",
                              style: mTextStyle16(
                                mColor: Colors.white,
                                mFontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sign in with google
                        googleBar(
                          text: "Sign in with Google",
                          imgUrl: "assets/icons/google.svg",
                        ),
                        const SizedBox(height: 20),

                        // Don't have an account?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?", style: mTextStyle14()),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => SignUpPage()),
                                );
                              },
                              child: Text(
                                "Sign Up",
                                style: mTextStyle14(
                                  mColor: AppColors.primaryBlueColor,
                                  mFontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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