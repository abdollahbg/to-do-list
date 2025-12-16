import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list/dialogs/edit_dialog.dart';
import 'package:to_do_list/models/Task.dart';
import 'package:to_do_list/models/priority.dart';
import 'package:to_do_list/models/tasks_in_day.dart';
import 'package:to_do_list/services/json_storage_service.dart';

class TasksProvider with ChangeNotifier {
  Map<int, Task> tasks = {};
  final JsonStorageService storage = JsonStorageService();
  final String filename = "today";
  Map<String, TasksInDay> archivedTasksMap = {};

  TasksProvider() {
    loadTasks();
    loadArchivedTasks();
  }

  Future<void> loadArchivedTasks() async {
    final archivedList = await storage.readAllTasks();

    archivedTasksMap = {
      for (var day in archivedList)
        DateFormat('yyyy-MM-dd').format(day.date): day,
    };

    notifyListeners();
  }

  Future<void> loadTasks() async {
    final loaded = await storage.readTasksInDay(filename);

    if (loaded != null) {
      final savedDate = DateTime(
        loaded.date.year,
        loaded.date.month,
        loaded.date.day,
      );

      final today = DateTime.now();
      final currentDate = DateTime(today.year, today.month, today.day);

      if (savedDate.isBefore(currentDate)) {
        await archiveTodayTasks();
        return;
      }

      tasks.clear();
      for (int i = 0; i < loaded.tasks.length; i++) {
        tasks[i] = loaded.tasks[i];
      }
    }

    notifyListeners();
  }

  Future<void> saveTasks() async {
    final items = tasks.values.toList();
    final data = TasksInDay(date: DateTime.now(), tasks: items);
    await storage.saveTasksInDay(filename, data);
  }

  // إضافة مهمة
  Future<void> addTask({
    required String title,
    int priority = Priority.none,
    required TimeOfDay taskTime,
  }) async {
    int id = tasks.length;
    tasks[id] = Task(
      title: title,
      priority: priority,
      isCompleted: false,
      taskTime: taskTime,
    );
    notifyListeners();
    await saveTasks();
  }

  Future<void> editTask({
    required int taskId,
    required String title,
    required int priority,
    required TimeOfDay taskTime,
  }) async {
    final task = tasks[taskId];
    if (task != null) {
      task.title = title;
      task.priority = priority;
      task.taskTime = taskTime;
    }
    notifyListeners();
    await saveTasks();
  }

  Future<void> deleteTask(int taskId) async {
    tasks.remove(taskId);
    notifyListeners();
    await saveTasks();
  }

  Future<void> updateTask(Task task) async {
    final taskId = tasks.entries
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
      await saveTasks();
    }
  }

  Future<void> toggleCompletion(int taskId) async {
    final task = tasks[taskId];
    if (task != null) {
      task.isCompleted = !task.isCompleted;
    }
    notifyListeners();
    await saveTasks();
  }

  void editTaskDialog(BuildContext context, int taskId) {
    showEditTaskDialog(context, taskId);
  }

  Future<void> archiveTodayTasks() async {
    if (tasks.isEmpty) return;

    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);

    // قراءة جميع الأرشيف
    List<TasksInDay> allTasks = await storage.readAllTasks();

    archivedTasksMap = {
      for (var t in allTasks) DateFormat('yyyy-MM-dd').format(t.date): t,
    };

    // حفظ مهام اليوم في الأرشيف
    final todayTasks = TasksInDay(date: now, tasks: tasks.values.toList());
    if (archivedTasksMap.containsKey(dateKey)) {
      archivedTasksMap[dateKey]?.tasks.addAll(todayTasks.tasks);
    } else {
      archivedTasksMap[dateKey] = todayTasks;
    }
    await storage.saveAllTasks(archivedTasksMap.values.toList());

    tasks.clear();

    await saveTasks();

    notifyListeners();
  }

  TasksInDay? getTasksByDate(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return archivedTasksMap[dateKey];
  }

  Map<String, TasksInDay> getFilteredArchivedTasks(
    DateTime start,
    DateTime end,
  ) {
    final filtered = <String, TasksInDay>{};

    archivedTasksMap.forEach((dateKey, tasksInDay) {
      final date = DateTime.parse(dateKey);
      if (!date.isBefore(start) && !date.isAfter(end)) {
        filtered[dateKey] = tasksInDay;
      }
    });

    return filtered;
  }
}
