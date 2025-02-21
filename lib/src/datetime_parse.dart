/// Take a datetime and convert it into an int of the form {year}{month}{day} (ex. 20250101) with leading 0s for months and days less than 10.
int dateTimeToInt(DateTime dateTime) {
  DateTime utc = dateTime.toLocal();

  String month = utc.month < 10 ? '0${utc.month}' : '${utc.month}';
  String day = utc.day < 10 ? '0${utc.day}' : '${utc.day}';

  return int.parse('${utc.year}$month$day');
}

/// Return the int formed by taking the current time in local time.
int dateTimeNowToInt() {
  return dateTimeToInt(DateTime.now());
}

/// Return the datetime representation of an int of the form {year}{month}{day}
DateTime intToDateTime(int dateTimeInt) {
  String dateTimeString = dateTimeInt.toString();

  String year = dateTimeString.substring(0, 4);
  String month = dateTimeString.substring(4, 6);
  String day = dateTimeString.substring(6);

  return DateTime(
    int.parse(year),
    int.parse(month),
    int.parse(day),
  );
}

String dateTimeToYMDString(DateTime dateTime) {
  DateTime localTime = dateTime.toLocal();
  return '${localTime.year} - ${localTime.month} - ${localTime.day}';
}

String dateTimeIntToYMDString(int dateTimeInt) {
  DateTime dateTime = intToDateTime(dateTimeInt);

  return dateTimeToYMDString(dateTime);
}

bool isInPreviousMonth(DateTime currentDate, DateTime nextDate) {
  DateTime previousMonth = currentDate.subtract(Duration(days: currentDate.day + 1));

  int firstOfYear = previousMonth.year * 10000;
  int firstOfMonth = firstOfYear + (previousMonth.month * 100);
  int endOfMonth = firstOfMonth + 31;

  int nextDateInt = dateTimeToInt(nextDate);

  return nextDateInt >= firstOfMonth && nextDateInt <= endOfMonth;
}

bool isInNextMonth(DateTime currentDate, DateTime nextDate) {
  DateTime nextMonth = currentDate.add(Duration(days: 32 - currentDate.day));

  int firstOfYear = nextMonth.year * 10000;
  int firstOfMonth = firstOfYear + (nextMonth.month * 100);
  int endOfMonth = firstOfMonth + 31;

  int nextDateInt = dateTimeToInt(nextDate);

  return nextDateInt > firstOfMonth && nextDateInt <= endOfMonth;
}

bool isInPreviousWeek(DateTime currentDate, DateTime nextDate) {
  //  Make Sunday the first day of the week
  int currentWeekday = currentDate.weekday == 7 ? 1 : currentDate.weekday + 1;
  DateTime firstOfWeekDT = currentDate.subtract(Duration(days: currentWeekday));

  DateTime firstOfPreviousWeek = firstOfWeekDT.subtract(Duration(days: 7));

  int firstOfWeek = firstOfPreviousWeek.year * 10000 + firstOfPreviousWeek.month * 100 + firstOfPreviousWeek.day;
  int endOfWeek = firstOfWeekDT.year * 10000 + firstOfWeekDT.month * 100 + firstOfWeekDT.day;

  int nextDateInt = dateTimeToInt(nextDate);

  return nextDateInt > firstOfWeek && nextDateInt <= endOfWeek;
}

bool isInNextWeek(DateTime currentDate, DateTime nextDate) {
  //  Make Sunday the first day of the week
  int currentWeekday = currentDate.weekday == 7 ? 1 : currentDate.weekday + 1;
  DateTime firstOfWeekDT = currentDate.subtract(Duration(days: currentWeekday));

  DateTime firstOfNextWeek = firstOfWeekDT.add(Duration(days: 7));
  DateTime endOfNextWeek = firstOfWeekDT.add(Duration(days:  14));

  int firstOfWeek = firstOfNextWeek.year * 10000 + firstOfNextWeek.month * 100 + firstOfNextWeek.day;
  int endOfWeek = endOfNextWeek.year * 10000 + endOfNextWeek.month * 100 + endOfNextWeek.day;

  int nextDateInt = dateTimeToInt(nextDate);

  return nextDateInt >= firstOfWeek && nextDateInt < endOfWeek;
}