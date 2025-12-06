// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> ListTiles = [
      SettingsListTile(
        icon: Icons.circle_notifications,
        title: 'notifications',
        onTap: () {},
      ),
      SettingsListTile(
        icon: Icons.dark_mode,
        title: 'darktheme',
        onTap: () {
          Navigator.pushNamed(context, 'darktheme');
        },
      ),
      SettingsListTile(
        icon: Icons.headphones,
        title: 'help and support',
        onTap: () {},
      ),
      SettingsListTile(
        icon: Icons.question_mark_sharp,
        title: 'about',
        onTap: () {},
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Container(child: ListView(children: ListTiles)),
    );
  }
}

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title, style: TextStyle(fontSize: 18)),
          trailing: Icon(Icons.arrow_forward_ios, size: 14),
          onTap: onTap,
        ),
        Divider(),
      ],
    );
  }
}
