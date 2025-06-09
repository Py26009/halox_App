import 'package:flutter/cupertino.dart';

import 'User Profile Model.dart';

class ProfileProvider extends ChangeNotifier {
  String fullName;
  String email;
  String phoneNumb;
  String occupation;

  ProfileProvider({
    required this.fullName,
    required this.email,
    required this.phoneNumb,
    this.occupation = '',
  });

  void updateProfile({
    required String fullName,
    required String email,
    required String phoneNumb,
    String? occupation,
  }) {
    this.fullName = fullName;
    this.email = email;
    this.phoneNumb = phoneNumb;
    this.occupation = occupation ?? '';
    notifyListeners();
  }
}
