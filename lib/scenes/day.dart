import 'package:flutter/material.dart';
import 'package:calendar/scenes/tasks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayScene extends StatefulWidget {
  const DayScene({
    super.key,
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;

  @override
  State<DayScene> createState() => _DaySceneState();
}

class _DaySceneState extends State<DayScene> {
  @override
  void initState() {
    super.initState();
    TasksScene.loadTasks();
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController editTitleController = TextEditingController();

  DateTime get taskDate => DateTime(widget.year, widget.month, widget.day);
  DateTime get currentDate => DateTime.now();
  DateTime get currentDateWithoutTime =>
      DateTime(currentDate.year, currentDate.month, currentDate.day);
  bool get isTodayOrFuture => !taskDate.isBefore(currentDateWithoutTime);

  String checkDataInput(int value) {
    if (value.toString().length == 1) {
      String newValue = "0${value.toString()}";
      return newValue;
    } return value.toString();
  }

  void addTask() {
    String taskTitle = titleController.text.trim();
    if (taskTitle.isNotEmpty && isTodayOrFuture) {
      TasksScene.addTask(taskDate, taskTitle);
      setState(() {});
      titleController.clear();
      Navigator.of(context).pop();
    }
  }

  Future<void> openDialog(String taskTitle) async {
    editTitleController.text = taskTitle;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Изменить задачу'),
              content: TextField(
                controller: editTitleController,
                decoration: InputDecoration(hintText: 'Изменить задачу'),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      String newTaskTitle = editTitleController.text.trim();
                      if (newTaskTitle.isNotEmpty) {
                        TasksScene.deleteTask(taskDate, taskTitle);
                        TasksScene.addTask(taskDate, newTaskTitle);
                        setState(() {});
                      }
                      editTitleController.clear();
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    child: Text('Продолжить')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Отмена')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    Map<String, bool> tasks =
        TasksScene.getTasks(DateTime(widget.year, widget.month, widget.day));
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text('Задачи', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tasks.length > 0) ...[
              Center(
                child: Text(
                  'Задачи на ${checkDataInput(widget.day)}.${checkDataInput(widget.month)}.${widget.year}:',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    String task = tasks.keys.elementAt(index);
                    bool isCompleted = tasks[task]!;
                    return Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(
                              task,
                              style: TextStyle(
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: isTodayOrFuture
                                      ? Colors.deepPurple
                                      : Colors.pink,
                                  decorationThickness: 2,
                                  color: isTodayOrFuture
                                      ? Colors.deepPurple
                                      : Colors.pink),
                            ),
                            onTap: () {
                              if (!isTodayOrFuture && !isCompleted) {
                                TasksScene.deleteTask(
                                    DateTime(
                                        widget.year, widget.month, widget.day),
                                    task);
                                setState(() {});
                              } else if (!isTodayOrFuture && isCompleted) {
                              } else {
                                TasksScene.toggleTaskStatus(
                                    DateTime(
                                        widget.year, widget.month, widget.day),
                                    task);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        if (isTodayOrFuture) ...[
                          IconButton(
                              onPressed: () {
                                TasksScene.deleteTask(
                                    DateTime(
                                        widget.year, widget.month, widget.day),
                                    task);
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.pink,
                              )),
                          IconButton(
                              onPressed: () => openDialog(task),
                              icon: Icon(
                                Icons.edit,
                                color: Colors.deepPurple,
                              )),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
            if (tasks.length == 0)
              Center(
                child: Text(
                  'Вы не добавили ни одной задачи на ${checkDataInput(widget.day)}.${checkDataInput(widget.month)}.${widget.year}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: 16),
            if (isTodayOrFuture) ...[
              const Text(
                'Новое задание',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.pink,
                ),
              ),
              TextField(
                style: TextStyle(color: Colors.pink),
                controller: titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.pinkAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.pinkAccent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.pinkAccent),
                  ),
                  hintText: 'Сделать что-то...',
                  hintStyle: TextStyle(color: Colors.pink[200]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: addTask,
                    child: const Text('Добавить', style: TextStyle(
                        color: Colors.pink
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
