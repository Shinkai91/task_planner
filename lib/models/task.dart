class Task {
  String title;
  String description;
  DateTime? startTime;

  Task({
    required this.title,
    required this.description,
    this.startTime,
  });
}