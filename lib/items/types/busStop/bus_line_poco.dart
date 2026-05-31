import 'package:flutter/material.dart';

class BusLinePOCO {
  String number;
  List<TimeOfDay> monFri;
  List<TimeOfDay> sat;
  List<TimeOfDay> sun;

  BusLinePOCO({
    required this.number,
    required this.monFri,
    required this.sat,
    required this.sun,
  });
}

class FrequencyRule {
  TimeOfDay start;
  TimeOfDay end;
  int frequency;

  FrequencyRule({
    required this.start,
    required this.end,
    required this.frequency,
  });

  List<TimeOfDay> calculateTimes() {
    List<TimeOfDay> result = [];
    int current = start.hour * 60 + start.minute;
    int stop = end.hour * 60 + end.minute;

    // Handle night shifts (e.g., 22:00 to 02:00)
    if (stop <= current) stop += 24 * 60;

    while (current <= stop) {
      int h = (current ~/ 60) % 24;
      int m = current % 60;
      result.add(TimeOfDay(hour: h, minute: m));
      current += frequency;
    }
    return result;
  }
}
