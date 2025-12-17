import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/Providers/TasksProvider.dart';
import 'package:to_do_list/Providers/ThemeModeProvider.dart';
import 'package:to_do_list/Providers/notification_provider.dart';
import 'package:to_do_list/Screens/Darktheme_screen.dart';
import 'package:to_do_list/Screens/archived_Tasks_screen.dart';
import 'package:to_do_list/Screens/homePage.dart';
import 'package:to_do_list/Screens/Settings_screen.dart';
import 'package:to_do_list/Screens/notification_screen.dart';
import 'package:to_do_list/Screens/statistics_screen.dart';
import 'package:to_do_list/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => ThemeModeProvider(isDark)),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: ToDoList(),
    ),
  );
}

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  @override
  Widget build(BuildContext context) {
    return Selector<ThemeModeProvider, bool>(
      builder: (context, isDark, child) {
        return MaterialApp(
          routes: {
            'settings': (context) => SettingsScreen(),
            'darktheme': (context) => DarkthemeScreen(),
            'archivedTasks': (context) => ArchivedTasksScreen(),
            'Statistics': (context) => StatisticsScreen(),
            'notification': (context) => NotificationScreen(),
          },
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurpleAccent,
              primary: Colors.deepPurple,
              secondary: Colors.pinkAccent,
            ),
          ),
          darkTheme: ThemeData.dark(),

          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: Homepage(),
          debugShowCheckedModeBanner: false,
        );
      },
      selector: (_, notifier) {
        return notifier.isDark;
      },
    );
  }
}
