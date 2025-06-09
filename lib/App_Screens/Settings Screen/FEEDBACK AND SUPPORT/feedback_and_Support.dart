import 'package:flutter/material.dart';
import 'package:halox_app/App_Utilities/app_utilities.dart';
import 'package:halox_app/Widgets/widgets.dart';

class FeedbackAndSupportScreen extends StatelessWidget {
  final String title;
  final String ques;
  FeedbackAndSupportScreen({required this.title, required this.ques});

  @override
  Widget build(BuildContext context) {
    TextEditingController eController = TextEditingController();
    TextEditingController msgController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text("$title"),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email",style: mTextStyle18(mFontWeight: FontWeight.w900, mColor: Colors.grey.shade500),),
              SizedBox(height: 3,),
              CustomTextField(controller: eController, hintText:"Enter your email", fillColor: Colors.white38,),
              const SizedBox(height: 31,),
              Text("Let us hear your $ques",style: mTextStyle18(mFontWeight: FontWeight.w900, mColor: Colors.grey.shade500)),
              const SizedBox(height: 3,),
              CustomTextField(controller:msgController , hintText: "Let us know you thought", maxLines: 10,fillColor: Colors.white38),
              const SizedBox(height: 70,),
              blueContainer(text: "SEND",)
            ],
          ),
        ),
      ),
    );
  }
}
