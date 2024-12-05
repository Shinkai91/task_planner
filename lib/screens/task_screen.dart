import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task.dart';

class TaskScreen extends StatefulWidget {
  final bool isEditing;
  final Task? task;
  final Function(Task) addTask;
  final Function(Task) onSave;

  const TaskScreen(
      {super.key,
      required this.isEditing,
      required this.addTask,
      required this.onSave,
      this.task});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  DateTime? startTime;

  final _formKey = GlobalKey<FormState>();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.isEditing ? widget.task?.title : '');
    descriptionController = TextEditingController(
        text: widget.isEditing ? widget.task?.description : '');
    if (widget.isEditing) {
      startTime = widget.task?.startTime;
    }

    // Initialize the notification plugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize settings for notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final Task task = Task(
        title: titleController.text,
        description: descriptionController.text,
        startTime: startTime,
      );

      if (widget.isEditing) {
        widget.onSave(task);
      } else {
        widget.addTask(task);
      }

      // Schedule notification if the task is within 10 minutes of starting
      _scheduleNotificationIfNeeded(task);

      Navigator.pop(context);
    }
  }

  Future<void> selectDateTime() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: startTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      final TimeOfDay? selectedTime = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.fromDateTime(startTime ?? DateTime.now()),
      );

      if (selectedTime != null) {
        setState(() {
          startTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  // Function to schedule a notification
  Future<void> _scheduleNotificationIfNeeded(Task task) async {
    if (task.startTime != null) {
      final now = DateTime.now();
      final difference = task.startTime!.difference(now).inMinutes;

      // Debugging log for checking the time difference
      // ignore: avoid_print
      print('Time difference: $difference minutes');

      // Schedule notification if the task is 10 minutes or less away
      if (difference <= 10 && difference >= 0) {
        await _showNotification(task);
      }
    }
  }

  // Function to show the notification
  Future<void> _showNotification(Task task) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Upcoming Task', // Notification title
      'Task "${task.title}" will start in less than 10 minutes.', // Notification body
      platformChannelSpecifics,
      payload: 'task_payload', // Optional payload
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'Add Task'),
        backgroundColor: Colors.teal,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Task Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task title';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: descriptionController,
                    decoration:
                        const InputDecoration(labelText: 'Task Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task description';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          startTime != null
                              ? 'Date & Time: ${DateFormat('yyyy-MM-dd – hh:mm a').format(startTime!)}'
                              : 'No time selected',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: selectDateTime,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: Text(widget.isEditing ? 'Save Changes' : 'Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
