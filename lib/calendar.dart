import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

extension Format on DateTime {
  String get format {
    return DateFormat('dd/MM/yy').format(this);
  }

  String get formatAndGetDay {
    String day = DateFormat.d().format(this);
    String weekday = DateFormat.E().format(this);
    return '$day\n$weekday';
  }

  String get getMonthName {
    return DateFormat('MMM').format(this);
  }
}

class CalendarScrollExample extends StatefulWidget {
  const CalendarScrollExample({super.key});

  @override
  State<CalendarScrollExample> createState() => _CalendarScrollExampleState();
}

class _CalendarScrollExampleState extends State<CalendarScrollExample> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScrollController _listScrollController = ScrollController();
  final List<DateTime> _dateList = [];

  bool _isCalendarVisible = false;
  double currentOffsetOfMonth = 0;

  @override
  void initState() {
    super.initState();
    _generateDateList();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  void _generateDateList() {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 25));
    for (int i = 0; i < 30; i++) {
      DateTime date = startDate.add(Duration(days: i));
      _dateList.add(date);
    }
  }

  void _scrollToSelectedDate(DateTime date) {
    int index = _dateList.indexWhere((element) =>
        element.year == date.year &&
        element.month == date.month &&
        element.day == date.day);

    if (index != -1) {
      _listScrollController.animateTo(
        index * 70,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.black,
        centerTitle: false,
        title: GestureDetector(
          onTap: () {
            setState(() {
              _isCalendarVisible = !_isCalendarVisible;
            });
          },
          child: Text(
            _selectedDay?.format ?? DateTime.now().format,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isCalendarVisible = false;
              });
            },
            child: ListView.builder(
              controller: _listScrollController,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(
                  top: 10, left: 15, right: 15, bottom: 40),
              itemCount: _dateList.length,
              itemBuilder: (context, index) {
                DateTime date = _dateList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(5),
                        width: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: date.format == _selectedDay?.format
                              ? Border.all(
                                  width: 2,
                                  color: Colors.black87,
                                )
                              : null,
                        ),
                        child: Text(
                          date.formatAndGetDay,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[400]!,
                          highlightColor: Colors.grey[500]!,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: _isCalendarVisible,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.47,
              color: Colors.black,
              child: Column(
                children: [
                  ListOfMonthWidget(
                    focusedDay: _focusedDay,
                    currentOffsetOfMonth: currentOffsetOfMonth,
                    onChangeDate: (currentOffsetMonth, selectedDate) {
                     setState(() {
                       _focusedDay = selectedDate;
                       currentOffsetMonth = currentOffsetMonth;
                     });
                    },
                  ),
                  Expanded(
                    child: TableCalendar(
                      daysOfWeekVisible: true,
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      onHeaderTapped: (focusedDay) {
                        _showYearPicker();
                      },
                      focusedDay: _focusedDay,
                      headerVisible: true,
                      calendarFormat: CalendarFormat.month,
                      currentDay: DateTime.now(),
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _isCalendarVisible = false;
                        });
                        _scrollToSelectedDate(selectedDay);
                      },
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                        leftChevronVisible: false,
                        rightChevronVisible: false,
                        titleTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      calendarStyle: const CalendarStyle(
                        defaultTextStyle: TextStyle(color: Colors.white),
                        weekendTextStyle: TextStyle(color: Colors.white70),
                        selectedTextStyle: TextStyle(color: Colors.black),
                        selectedDecoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: Colors.white,
                        ),
                        outsideDaysVisible: false,
                        todayDecoration: BoxDecoration(
                          color: Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Colors.white70),
                        weekendStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showYearPicker() async {
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int tempYear = _focusedDay.year;
        return AlertDialog(
          title: const Text('Select Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: ListView.builder(
              itemCount: DateTime.utc(2031, 1, 1).year -
                  DateTime.utc(2020, 1, 1).year +
                  1, // Limits to the years in the range
              itemBuilder: (context, index) {
                int year = DateTime.utc(2020, 1, 1).year + index;
                return ListTile(
                  title: Text(
                    year.toString(),
                    style: TextStyle(
                      color: tempYear == year ? Colors.teal : Colors.black,
                      fontWeight: tempYear == year
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    tempYear = year;
                    Navigator.pop(context, year);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null) {
      setState(() {
        if (selectedYear >= 2020 && selectedYear <= 2030) {
          _focusedDay =
              DateTime(selectedYear, _focusedDay.month, _focusedDay.day);
        }
      });
    }
  }
}

class ListOfMonthWidget extends StatefulWidget {
  ListOfMonthWidget({
    super.key,
    required this.focusedDay,
    required this.currentOffsetOfMonth,
    required this.onChangeDate,
  });

  DateTime focusedDay;
  double currentOffsetOfMonth;
  final Function(double currentOffsetMonth, DateTime selectedDate) onChangeDate;

  @override
  State<ListOfMonthWidget> createState() => _ListOfMonthWidgetState();
}

class _ListOfMonthWidgetState extends State<ListOfMonthWidget> {
  final ScrollController _mothScrollController = ScrollController();

  final List<String> _months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  void _onMonthSelected(int month) {
    setState(() {
      widget.focusedDay =
          DateTime(widget.focusedDay.year, month + 1, widget.focusedDay.day);
    });
  }

  @override
  void initState() {
    log(widget.currentOffsetOfMonth.toString());
    log(widget.focusedDay.getMonthName.toString());

    if (widget.currentOffsetOfMonth == 0) {
      int monthIndex = _months.indexWhere(
        (element) => element == widget.focusedDay.getMonthName,
      );
      widget.currentOffsetOfMonth = monthIndex * 60;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mothScrollController.animateTo(
        widget.currentOffsetOfMonth,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _mothScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        controller: _mothScrollController,
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            _months.length,
            (index) {
              return GestureDetector(
                onTap: () {
                  _onMonthSelected(index);
                  log('The scroll position');
                  log(_mothScrollController.offset.toString());
                  setState(() {
                    widget.currentOffsetOfMonth = _mothScrollController.offset;
                    widget.onChangeDate(
                      widget.currentOffsetOfMonth,
                      widget.focusedDay,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: widget.focusedDay.month == index + 1
                        ? Colors.white
                        : Colors.black,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: widget.focusedDay.month == index + 1
                          ? Colors.white
                          : Colors.white54,
                    ),
                  ),
                  child: Text(
                    _months[index],
                    style: TextStyle(
                      color: widget.focusedDay.month == index + 1
                          ? Colors.black
                          : Colors.white54,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
