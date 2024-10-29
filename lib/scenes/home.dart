import 'package:calendar/scenes/day.dart';
import 'package:flutter/material.dart';
import 'package:calendar/scenes/tasks.dart';

class HomeScene extends StatefulWidget {
  const HomeScene({super.key});

  @override
  State<HomeScene> createState() => _HomeSceneState();
}

class _HomeSceneState extends State<HomeScene> {
  List<int> years = [];
  List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  List<String> months = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь'
  ];

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month - 1; // Месяцы начинаются с 0

  final currentYear = DateTime.now().year;
  final currentMonth = DateTime.now().month;
  final currentDay = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    for (int i = 2000; i <= 2050; i++) {
      years.add(i); // Календарь с 1980 до 2050 при загрузке
    }
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    await TasksScene.loadTasks(); // Загружаем задачи после генерирования календаря
    setState(() {});
  }

  int daysInMonth(int year, int month) {
    // Кол-во дней в месяце
    if (month == 1) {
      // Февраль
      return isLeapYear(year) ? 29 : 28;
    }
    return [3, 5, 8, 10].contains(month) ? 30 : 31;
  }

  bool hasPendingTasks(DateTime date) {
    Map<String, bool> tasks = TasksScene.getTasks(date);
    return tasks.values.any((isCompleted) => !isCompleted);
  }

  bool isLeapYear(int year) {
    // Високосный год
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  final TextEditingController editTitleController = TextEditingController();

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
                        TasksScene.deleteTask(
                            DateTime(currentYear, currentMonth, currentDay),
                            taskTitle);
                        TasksScene.addTask(
                            DateTime(currentYear, currentMonth, currentDay),
                            newTaskTitle);
                        setState(() {});
                      }
                      editTitleController.clear();
                      Navigator.of(context).pop();
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
    Map<String, bool> currentTasks =
        TasksScene.getTasks(DateTime(currentYear, currentMonth, currentDay));
    int daysCount = daysInMonth(selectedYear, selectedMonth);
    DateTime firstDayOfMonth = DateTime(selectedYear, selectedMonth + 1,
        1); // Определяем первый день месяца (пн, вт, ...)
    int firstWeekDay = firstDayOfMonth.weekday -
        1; // Определяем первый день недели (начинаются с нуля)
    int daysToNextSunday = (7 - (firstWeekDay + daysCount) % 7) %
        7; // Кол-во дней до первого воскресенья следующего месяца

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: selectedYear == 1980 && selectedMonth == 0
                      ? null
                      : () {
                          setState(() {
                            selectedMonth =
                                selectedMonth > 0 ? selectedMonth - 1 : 11;
                            if (selectedMonth == 11) {
                              selectedYear--;
                            }
                          });
                        },
                  icon: Icon(Icons.chevron_left,
                      color: selectedYear == 1980 && selectedMonth == 0
                          ? Colors.deepPurple[300]
                          : Colors.white),
                ),
                DropdownButton<int>(
                  value: selectedMonth,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  dropdownColor: Colors.deepPurple,
                  iconEnabledColor: Colors.white,
                  underline: SizedBox(),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text(
                        months[index],
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedMonth = value; // Обновляем выбранный месяц
                      });
                    }
                  },
                ),
                DropdownButton<int>(
                  value: selectedYear,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                  dropdownColor: Colors.deepPurple,
                  iconEnabledColor: Colors.white,
                  underline: SizedBox(),
                  items: years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(
                        year.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedYear = value; // Обновляем выбранный год
                      });
                    }
                  },
                ),
                IconButton(
                  onPressed: selectedYear == 2050 && selectedMonth == 11
                      ? null
                      : () {
                          setState(() {
                            selectedMonth =
                                selectedMonth < 11 ? selectedMonth + 1 : 0;
                            if (selectedMonth == 0) {
                              selectedYear++;
                            }
                          });
                        },
                  icon: Icon(Icons.chevron_right,
                      color: selectedYear == 2050 && selectedMonth == 11
                          ? Colors.deepPurple[300]
                          : Colors.white),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  selectedYear = currentYear;
                  selectedMonth = currentMonth - 1;
                });
              },
              icon: Icon(Icons.access_time_outlined, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map((day) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        day,
                        style: TextStyle(
                            color: (day == 'Сб' || day == 'Вс')
                                ? Colors.pinkAccent
                                : Colors.deepPurple[300],
                            fontSize: 20),
                      ),
                    ))
                .toList(),
          ),
          GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            shrinkWrap: true,
            itemCount: daysCount +
                firstWeekDay +
                daysToNextSunday, // Кол-во дней в месяце + начало календаря (конец прошлого месяца)
            // + конец календаря (начало следующего месяца)
            itemBuilder: (context, index) {
              int day = index -
                  firstWeekDay +
                  1; // Начало с первого числа (начинается с единицы)
              if (index < firstWeekDay) {
                // Если начало выбранного месяца НЕ понедельник
                int previousDays = daysInMonth(
                    // Кол-во дней в прошлом месяце
                    selectedMonth != 0 ? selectedYear : selectedYear - 1,
                    selectedMonth != 0 ? selectedMonth - 1 : 11);
                return InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return DayScene(
                          year: selectedYear,
                          month: selectedMonth,
                          day: previousDays + index + 1 - firstWeekDay);
                    })).then((_) {
                      setState(() {});
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                            '${previousDays + index + 1 - firstWeekDay}', // Вычитаем из кол-ва дней прошлого месяца индекс начала недели,
                            // прибавляем единицу и итерацию
                            style: TextStyle(color: Colors.grey)),
                      ),
                      if (hasPendingTasks(DateTime(selectedYear, selectedMonth,
                          previousDays + index + 1 - firstWeekDay)))
                        Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 6,
                        ),
                    ],
                  ),
                );
              } else if (index < firstWeekDay + daysCount) {
                // Если не последний день выбранного месяца
                // Если сегодняшняя дата совпадает с днем и выбранными месяцем с годом в календаре
                if (currentYear == selectedYear &&
                    currentMonth - 1 == selectedMonth &&
                    currentDay == day)
                  return Container(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return DayScene(
                              year: selectedYear,
                              month: selectedMonth + 1,
                              day: day);
                        })).then((_) {
                          setState(() {});
                        });
                      },
                      child: Container(
                        // Если сегодняшний день - это сб/вс
                        color: (day + firstWeekDay + 1) % 7 <= 1
                            ? Colors.pinkAccent
                            : Colors.deepPurple,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                '$day',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            if (hasPendingTasks(
                                DateTime(selectedYear, selectedMonth + 1, day)))
                              Icon(
                                Icons.circle,
                                color: Colors.red,
                                size: 6,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                return InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return DayScene(
                          year: selectedYear,
                          month: selectedMonth + 1,
                          day: day); // Месяцы с единицы
                    })).then((_) {
                      setState(() {});
                    });
                  },
                  child: Container(
                    color: (day + firstWeekDay + 1) % 7 <=
                            1 // Если это суббота или воскресенье (6 и 7 дни недели)
                        ? Colors.pink[100]
                        : Colors.deepPurple[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text('$day'),
                        ),
                        if (hasPendingTasks(
                            DateTime(selectedYear, selectedMonth + 1, day)))
                          Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 6,
                          ),
                      ],
                    ),
                  ),
                );
              } else {
                int nextDay = index -
                    (firstWeekDay + daysCount) +
                    1; // Если вышли за пределы кол-ва дней в календаре,
                // то заполняем до вс значениями i++, где i = 1
                return InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return DayScene(
                          year: selectedYear,
                          month: selectedMonth + 2,
                          day: nextDay); // Прибавляем 2 к следующему месяцу,
                      // т. к. начинается с единицы
                    })).then((_) {
                      setState(() {});
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text('$nextDay',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      if (hasPendingTasks(
                          DateTime(selectedYear, selectedMonth + 2, nextDay)))
                        Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 6,
                        ),
                    ],
                  ),
                );
              }
            },
          ),
          if (currentTasks.length > 0) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Задачи на сегодня:',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  for (var task in currentTasks.keys)
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(
                              task,
                              style: TextStyle(
                                color: Colors.pink,
                                decoration: currentTasks[task]!
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: Colors.pink,
                                decorationThickness: 2,
                              ),
                            ),
                            onTap: () {
                              TasksScene.toggleTaskStatus(
                                  DateTime(
                                      currentYear, currentMonth, currentDay),
                                  task);
                              setState(() {});
                            },
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              TasksScene.deleteTask(
                                  DateTime(
                                      currentYear, currentMonth, currentDay),
                                  task);
                              setState(() {});
                            },
                            icon: Icon(Icons.delete, color: Colors.pink)),
                        IconButton(
                            onPressed: () => openDialog(task),
                            icon: Icon(Icons.edit, color: Colors.deepPurple)),
                      ],
                    ),
                ],
              ),
            ),
          ],
          if (currentTasks.length == 0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Задач на сегодня нет',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.pink,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
