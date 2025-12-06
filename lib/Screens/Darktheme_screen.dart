import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Providers/ThemeModeProvider.dart';

class DarkthemeScreen extends StatelessWidget {
  const DarkthemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dark Theme")),
      body: const DarkThemeSwitcher(),
    );
  }
}

class DarkThemeSwitcher extends StatefulWidget {
  const DarkThemeSwitcher({super.key});

  @override
  State<DarkThemeSwitcher> createState() => _DarkThemeSwitcherState();
}

class _DarkThemeSwitcherState extends State<DarkThemeSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          margin: EdgeInsets.all(20),
          child: ListTile(
            title: Text('Dark theme'),
            trailing: themeProvider.isDark
                ? Icon(Icons.dark_mode, color: Colors.blue)
                : Icon(Icons.light_mode, color: Colors.amberAccent),
            leading: Switch(
              value: themeProvider.isDark,
              onChanged: (value) {
                themeProvider.changeThemeMode(value);
              },
            ),
          ),
        );
      },
    );
  }
}
