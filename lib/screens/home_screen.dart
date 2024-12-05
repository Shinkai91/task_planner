import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import 'task_screen.dart';
import 'profile_screen.dart';
import '../data/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks(); // Muat tugas saat aplikasi dimulai
  }

  // Muat tugas dari local storage
  void loadTasks() async {
    final List<Task> loadedTasks = await LocalStorage().loadTasksFromLocal();
    // ignore: avoid_print
    print("Loaded Tasks: $loadedTasks"); // Debugging: Melihat tugas yang dimuat
    setState(() {
      tasks = loadedTasks;
    });
  }

  // Tambah tugas
  void addTask(Task task) async {
    setState(() {
      tasks.add(task); // Menambahkan task baru ke dalam list tasks
    });
    await saveTasks(); // Simpan seluruh task yang ada setelah penambahan task baru
  }

  // Simpan semua tugas ke SharedPreferences
  Future<void> saveTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> tasksJson = tasks
        .map((task) => jsonEncode({
              'title': task.title,
              'description': task.description,
              'startTime': task.startTime?.toIso8601String(),
            }))
        .toList();

    await prefs.setStringList(
        'tasks', tasksJson); // Simpan daftar tugas ke SharedPreferences
    // ignore: avoid_print
    print(
        "Tasks saved locally: $tasksJson"); // Debugging: Melihat data yang disimpan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Planner'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ProfileScreen(), // Navigasi ke ProfileScreen
                ),
              );
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(
              child: Text('No tasks yet! Add a task using the "+" button.'),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      tasks[index].title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tasks[index].description,
                            style: const TextStyle(fontSize: 14)),
                        if (tasks[index].startTime != null)
                          Text(
                            'Date & Time: ${DateFormat('yyyy-MM-dd – hh:mm a').format(tasks[index].startTime!)}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskScreen(
                                  addTask: addTask,
                                  task: tasks[index],
                                  isEditing: true,
                                  onSave: (editedTask) {
                                    setState(() {
                                      tasks[index] = editedTask;
                                    });
                                    saveTasks();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              tasks.removeAt(index);
                            });
                            saveTasks();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskScreen(
                addTask: addTask,
                isEditing: false,
                onSave: (editedTask) {},
              ),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
