import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScrollExample extends StatefulWidget {
  const CalendarScrollExample({super.key});

  @override
  State<CalendarScrollExample> createState() => _CalendarScrollExampleState();
}

class _CalendarScrollExampleState extends State<CalendarScrollExample> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScrollController _scrollController = ScrollController();
  final List<DateTime> _dateList = [];

  bool _isCalendarVisible = false;


  @override
  void initState() {
    super.initState();
    _generateDateList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateDateList() {
    DateTime startDate = DateTime.now().subtract(const Duration(days: 15));
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
      _scrollController.animateTo(
        index * 40,
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
          ListView.builder(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            itemCount: _dateList.length,
            itemBuilder: (context, index) {
              DateTime date = _dateList[index];
              return ListTile(
                title: Text(
                  '${date.day}-${date.month}-${date.year}',
                  style: TextStyle(
                    color: date.format == _selectedDay?.format
                        ? Colors.black
                        : Colors.red,
                    fontSize: date.format == _selectedDay?.format ? 40 : 20,
                    fontWeight: date.format == _selectedDay?.format
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
          Visibility(
            visible: _isCalendarVisible,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.25,
              color: Colors.black,
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.twoWeeks,
                onFormatChanged: (format) {
                  setState(() {
                    CalendarFormat.twoWeeks;
                  });
                },
                currentDay: DateTime.now(),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _isCalendarVisible = false;
                  });
                  _scrollToSelectedDate(selectedDay);
                },
              ),
            ),

          ),

        ],
      ),
    );
  }
}

extension Format on DateTime {
  String get format {
    return DateFormat('dd/MM/yy').format(this);
  }
}
