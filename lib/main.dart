import 'package:flutter/material.dart';
import 'package:halox_app/Bottom_nav_bar/Bottom_Nav_Bar.dart';
import 'package:halox_app/State%20Management/Provider%20State%20management/User%20Data%20Provider/All%20homes%20list%20provider.dart';
import 'package:provider/provider.dart';
import 'App_Screens/Home Bottom Nav Screens/Specific room Screen.dart';
import 'App_Screens/Home_Setup_InitialPage.dart';
import 'App_Screens/Settings Screen/Account_Family Screens/Account and family Screen.dart';
import 'App_Screens/Settings Screen/Account_Family Screens/Forgot password Screen.dart';
import 'App_Screens/Settings Screen/Account_Family Screens/My Profile Screen.dart';
import 'App_Screens/Settings Screen/My Places Screen.dart';
import 'App_Screens/Settings Screen/Settings_Screen.dart';
import 'App_Screens/Home Bottom Nav Screens/firstScreen.dart';
import 'OnBoarding/Basic_details.dart';
import 'OnBoarding/LoginPage.dart';
import 'OnBoarding/Sign_up Page.dart';
import 'Splash_Screen/splash screen.dart';
import 'State Management/Provider State management/User Data Provider/User Data Provider.dart';
import 'State Management/Provider State management/User Data Provider/home_name Provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider(
          fullName: "",
          email: "",
          phoneNumb: "",
          occupation: "",
        )),
        ChangeNotifierProvider(create: (_) => HomeNameProvider()),
        ChangeNotifierProvider(create: (_) => HomeListProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:LoginPage()
    );
  }
}

