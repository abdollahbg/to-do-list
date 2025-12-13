import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Providers/TasksProvider.dart';
import 'package:to_do_list/models/priority.dart';
import 'TaskCard.dart';
import 'package:percent_indicator/percent_indicator.dart';

Widget AllTasks() {
  return Consumer<TasksProvider>(
    builder: (context, provider, _) {
      int totalTasks = provider.tasks.length;
      int completedTasks = provider.tasks.values
          .where((t) => t.isCompleted)
          .length;
      double percent = totalTasks == 0 ? 0 : completedTasks / totalTasks;

      return ListView(
        padding: EdgeInsets.only(top: 10),

        children: [
          ...provider.tasks.entries.map((entry) {
            final index = entry.key;
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
              index: index,
            );
          }),

          SizedBox(height: 30),

          Center(
            child: CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 6.0,
              percent: percent,
              center: Text("${(percent * 100).toInt()}%"),
              progressColor: Colors.green,
              backgroundColor: Colors.grey.shade300,
              animation: true,
              animationDuration: 800,
              animateFromLastPercent: true,
            ),
          ),

          SizedBox(height: 40),
        ],
      );
    },
  );
}
