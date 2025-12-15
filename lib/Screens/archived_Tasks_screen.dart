import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/Providers/TasksProvider.dart';

class ArchivedTasksScreen extends StatelessWidget {
  const ArchivedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Archived Tasks")),
      body: Consumer<TasksProvider>(
        builder: (context, provider, child) {
          if (provider.archivedTasksMap.isEmpty) {
            return const Center(child: Text("No archived tasks"));
          }

          final sortedKeys = provider.archivedTasksMap.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final dateKey = sortedKeys[index];
              final dayTasks = provider.archivedTasksMap[dateKey]!;

              final completedTasks = dayTasks.tasks
                  .where((task) => task.isCompleted)
                  .toList();

              final skippedTasks = dayTasks.tasks
                  .where((task) => !task.isCompleted)
                  .toList();

              return ExpansionTile(
                title: Text(
                  dateKey,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  ...dayTasks.tasks.map((task) {
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text(
                        "Time: ${task.taskTime.hour}:${task.taskTime.minute.toString().padLeft(2, '0')}",
                      ),
                      trailing: task.isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    );
                  }),
                  RichText(
                    text: TextSpan(
                      text: 'Tasks completed : ',
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: '${completedTasks.length}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Tasks skipped : ',
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: '${skippedTasks.length}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
