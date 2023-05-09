import 'package:flutter_tts/flutter_tts.dart';

class GetDate{
  final FlutterTts _flutterTts = FlutterTts();
  String? dateTts;

  Future<void> speakDate() async {
    var date = DateTime.now();
    var day = date.day;
    var month = date.month;
    var year = date.year;
    var weekday = date.weekday;

    sayMonth(weekday, day, month, year);
  }

  Future<void> speakTomorrowDate() async {
    var date = DateTime.now();
    var day = date.day;
    var month = date.month;
    var year = date.year;
    var weekday = date.weekday;

    sayMonth(weekday+1, day+1, month, year);
  }

  void sayMonth(weekday, day, month, year) {
    String monthtoString;
    if (month == 1) {
      monthtoString = "January";
      sayDay(weekday, day, monthtoString, year);
    } else if (month == 2) {
      monthtoString = "February";
      sayDay(weekday, day, monthtoString, year);
    } else if (month == 3) {
      monthtoString = "March";
      sayDay(weekday, day, monthtoString, year);
    } else if (month == 4) {
      monthtoString = "April";
      sayDay(weekday, day, monthtoString, year);
    } else if (month == 5) {
      monthtoString = "May";
      sayDay(weekday, day, monthtoString, year);
    } else if (month == 6) {
      monthtoString = "June";
      sayDay(weekday, day, monthtoString, year);
    } else if (month == 7) {
      monthtoString = "July";
      sayDay(weekday, day, monthtoString, year);
    } else if (month == 8) {
      monthtoString = "August";
      sayDay(weekday, day, monthtoString, year);
    } else if (month == 9) {
      monthtoString = "September";
      sayDay(weekday, day, monthtoString, year);
    } else if (month == 10) {
      monthtoString = "October";
      sayDay(weekday, day, monthtoString, year);
    } else if (month == 11) {
      monthtoString = "November";
      sayDay(weekday, day, monthtoString, year);
    } else if (month == 12) {
      monthtoString = "December";
      sayDay(weekday, day, monthtoString, year);
    }
  }

  void sayDay(weekday, day, month, year) {
    String weekdayString;
    if (weekday == 1) {
      weekdayString = "Monday";
      saydate(weekdayString, day, month, year);
    } else if (weekday == 2) {
      weekdayString = "Tuesday";
      saydate(weekdayString, day, month, year);
    } else if (weekday == 3) {
      weekdayString = "Wednesday";
      saydate(weekdayString, day, month, year);
    } else if (weekday == 4) {
      weekdayString = "Thursday";
      saydate(weekdayString, day, month, year);
    } else if (weekday == 5) {
      weekdayString = "Friday";
      saydate(weekdayString, day, month, year);
    } else if (weekday == 6) {
      weekdayString = "Saturday";
      saydate(weekdayString, day, month, year);
    } else if (weekday == 7) {
      weekdayString = "Sunday";
      saydate(weekdayString, day, month, year);
    }
  }

  void saydate(weekdayString, day, month, year) {
    String finalDate = '$weekdayString $day $month $year';
    var refDate = DateTime.now();
    var refDay = refDate.day;
    print(finalDate);
    if(day == refDay){
      _flutterTts.speak('The date is $finalDate');
    }
    else{
      _flutterTts.speak('The date tomorrow will be $finalDate');
    }
  }

}