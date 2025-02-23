import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:habitual/src/datetime_parse.dart';

enum Frequency {
  all,
  daily,
  weekly,
  monthly,
  // quarterly,
  // yearly,
}

enum DurationType {
  seconds,
  minutes,
  hours,
}

class Habit {
  int id;
  String title;
  Frequency frequency;
  DurationType durationType;
  int? duration;
  List<int> datesCompleted;
  int dateCreated;

  Habit(this.id, this.title, this.frequency, this.durationType, this.duration, this.datesCompleted, this.dateCreated);

  factory Habit.fromJson(String json) {
    Map<String, dynamic> habitData = jsonDecode(json);
    List<dynamic> jsonDates = jsonDecode(habitData['datesCompleted']);

    List<int> dates = jsonDates.isNotEmpty ? List.from(jsonDates.cast(), growable: true) : List.empty(growable: true);

    return Habit(
      habitData['id'],
      habitData['title'],
      Frequency.values[habitData['frequency']],
      DurationType.values[habitData['durationType']],
      habitData['duration'],
      dates,
      habitData['dateCreated'],
    );
  }

  String toJson() {
    return jsonEncode( {
      'id': id,
      'title': title,
      'frequency': frequency.index,
      'durationType': durationType.index,
      'duration': duration,
      'datesCompleted': jsonEncode(datesCompleted),
      'dateCreated': dateCreated,
    });
  }

  void increment(DateTime now) {
    DateTime utcDT = now.toLocal();

    if (datesCompleted.contains(dateTimeToInt(utcDT))) return;

    datesCompleted.add(dateTimeToInt(utcDT));
  }

  void decrement(DateTime now) {
    if (datesCompleted.isEmpty) return;

    DateTime today = now.toLocal();
    DateTime firstOfWeekDT = today.subtract(Duration(days: today.weekday));
    DateTime endOfWeekDT = today.add(Duration(days: 7- today.weekday));
    int currentDate = dateTimeToInt(today);

    int firstOfYear = today.year * 10000;
    // int endOfYear = (today.year + 1) * 10000;
    int firstOfMonth = firstOfYear + (today.month * 100);
    int endOfMonth = firstOfMonth + 31;
    int firstOfWeek = firstOfWeekDT.year * 10000 + firstOfWeekDT.month * 100 + firstOfWeekDT.day;
    int endOfWeek = endOfWeekDT.year * 10000 + endOfWeekDT.month * 100 + endOfWeekDT.day;

    switch (frequency) {
      case Frequency.daily:
        datesCompleted.remove(datesCompleted.lastWhere((date) => date == currentDate));
        break;
      case Frequency.weekly:
        datesCompleted.remove(datesCompleted.lastWhere((date) => date >= firstOfWeek && date <= endOfWeek));
        break;
      case Frequency.monthly:
        datesCompleted.remove(datesCompleted.lastWhere((date) => date >= firstOfMonth && date <= endOfMonth));
        break;
      // case Frequency.yearly:
      //   datesCompleted.remove(datesCompleted.lastWhere((date) => date >= firstOfYear && date <= endOfYear));
      //   break;
      default:
        return;
    }

    return;
  }


  /// Return the integer length of the current streak 
  int getCurrentStreak() {
    if (datesCompleted.isEmpty) return 0;
    if (datesCompleted.length == 1) return 1;

    datesCompleted.sort();

    if (frequency == Frequency.daily) {
      // Binary search
      DateTime currentDate = intToDateTime(datesCompleted.last);
      int datesLength = datesCompleted.length - 1;
      int last = (datesLength / 2).floor();
      int current = 0;

      while(intToDateTime(datesCompleted[current]).add(Duration(days: datesLength - current)) != currentDate) {
        current += last;
        last = max((last / 2).floor(), 1);
      }

      if (current != datesLength) {
        while (intToDateTime(datesCompleted[current]).subtract(Duration(days: datesLength - current)) == currentDate) {
          current -= 1;
        }
      }

      return datesCompleted.length - current;
    } else if (frequency == Frequency.weekly) {
      DateTime currentDate = intToDateTime(datesCompleted.last);
      int currentStreak = 1;

      for (int i = datesCompleted.length - 1; i > 0; --i) {
        DateTime nextDate = intToDateTime(datesCompleted[i - 1]);

        if (isInPreviousWeek(currentDate, nextDate) ) {
          currentStreak += 1;
          currentDate = nextDate;
        } else {
          break;
        }
      }

      return currentStreak;
    } else if (frequency == Frequency.monthly) {
      DateTime currentDate = intToDateTime(datesCompleted.last);
      int currentStreak = 1;

      for (int i = datesCompleted.length - 1; i > 0; --i) {
        DateTime nextDate = intToDateTime(datesCompleted[i - 1]);

        if (isInPreviousMonth(currentDate, nextDate) ) {
          currentStreak += 1;
          currentDate = nextDate;
        } else {
          break;
        }
      }

      return currentStreak;
    }
    
    return 0;
  }

    /// Return the integer length of the l
  int getLongestStreak() {
    if (datesCompleted.isEmpty) return 0;
    if (datesCompleted.length == 1) return 1;

    datesCompleted.sort();

    int currentStreak = 1;
    int maxStreak = 0;

    DateTime currentDate = intToDateTime(datesCompleted.first);

    for (int i = 0; i < datesCompleted.length - 1; ++i) {
      DateTime nextDate = intToDateTime(datesCompleted[i + 1]);
      bool check = false;
      switch (frequency) {
        case Frequency.daily:
          nextDate == currentDate.add(Duration(days: 1));
        break;
        case Frequency.weekly:
          check = isInNextWeek(currentDate, nextDate);
        break;
        case Frequency.monthly:
          check = isInNextMonth(currentDate, nextDate);
        break;
        default:
      }

      if (check) {
        currentStreak += 1;
        currentDate = nextDate;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
        currentStreak = 1;
      }
    }
    
    return maxStreak;
  }

  bool completed(DateTime checkDate) {
    if (datesCompleted.isEmpty) return false;

    DateTime today = checkDate.toLocal();
    DateTime firstOfWeekDT = today.subtract(Duration(days: today.weekday));
    DateTime endOfWeekDT = today.add(Duration(days: 7- today.weekday));
    int currentDate = dateTimeToInt(today);

    int firstOfYear = today.year * 10000;
    // int endOfYear = (today.year + 1) * 10000;
    // int firstOfQuarter = firstOfYear + ((today.month / 3).ceil() * 100);
    int firstOfMonth = firstOfYear + (today.month * 100);
    int endOfMonth = firstOfMonth + 31;
    int firstOfWeek = firstOfWeekDT.year * 10000 + firstOfWeekDT.month * 100 + firstOfWeekDT.day;
    int endOfWeek = endOfWeekDT.year * 10000 + endOfWeekDT.month * 100 + endOfWeekDT.day;

    switch (frequency) {
      case Frequency.daily:
        return datesCompleted.contains(currentDate);
      case Frequency.weekly:
        return datesCompleted.where((date) => date >= firstOfWeek && date <= endOfWeek).isNotEmpty;
      case Frequency.monthly:
        return datesCompleted.where((date) => date >= firstOfMonth && date <= endOfMonth).isNotEmpty;
      // case Frequency.yearly:
      //   return datesCompleted.where((date) => date >= firstOfYear && date <= endOfYear).isNotEmpty;
      default:
        return false;
    }
  }
}

