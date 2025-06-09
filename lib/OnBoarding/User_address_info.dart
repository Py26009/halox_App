import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:halox_app/App_Screens/Home_Setup_InitialPage.dart';
import 'package:halox_app/App_Utilities/app_utilities.dart';
import 'package:lottie/lottie.dart';

import '../Bottom_nav_bar/Bottom_Nav_Bar.dart';
import '../Widgets/widgets.dart';

class AddressInfoScreen extends StatefulWidget {

  final String fullName;
  final String? Occupation;
  final String email;
  final String phoneNumb;

  AddressInfoScreen({required this.fullName, this.Occupation, required this.email, required this.phoneNumb});

  @override
  _AddressInfoScreenState createState() => _AddressInfoScreenState();
}

class _AddressInfoScreenState extends State<AddressInfoScreen> {
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Address Information'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Progress
            _buildStepIndicator(),

            const SizedBox(height: 70),

            // Street
            Text("Street Address",),
            CustomTextField(
              controller: streetController,
                hintText: "Street Address",
                prefixIcon: Icons.home,
                fillColor: Colors.white60
              ),


            const SizedBox(height: 20),

            // City
            Text("City"),
            CustomTextField(
              controller: cityController,
                hintText: "New Delhi",
                prefixIcon: Icons.location_city,
                fillColor: Colors.white60
            ),

            const SizedBox(height: 20),

            // State
            Text("State"),
            CustomTextField(
              controller: stateController,
                hintText: "New Delhi",
                prefixIcon: Icons.map,
                fillColor: Colors.white60
            ),
            const SizedBox(height: 20),

            // Zip Code
            Text("Zip Code"),
            CustomTextField(
              controller: zipController,
              hintText: "110001",
              keyboardType: TextInputType.number,
                prefixIcon: Icons.pin_drop,
                fillColor: Colors.white60
            ),


            const SizedBox(height: 50),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: ()async {
                      await  showDialog(context: context,
                      barrierDismissible: false,
                      builder: (context){
                        Future.delayed(Duration(seconds: 3,),(){
                          Navigator.of(context).pop();
                        });
                        return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(padding: EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset("assets/icons/Successful_lottie.json", height: 120,width: 120,),
                                const SizedBox(height: 21,),
                                Text("'Congratulations!",style: mTextStyle24(mFontWeight: FontWeight.w700),),
                                const SizedBox(height: 11,),
                                const Text('You have successfully created your account.'),
                                const SizedBox(height: 20),
                              ],
                            ),),
                        );
                      });

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeSetupInitialPage(
                        fullName: widget.fullName,
                        Occupation: widget.Occupation,
                        email: widget.email,
                        phoneNumb: widget.phoneNumb,
                      )));
                    },
                    child: Text("Finish", style: mTextStyle16(mColor: Colors.white),),
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
        _buildStepCircle(true),
        _buildStepLine(),
        _buildStepCircle(false),
      ],
    );
  }

  Widget _buildStepCircle(bool isActive) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.blue : Colors.grey.shade300,
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