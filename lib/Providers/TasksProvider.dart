import 'package:to_do_list/dialogs/edit_dialog.dart';
import 'package:to_do_list/models/Task.dart';
import 'package:to_do_list/models/priority.dart';

import 'package:flutter/material.dart';

class TasksProvider with ChangeNotifier {
  Map<int, Task> tasks = {};

  void addTask({
    required String title,
    int priority = Priority.none,
    required TimeOfDay taskTime,
  }) {
    int id = tasks.length;
    tasks[id] = Task(
      title: title,
      priority: priority,
      isCompleted: false,
      taskTime: taskTime,
    );
    notifyListeners();
  }

  void editTask(int taskId, String title, int priority, TimeOfDay taskTime) {
    tasks[taskId]?.title = title;
    tasks[taskId]?.priority = priority;
    tasks[taskId]?.taskTime = taskTime;
    notifyListeners();
  }

  void deleteTask(int taskId) {
    tasks.remove(taskId);
    notifyListeners();
  }

  void updateTask(Task task) {
    int? taskId = tasks.entries
        .firstWhere(
          (entry) => entry.value == task,
          orElse: () => MapEntry(
            -1,
            Task(
              title: '',
              priority: Priority.none,
              isCompleted: false,
              taskTime: TimeOfDay.now(),
            ),
          ),
        )
        .key;
    if (taskId != -1) {
      tasks[taskId] = task;
      notifyListeners();
    }
  }

  void toggleCompletion(int index) {
    tasks[index]!.isCompleted = !tasks[index]!.isCompleted;
    notifyListeners();
  }

  void editTaskDialog(BuildContext context, int index) {
    showEditTaskDialog(context, index); // استدعاء نافذة التعديل
  }
}
