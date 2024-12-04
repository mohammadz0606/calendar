import 'dart:developer';

import 'package:intl/intl.dart';

List<String> hijriMonths = [
  'محرم',
  'صفر',
  'ربيع الأول',
  'ربيع الآخر',
  'جمادى الأولى',
  'جمادى الآخرة',
  'رجب',
  'شعبان',
  'رمضان',
  'شوال',
  'ذو القعدة',
  'ذو الحجة'
];

Map<int, int> daysInHijriMonths = {
  1: 30, // محرم
  2: 29, // صفر
  3: 30, // ربيع الأول
  4: 29, // ربيع الآخر
  5: 30, // جمادى الأولى
  6: 29, // جمادى الآخرة
  7: 30, // رجب
  8: 29, // شعبان
  9: 30, // رمضان
  10: 29, // شوال
  11: 30, // ذو القعدة
  12: 30, // ذو الحجة
};

Map<String, int> convertGregorianToHijri(DateTime gregorianDate) {
  final referenceGregorian = DateTime(622, 7, 16);
  final daysSinceReference =
      gregorianDate.difference(referenceGregorian).inDays;

  // Average length of a Hijri year in days
  const double averageHijriYearLength = 354.367;

  // Calculate Hijri year and remaining days
  final hijriYear = (daysSinceReference / averageHijriYearLength).floor() + 1;
  final remainingDays = daysSinceReference % averageHijriYearLength;

  // Calculate Hijri month and day
  int hijriMonth = 0;
  int hijriDay = 0;
  int dayCount = 0;

  for (int month = 1; month <= 12; month++) {
    final daysInMonth = daysInHijriMonths[month]!;
    if (dayCount + daysInMonth > remainingDays) {
      hijriMonth = month;
      hijriDay = (remainingDays - dayCount + 1).toInt();
      break;
    }
    dayCount += daysInMonth;
  }

  return {
    'hijriYear': hijriYear,
    'hijriMonth': hijriMonth,
    'hijriDay': hijriDay,
  };
}

void conv() {
  final gregorianDate = DateTime.now();
  final hijriDate = convertGregorianToHijri(gregorianDate);

  log(
    'Gregorian: ${DateFormat.yMMMMd().format(gregorianDate)} -> Hijri: ${hijriDate['hijriDay']} ${hijriMonths[hijriDate['hijriMonth']! - 1]} ${hijriDate['hijriYear']} AH',
  );
}
