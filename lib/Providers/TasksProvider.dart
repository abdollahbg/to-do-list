import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list/dialogs/edit_dialog.dart';
import 'package:to_do_list/models/Task.dart';
import 'package:to_do_list/models/priority.dart';
import 'package:to_do_list/models/tasks_in_day.dart';
import 'package:to_do_list/services/json_storage_service.dart';
import 'package:to_do_list/services/notification_service.dart';

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

        // 🔔 إعادة جدولة إشعارات مهام اليوم عند فتح التطبيق
        _scheduleTaskNotifications(
          i,
          loaded.tasks[i].title,
          loaded.tasks[i].taskTime,
        );
      }
    }

    notifyListeners();
  }

  Future<void> saveTasks() async {
    final items = tasks.values.toList();
    final data = TasksInDay(date: DateTime.now(), tasks: items);
    await storage.saveTasksInDay(filename, data);
  }

  // -------------------- إضافة مهمة --------------------
  Future<void> addTask({
    required String title,
    int priority = Priority.none,
    required TimeOfDay taskTime,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    tasks[id] = Task(
      title: title,
      priority: priority,
      isCompleted: false,
      taskTime: taskTime,
    );

    notifyListeners();
    await saveTasks();

    _scheduleTaskNotifications(id, title, taskTime);
  }

  // -------------------- تعديل مهمة --------------------
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

      _cancelTaskNotifications(taskId);
      _scheduleTaskNotifications(taskId, title, taskTime);
    }

    notifyListeners();
    await saveTasks();
  }

  // -------------------- حذف مهمة --------------------
  Future<void> deleteTask(int taskId) async {
    tasks.remove(taskId);

    _cancelTaskNotifications(taskId);

    notifyListeners();
    await saveTasks();
  }

  Future<void> updateTask(Task task) async {
    final taskId = tasks.entries.firstWhere((entry) => entry.value == task).key;

    tasks[taskId] = task;

    _cancelTaskNotifications(taskId);
    _scheduleTaskNotifications(taskId, task.title, task.taskTime);

    notifyListeners();
    await saveTasks();
  }

  Future<void> toggleCompletion(int taskId) async {
    final task = tasks[taskId];
    if (task != null) {
      task.isCompleted = !task.isCompleted;

      if (task.isCompleted) {
        _cancelTaskNotifications(taskId);
      }
    }

    notifyListeners();
    await saveTasks();
  }

  void editTaskDialog(BuildContext context, int taskId) {
    showEditTaskDialog(context, taskId);
  }

  Future<void> archiveTodayTasks() async {
    if (tasks.isEmpty) return;

    for (final id in tasks.keys) {
      _cancelTaskNotifications(id);
    }

    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);

    List<TasksInDay> allTasks = await storage.readAllTasks();

    archivedTasksMap = {
      for (var t in allTasks) DateFormat('yyyy-MM-dd').format(t.date): t,
    };

    final todayTasks = TasksInDay(date: now, tasks: tasks.values.toList());

    archivedTasksMap[dateKey] = todayTasks;

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

  // -------------------- دوال الإشعارات --------------------
  void _scheduleTaskNotifications(
    int taskId,
    String title,
    TimeOfDay taskTime,
  ) {
    final now = DateTime.now();

    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      taskTime.hour,
      taskTime.minute,
    );

    if (scheduledDate.isBefore(now)) return;

    final reminderTime = scheduledDate.subtract(const Duration(minutes: 10));

    if (reminderTime.isAfter(now)) {
      NotificationService.scheduleNotification(
        id: taskId,
        title: 'Reminder: $title',
        body: 'Your task starts in 10 minutes',
        scheduledDate: reminderTime,
      );
    }

    NotificationService.scheduleNotification(
      id: taskId + 1000,
      title: 'Task Started: $title',
      body: 'It\'s time to start your task!',
      scheduledDate: scheduledDate,
    );
  }

  void _cancelTaskNotifications(int taskId) {
    NotificationService.cancelNotification(taskId);
    NotificationService.cancelNotification(taskId + 1000);
  }
}
