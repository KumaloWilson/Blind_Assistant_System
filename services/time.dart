import 'package:flutter_tts/flutter_tts.dart';

class TimerTime {
  final FlutterTts _flutterTts = FlutterTts();
  String? time;

  Future<void>timer() async {
    var dt = DateTime.now();
    var hour = dt.hour;
    var minute = dt.minute;
    var ampm = 'AM';

    if (hour >= 12) {
      ampm = "PM";
      if (hour > 12) {
        hour = hour - 12;

        if (minute == 00) {
          oclock(hour, minute, ampm);
        } else if (minute > 0 && minute < 30 && minute != 15) {
          past(hour, minute, ampm);
        } else if (minute == 15) {
          quarterpast(hour, minute, ampm);
        } else if (minute > 30 && minute != 45 && minute < 60) {
          to(hour, minute, ampm);
        } else if (minute == 30) {
          halfpast(hour, minute, ampm);
        } else if (minute == 45) {
          quarterto(hour, minute, ampm);
        }
      }
    } else {
      ampm = "AM";
      if (minute == 00) {
        oclock(hour, minute, ampm);
      } else if (minute > 0 && minute < 30 && minute != 15) {
        past(hour, minute, ampm);
      } else if (minute == 15) {
        quarterpast(hour, minute, ampm);
      } else if (minute > 30 && minute != 45 && minute < 60) {
        to(hour, minute, ampm);
      } else if (minute == 30) {
        halfpast(hour, minute, ampm);
      } else if (minute == 45) {
        quarterto(hour, minute, ampm);
      }
    }
  }
  void past(hour, minute, ampm) {
    if (minute == 1) {
      time = 'The time is a minute past $hour $ampm';
      _flutterTts.speak(time!);
    } else {
      time = 'The time is $minute minutes past $hour $ampm';
      _flutterTts.speak(time!);
    }
  }

  void quarterpast(hour, minute, ampm) {
    time ='The time is quarter past $hour $ampm';
    _flutterTts.speak(time!);
  }

  void halfpast(hour, minute, ampm) {
    time = 'The time is half past $hour $ampm';
    _flutterTts.speak(time!);
  }

  void to(hour, minute, ampm) {
    minute = 60 - minute;
    hour = hour + 1;

    if (minute == 1) {
      time = 'The time is a minute to $hour $ampm';
      _flutterTts.speak(time!);
    } else {
      time = 'The time is $minute minutes to $hour $ampm';
      _flutterTts.speak(time!);
    }
  }

  void quarterto(hour, minute, ampm) {
    minute = 60 - minute;
    hour = hour + 1;
    time = 'The time is quarter to $hour $ampm';
    _flutterTts.speak(time!);
  }

  void oclock(hour, minute, ampm) {
    time = "The time is $hour o'clock $ampm";
    _flutterTts.speak(time!);
  }
}