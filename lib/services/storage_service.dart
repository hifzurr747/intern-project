import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

/// Handles all SharedPreferences read/write for the Task Manager.
class StorageService {
  static const String _tasksKey = 'tasks_list';
  static const String _counterKey = 'counter';
  static const String _todosKey = 'todos';

  /// Saves the full task list to SharedPreferences.
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = tasks.map((t) => t.encode()).toList();
    await prefs.setStringList(_tasksKey, encoded);
  }

  /// Loads and decodes the task list from SharedPreferences.
  /// Returns an empty list if nothing is stored yet.
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_tasksKey) ?? [];
    return raw.map((s) => Task.decode(s)).toList();
  }

  /// Saves the counter value to SharedPreferences.
  static Future<void> saveCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, value);
  }

  /// Loads the counter value from SharedPreferences.
  /// Returns 0 if nothing is stored yet.
  static Future<int> loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_counterKey) ?? 0;
  }

  /// Saves the todos list to SharedPreferences.
  /// Format: "done|||title" — separator is unlikely to appear in a task title.
  static Future<void> saveTodos(List<Map<String, dynamic>> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = todos
        .map((t) => '${t['done']}|||${t['title']}')
        .toList();
    await prefs.setStringList(_todosKey, encoded);
  }

  /// Loads the todos list from SharedPreferences.
  /// Returns an empty list if nothing is stored yet.
  static Future<List<Map<String, dynamic>>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_todosKey) ?? [];
    return raw.map((s) {
      final sep = s.indexOf('|||');
      if (sep == -1) return {'title': s, 'done': false}; // legacy fallback
      return {
        'done': s.substring(0, sep) == 'true',
        'title': s.substring(sep + 3),
      };
    }).toList();
  }
}
