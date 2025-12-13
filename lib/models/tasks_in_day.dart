import 'dart:convert';

import 'package:to_do_list/models/Task.dart';

class TasksInDay {
  final DateTime date;
  final List<Task> tasks;

  TasksInDay({required this.date, required this.tasks});

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory TasksInDay.fromJson(Map<String, dynamic> json) {
    return TasksInDay(
      date: DateTime.parse(json['date']),
      tasks: (json['tasks'] as List)
          .map((taskJson) => Task.fromJson(taskJson))
          .toList(),
    );
  }
}
