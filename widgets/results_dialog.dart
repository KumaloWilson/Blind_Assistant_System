import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../global/global.dart';

class ResultsDialog extends StatelessWidget {
  String text;
  String isEmpty = "No Text Found, Please rescan";
  final FlutterTts _flutterTts = FlutterTts();
  bool pauseTts = false;

  ResultsDialog({super.key, required this.text});

  @override
  Widget build(BuildContext context) {

    speechTimer(){

      audioPlayer.open(Audio("audios/mixkit-classic-camera-click-1440.wav"));
      audioPlayer.play();

      if(text == "" || text == " " || text.isEmpty)
      {
        Timer(const Duration(seconds: 1), () async {
          await _flutterTts.speak(isEmpty);
        });

        Timer(const Duration(seconds: 4,), () async {
          Navigator.pop(context);
        });
      }
      else{
        Timer(const Duration(seconds: 3), () async {
          await _flutterTts.speak(text);
        });
      }

    }


    stopResultsScreen(){
      _flutterTts.stop();

      Timer(const Duration(seconds: 1,), () async {
        Navigator.pop(context);
      });
    }

    speechTimer();

    return GestureDetector(
      onTap: ()
      {
        if(pauseTts == false)
        {
          _flutterTts.pause();
          pauseTts = true;
        }
        else if(pauseTts == true)
        {

          _flutterTts.speak(text);
          pauseTts = false;
        }
      },

      onDoubleTap: ()
      {
        stopResultsScreen();
      },

      child: AlertDialog(
        backgroundColor: Colors.transparent,
        scrollable: true,
        content: SingleChildScrollView(
          reverse: true,
          physics: const BouncingScrollPhysics(),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 152, 158),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
