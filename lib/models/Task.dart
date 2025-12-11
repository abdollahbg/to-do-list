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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'priority': priority,
      'isCompleted': isCompleted,
      'taskTime': '${taskTime.hour}:${taskTime.minute}',
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['taskTime'] as String).split(':');
    return Task(
      title: json['title'],
      priority: json['priority'],
      isCompleted: json['isCompleted'],
      taskTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
    );
  }
}
