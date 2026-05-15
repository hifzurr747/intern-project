/// Represents a single task in the Task Management App.
class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Encode: "id|isCompleted|createdAtMs|title"
  /// Title is last so any '|' inside it is safe via sublist join.
  String encode() {
    return '$id|$isCompleted|${createdAt.millisecondsSinceEpoch}|$title';
  }

  /// Decode a stored string back to a Task.
  factory Task.decode(String raw) {
    final parts = raw.split('|');
    return Task(
      id: parts[0],
      isCompleted: parts[1] == 'true',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          int.parse(parts[2])),
      title: parts.sublist(3).join('|'),
    );
  }

  /// Returns a copy with optional new values (immutable update pattern).
  Task copyWith({String? title, bool? isCompleted}) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
