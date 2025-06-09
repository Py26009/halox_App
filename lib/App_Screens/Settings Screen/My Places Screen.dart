import 'package:flutter/material.dart';
import 'package:halox_app/App_Utilities/app_utilities.dart';

import '../../Widgets/widgets.dart';

class MyPlacesScreen extends StatefulWidget {
  @override
  State<MyPlacesScreen> createState() => _MyPlacesScreenState();
}

class _MyPlacesScreenState extends State<MyPlacesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 11.0),
          child: Text("My Places"),
        ),
        backgroundColor: Colors.grey.shade50,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Image.asset("assets/images/workPlace.jpeg"),
              const SizedBox(height: 31),
              buildSettingsGrp(context, [
                SettingsItem(
                  icon: Icons.laptop,
                  title: 'Office',
                  onTap: () {},
                ),
                SettingsItem(
                  icon: Icons.home,
                  title: 'My Home',
                  onTap: () {},
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildSettingsGrp(BuildContext context, List<SettingsItem> items) {
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      showEditDialog(context, item.title);
                    },
                    child: Icon(Icons.edit, color: AppColors.primaryBlueColor),
                  ),
                  SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      showDeleteDialog(context, item.title);
                    },
                    child: Icon(Icons.delete, color: Colors.red),
                  )
                ],
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

/// Show edit dialog
void showEditDialog(BuildContext context, String currentName) {
  final TextEditingController controller = TextEditingController(text: currentName);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Edit Place Name"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter new name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Renamed to "$newName"')),
              );
            },
            child: Text("Save"),
          ),
        ],
      );
    },
  );
}

/// Show delete confirmation dialog
void showDeleteDialog(BuildContext context, String name) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Delete Place"),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"$name" deleted')),
              );
            },
            child: Text("Delete", style: mTextStyle14(mColor: Colors.white60),),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      );
    },
  );
}
