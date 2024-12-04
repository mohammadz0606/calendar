import 'dart:developer';

import 'package:calendar/test.dart';
import 'package:flutter/material.dart';

class CalendarHScreen extends StatefulWidget {
  const CalendarHScreen({super.key});

  @override
  State<CalendarHScreen> createState() => _CalendarHScreenState();
}

class _CalendarHScreenState extends State<CalendarHScreen> {

  @override
  void initState() {
    conv();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showHijriPicker(context);
          },
          child: const Text('Click'),
        ),
      ),
    );
  }

  void _showHijriPicker(BuildContext context) async {
    // Example of converting Gregorian dates to Hijri
    final startDate = convertGregorianToHijri(DateTime(1900, 1, 1));
    final endDate = convertGregorianToHijri(DateTime.now());

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => HijriDatePicker(
        startDate: startDate,
        endDate: endDate,
      ),
    );

    if (result != null) {
      log(
          'Selected Hijri Date: ${result['hijriYear']}-${result['hijriMonth']}-${result['hijriDay']}');
    }
  }
}


class HijriDatePicker extends StatefulWidget {
  const HijriDatePicker({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  final Map<String, int> startDate; // {hijriYear: x, hijriMonth: y, hijriDay: z}
  final Map<String, int> endDate; // {hijriYear: x, hijriMonth: y, hijriDay: z}

  @override
  _HijriDatePickerState createState() => _HijriDatePickerState();
}

class _HijriDatePickerState extends State<HijriDatePicker> {
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;

  late int startYear;
  late int endYear;

  @override
  void initState() {
    super.initState();
    // Initialize start and end years
    startYear = widget.startDate['hijriYear']!;
    endYear = widget.endDate['hijriYear']!;

    // Default selected values
    selectedYear = endYear;
    selectedMonth = 1; // Default to Muharram
    selectedDay = 1; // Default to 1st day
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year and Month Selectors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Year Dropdown
                DropdownButton<int>(
                  value: selectedYear,
                  items: List.generate(
                    endYear - startYear + 1,
                        (index) {
                      final year = startYear + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year هـ'),
                      );
                    },
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value!;
                    });
                  },
                ),
                // Month Dropdown
                DropdownButton<int>(
                  value: selectedMonth,
                  items: List.generate(
                    hijriMonths.length,
                        (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(hijriMonths[index]),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                      selectedDay = 1; // Reset day to 1 when month changes
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Day Grid
            GridView.builder(
              shrinkWrap: true,
              itemCount: daysInHijriMonths[selectedMonth]!,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 days in a week
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                final day = index + 1;
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedDay = day;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedDay == day
                          ? Colors.blueAccent
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: selectedDay == day ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'hijriYear': selectedYear,
                  'hijriMonth': selectedMonth,
                  'hijriDay': selectedDay,
                });
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
}