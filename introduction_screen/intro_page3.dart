import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

String introText = "To detect object just tap the screen to initialize the camera and then every detected object will be said out aloud";
FlutterTts _flutterTts = FlutterTts();

class IntroPage3 extends StatelessWidget {
  const IntroPage3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void tts()async{
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.awaitSpeakCompletion(false);
      _flutterTts.speak(introText);
    }
    tts();
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.20,
            ),
            const Center(
              child: Text(
                "Object Detection",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30,
                    color: Color.fromARGB(255, 3, 152, 158),
                    fontWeight: FontWeight.bold

                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Center(
              child: Image.asset(
                "images/object detection.png",
                width: MediaQuery.of(context).size.width * 0.80,
                height: MediaQuery.of(context).size.height * 0.38,
              ),
            ),

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  introText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 3, 152, 158),
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
