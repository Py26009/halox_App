import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../App_Utilities/app_utilities.dart';



/// CUSTOMIZED TEXTFIELD
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final int ? maxLines;


  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.onSuffixTap,
    this.obscureText = false,
    this.validator,
    this.fillColor,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText ,
          keyboardType: keyboardType,
          validator: validator,
          maxLines:obscureText == true ? 1 : (maxLines ?? 1),
          style: mTextStyle14(),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor ?? Colors.white60,
            hintText: hintText,
            labelText: labelText,
            hintStyle: mTextStyle14(
              mFontWeight: FontWeight.w500,
              mColor: const Color(0xffBCC1CA),
            ),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
              onTap: onSuffixTap,
              child: Icon(
                suffixIcon,
                size: 20,
                color: const Color(0xffBCC1CA),
              ),
            )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // maintain height
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:  BorderSide(width: 2, color:Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:  BorderSide(width: 2, color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(width: 1.5, color: Theme.of(context).primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(width: 1, color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 1.5, color: Colors.red),
            ),
            errorStyle: const TextStyle(
              fontSize: 12,
              height: 1.0, // Control line height
            ),
          ),
        ),
        // const SizedBox(height: 12), // spacing between fields
      ],
    );
  }
}

/// Common Red Button
Widget blueContainer({required String text, VoidCallback ? onTap}){
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 42,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryBlueColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Text(text, style: mTextStyle14(mColor: Colors.white),)),
    ),
  );
}


/// List format for all settings options
Widget buildSettingsGroup(List<SettingsItem> items) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: items.asMap().entries.map((entry) {
        int index = entry.key;
        SettingsItem item = entry.value;
        bool isLast = index == items.length - 1;
        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              leading: Icon(
                item.icon,
                color: item.titleColor ?? Colors.grey.shade700,
                size: 24,
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: item.titleColor ?? Colors.grey.shade900,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
              onTap: item.onTap,
            ),
            if (!isLast)
              Divider(
                height: 1,
                indent: 64,
                endIndent: 20,
                color: Colors.grey.shade200,
              ),
          ],
        );
      }).toList(),
    ),
  );
}


/// On log out Dialog Box
void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement logout logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

class SettingsItem {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  SettingsItem({
    required this.icon,
    required this.title,
    this.titleColor,
    required this.onTap,
  });
}


