import 'package:to_do_list/Providers/TasksProvider.dart';
import 'package:to_do_list/models/priority.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showEditTaskDialog(BuildContext context, taskId) {
  String title = "";
  int priority = Priority.none;
  TimeOfDay taskTime = TimeOfDay.now();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Edit Task"),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Task Title",
                  icon: Icon(Icons.title),
                ),
                onChanged: (val) => title = val,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.priority_high),
                  SizedBox(width: 16),
                  DropdownButton<int>(
                    value: priority,
                    items: [
                      DropdownMenuItem(
                        value: Priority.none,
                        child: Text("None"),
                      ),
                      DropdownMenuItem(value: Priority.low, child: Text("Low")),
                      DropdownMenuItem(
                        value: Priority.medium,
                        child: Text("Medium"),
                      ),
                      DropdownMenuItem(
                        value: Priority.high,
                        child: Text("High"),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => priority = val ?? Priority.none);
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time),
                  SizedBox(width: 16),
                  TextButton(
                    child: Text(taskTime.format(context)),
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: taskTime,
                      );
                      if (picked != null) setState(() => taskTime = picked);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (title.isNotEmpty) {
                context.read<TasksProvider>().editTask(
                  taskId: taskId,
                  title: title,
                  priority: priority,
                  taskTime: taskTime,
                );
                Navigator.pop(context);
              }
            },
            child: Text("Edit"),
          ),
        ],
      );
    },
  );
}
