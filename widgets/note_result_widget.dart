import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../tabPages/currency_detection.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  DisplayPictureScreen(this.imagePath);
  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  Image? img;
  String result = "";
  var noteStatusIdentified;
  // ignore: non_constant_identifier_names
  double result_confidence = 0;
  final FlutterTts _flutterTts = FlutterTts();
  String? forTts;

  startTimer() {
    Timer(const Duration(seconds: 5), () async {
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    loadModel().then((value) {
      setState(() {});
    });
    img = Image.file(File(widget.imagePath));
    classifyImage(widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 152, 158),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            child: noteStatusIdentified == true
              ? Text(
                  "✅ $result",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20
                  ),
                )

              : Text(
                  "❌ $result",
                  style: const TextStyle(
                  color: Colors.red,
                  fontSize: 20
                  ),
                ),
          ),

          Container(
            height: MediaQuery.of(context).size.height * 0.83,
            width: 360,
            margin: const EdgeInsets.only(top: 0),
            child: Center(
              child: Expanded(
                child: Center(
                  child: img,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  classifyImage(String image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image,
      numResults: 1,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    //-------------------------------------------------------------------------------------------------------
    result = "";

    recognitions?.forEach((response) {
      result += response["label"];
      result_confidence = response["confidence"] * 100;
    });

    setState(() {
      result;
      result_confidence;
    });


    if (result_confidence > 99.5) {
      noteStatusIdentified = true;
      if (result == "0 1 US Dollar") {
        total += 1;
        result = "1 US Dollar";
        forTts = "1 U.S Dollar, your total is now $total dollars";
        await _flutterTts.speak(forTts!);

      }
      else if (result == "1 2 US Dollars") {
        total += 2;
        result = "2 US Dollars";
        forTts = "2 U.S Dollars, your total is now $total dollars";
        await _flutterTts.speak(forTts!);

      }
      else if (result == "2 5 US Dollars") {
        total += 5;
        result = "5 US Dollars";
        forTts = "5 U.S Dollars, your total is now $total dollars";
        await _flutterTts.speak(forTts!);

      }
      else if (result == "3 10 US Dollars") {
        total += 10;
        result = "10 US Dollars";
        forTts = "10 U.S Dollars, your total is now $total dollars";
        await _flutterTts.speak(forTts!);

      }

      else if (result == "4 20 US Dollars") {
        total += 20;
        result = "20 US Dollars";
        forTts = "20 U.S Dollars, your total is now $total dollars";
        await _flutterTts.speak(forTts!);

      }
      else if (result == "5 50 US Dollars") {
        total += 50;
        result = "50 US Dollars";
        forTts = "50 U.S Dollars, your total is now $total dollars";
        await _flutterTts.speak(forTts!);

      }
      else if (result == "6 100 US Dollars") {
        total += 100;
        result = "100 US Dollars";
        forTts = "100 U.S Dollars, your total is now $total dollars";
        await _flutterTts.speak(forTts!);

      }
    }
    else if(result_confidence >= 98 && result_confidence <= 99.5){
      noteStatusIdentified = false;
      result = "Please Rescan";
      forTts = "The note is not clear enough, Please rescan";
      await _flutterTts.speak(forTts!);

    }

    else{
      noteStatusIdentified = false;
      result = "Please Rescan";
      forTts = "No note found, Please rescan";
      await _flutterTts.speak(forTts!);

    }

    //-------------------------------------------------------------------------------------------------------



  }

  loadModel() async {
    await Tflite.loadModel(
      model: "datasets/usd_currency_model/model_unquant.tflite",
      labels: "datasets/usd_currency_model/labels.txt",
    );
  }

}