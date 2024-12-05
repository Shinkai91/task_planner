import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class LocalStorage {
  // Simpan daftar tugas ke SharedPreferences
  Future<void> saveTasksToLocal(List<Task> tasks) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> tasksJson = tasks
        .map((task) => jsonEncode({
              'title': task.title,
              'description': task.description,
              'startTime': task.startTime?.toIso8601String(),
            }))
        .toList();

    await prefs.setStringList('tasks', tasksJson);  // Simpan daftar tugas ke SharedPreferences
    // ignore: avoid_print
    print("Tasks saved locally: $tasksJson");  // Debugging: Melihat data yang disimpan
  }

  // Muat daftar tugas dari SharedPreferences
  Future<List<Task>> loadTasksFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? tasksJson = prefs.getStringList('tasks');

    if (tasksJson != null && tasksJson.isNotEmpty) {
      // ignore: avoid_print
      print("Loaded tasks: $tasksJson");  // Debugging: Melihat data yang dimuat
      return tasksJson.map((taskString) {
        final Map<String, dynamic> taskMap = jsonDecode(taskString);
        return Task(
          title: taskMap['title'],
          description: taskMap['description'],
          startTime: taskMap['startTime'] != null
              ? DateTime.parse(taskMap['startTime'])
              : null,
        );
      }).toList();
    }

    return []; // Kembalikan list kosong jika tidak ada data
  }
}