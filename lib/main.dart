import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homePage.dart';
import 'TasksProvider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TasksProvider(),
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
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.blue,
          secondary: Colors.pinkAccent,
        ),
      ),
      themeMode: ThemeMode.system,
      home: Homepage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
