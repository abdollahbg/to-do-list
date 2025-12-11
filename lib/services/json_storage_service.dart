import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:to_do_list/models/tasks_in_day.dart';

class JsonStorageService {
  Future<String> get _localpath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localpath;

    return File('$path/$filename.json');
  }

  Future<void> saveTasksInDay(String filename, TasksInDay data) async {
    final file = await _localFile(filename);

    final jsonString = jsonEncode(data.toJson());
    await file.writeAsString(jsonString);
  }

  Future<TasksInDay?> readTasksInDay(String filename) async {
    try {
      final file = await _localFile(filename);

      if (!await file.exists()) {
        return null;
      }
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);

      return TasksInDay.fromJson(jsonData);
    } catch (e) {
      print("Error reading JSON: $e");
      return null;
    }
  }
}
