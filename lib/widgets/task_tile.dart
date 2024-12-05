import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function(Task) onDelete;
  final Function(Task) onEdit;

  const TaskTile(
      {super.key,
      required this.task,
      required this.onDelete,
      required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text(task.description),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => onEdit(task), // Edit action
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onDelete(task), // Delete action
          ),
        ],
      ),
    );
  }
}