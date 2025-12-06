import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Providers/TasksProvider.dart';
import 'package:to_do_list/models/priority.dart';
import 'TaskCard.dart';

Widget UncompletedTasks() {
  return Consumer<TasksProvider>(
    builder: (context, provider, _) {
      final uncompletedTasks = provider.tasks.entries
          .where((e) => !e.value.isCompleted)
          .toList();

      return ListView.separated(
        itemCount: uncompletedTasks.length,
        itemBuilder: (context, index) {
          final entry = uncompletedTasks[index];
          final task = entry.value;

          String priorityText = "";
          Color priorityColor = Colors.grey;

          switch (task.priority) {
            case Priority.none:
              priorityText = "None";
              priorityColor = Colors.grey;
              break;
            case Priority.low:
              priorityText = "Low";
              priorityColor = Colors.green;
              break;
            case Priority.medium:
              priorityText = "Medium";
              priorityColor = Colors.orange;
              break;
            case Priority.high:
              priorityText = "High";
              priorityColor = Colors.red;
              break;
          }

          return Taskcard(
            title: Text(task.title),
            priority: Text(
              "Priority: $priorityText",
              style: TextStyle(
                color: priorityColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            isComplete: task.isCompleted,
            taskTime: task.taskTime,
            index: entry.key,
          );
        },
        separatorBuilder: (_, __) => SizedBox(height: 10),
      );
    },
  );
}
