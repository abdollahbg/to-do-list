import 'package:flutter/material.dart';

class Task {
  String title;
  int priority; // none, low, medium, high
  bool isCompleted;
  TimeOfDay taskTime;

  Task({
    required this.title,
    required this.priority,
    required this.isCompleted,
    required this.taskTime,
  });
}
