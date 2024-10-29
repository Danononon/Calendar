import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TasksScene {
  static final Map<DateTime, Map<String, bool>> tasks = {
    DateTime(2024, 9, 1): {'Сделать что-то': false},
    DateTime(2024, 9, 2): {'Опять сделать что-то': true},
  };

  static Future<void> loadTasks() async { // Загружаем задачи
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic>? savedTasks = jsonDecode(prefs.getString('tasks') ?? '{}'); // Если изначально задач нет,
                                                                                           // то возвращаем пустой map
    savedTasks?.forEach((key, value) {
      DateTime date = DateTime.parse(key);
      tasks[date] = Map<String, bool>.from(value);
    });
  }

  static Future<void> saveTasks() async { // Сохраняем задачи
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(tasks.map((key, value) => MapEntry(key.toIso8601String(), value))); // Преобразуем данные в JSON
    await prefs.setString('tasks', jsonString); // Сохраняем задачи в JSON
  }

  static Future<void> addTask(DateTime date, String taskTitle) async {
    if (tasks.containsKey(date)) {
      tasks[date]![taskTitle] = false; // Добавляем новую задачу с статусом false
    } else {
      tasks[date] = {taskTitle: false}; // Создаем новый список задач
    }
    await saveTasks(); // Сохраняем задачи
  }

  static Future<void> deleteTask(DateTime date, String taskTitle) async {
    if (tasks.containsKey(date)) { // Если в этот день несколько задач
      tasks[date]!.remove(taskTitle); // Удаляем только одну задачу
      if (tasks[date]!.isEmpty) { // Если только одна задача, то удаляем дату
        tasks.remove(date);
      }
      await saveTasks(); // Сохраняем задачи
    }
  }

  static Future<void> toggleTaskStatus(DateTime date, String taskTitle) async {
    if (tasks.containsKey(date) && tasks[date]!.containsKey(taskTitle)) {
      tasks[date]![taskTitle] = !tasks[date]![taskTitle]!; // Переключаем статус
      await saveTasks(); // Сохраняем задачи
    }
  }

  static Map<String, bool> getTasks(DateTime date) {
    return tasks[date] ?? {}; // Возвращаем задачи на указанную дату
  }
}
