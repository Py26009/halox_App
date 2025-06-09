import 'package:flutter/material.dart';
import 'package:halox_app/App_Utilities/app_utilities.dart';
import 'package:halox_app/Widgets/widgets.dart';
import 'package:lottie/lottie.dart';

class ForgetPasswordScreen extends StatelessWidget {
 TextEditingController emlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 11.0),
          child: Text("Forgot Password"),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 21,),
              Center(child: Lottie.asset("assets/icons/confused_animation.json", height: 150,width: 200,)),
              const SizedBox(height: 31,),
              Center(child: Text("Forgot your password?", style: mTextStyle28(),)),
              const SizedBox(height: 21,),
              Text("Enter your registered email below, to get password reset instructions ", style: mTextStyle16(mColor: Colors.grey,mFontWeight: FontWeight.w400),textAlign: TextAlign.center,),
              const SizedBox(height: 31,),
              Text("Email"),
              CustomTextField(controller: emlController, hintText: "Enter your registered email", prefixIcon: Icons.email,),
              const SizedBox(height: 260,),
              blueContainer(text: "SEND")


            ],
          ),
        ),
      ),
    );
  }
}
