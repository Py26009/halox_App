import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'App_Screens/Home Bottom Nav Screens/Device_Specific_Screen.dart';
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
import 'State Management/BLoC/device_usage/device_usage_event.dart';
import 'State Management/Provider State management/User Data Provider/All homes list provider.dart';
import 'State Management/Provider State management/User Data Provider/User Data Provider.dart';
import 'State Management/Provider State management/User Data Provider/home_name Provider.dart';
import 'State Management/BLoC/room/room_bloc.dart';
import 'State Management/BLoC/device_usage/device_usage_bloc.dart';
import 'package:halox_app/State Management/Provider State management/User Data Provider/Device Provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            fullName: "",
            email: "",
            phoneNumb: "",
            occupation: "",
          ),
        ),
        ChangeNotifierProvider(create: (_) => HomeNameProvider()),
        ChangeNotifierProvider(create: (_) => HomeListProvider()),
        BlocProvider(create: (_) => RoomBloc(prefs: prefs)),
        BlocProvider(create: (_) => DeviceUsageBloc(prefs: prefs)..add(LoadDeviceUsage())),
        Provider<SharedPreferences>.value(value: prefs),
        ChangeNotifierProvider(create: (_) => ScheduleTickProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

