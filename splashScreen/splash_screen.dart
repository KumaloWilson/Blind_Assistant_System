import 'dart:async';
import 'package:arti_eyes/assistant_side/assistant_home_screen.dart';
import 'package:arti_eyes/authentication/login_screen.dart';
import 'package:arti_eyes/services/assistant_user_models/assistance_methods.dart';
import 'package:arti_eyes/services/blind_user_models/assistance_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../authentication/userType.dart';
import '../global/global.dart';
import '../mainScreens/main_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}
enum TtsState { playing, stopped }

class _MySplashScreenState extends State<MySplashScreen> {

  String intro  = "Welcome to Arti eyes. Your Number 1 Digital Assistant";
  late FlutterTts _flutterTts;
  String? _tts;
  TtsState _ttsState = TtsState.stopped;


  //Function for initializing text to speech
  initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        _ttsState = TtsState.playing;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setErrorHandler((message) {
      setState(() {
        print("Error: $message");
        _ttsState = TtsState.stopped;
      });
    });
  }

//Function for speaking recognized text taking the results from the recognized model as the parameter
  Future speak(tts) async {
    await _flutterTts.setVolume(1);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1);

    if (_tts != null) {
      if (tts!.isNotEmpty) {
        await _flutterTts.speak(tts!);
      }
    }
  }

  void getUserMode() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    assistantMode = (prefs.getBool('assistantUser') ?? false);
    blindMode = (prefs.getBool('blindUser') ?? false);

    if(assistantMode == true){
      userType = UserType.assistant;

      asUser = 'Assistant';
      print("THE CURRENT USER TYPE IS $userType");

    }

    if(blindMode == true){
      userType = UserType.blindPerson;

      asUser = 'Visually Impaired';
      print("THE CURRENT USER TYPE IS $userType");


    }

    if(blindMode == false && assistantMode == false){
      asUser = 'BUG DETECTED';
      userType = null;
      print("THE CURRENT USER TYPE IS $userType");

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (c) => selectUserType()));
    }
  }


  startTimer() {
    setState(() {
      _tts = intro;

      speak(_tts);
    });

    if(userType == UserType.assistant){
      fAuth.currentUser != null ? AssistantUserAssistantMethods.readCurrentOnlineAssistantUserInfo() : null;
    }

    else if(userType == UserType.blindPerson){
      fAuth.currentUser != null ? BlindUserAssistantMethods.readCurrentOnlineBlindUserInfo(): null;
    }



    Timer(const Duration(seconds: 6), () async {
      if (fAuth.currentUser != null && userType == UserType.blindPerson) {
        currentFirebaseUser = fAuth.currentUser;

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (c) => MainScreen()));


      }else if (fAuth.currentUser != null && userType == UserType.assistant) {
        currentFirebaseUser = fAuth.currentUser;

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => AssistantHomeScreen()));


      }
      else {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUserMode();
    initTts();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/wallpaper1.jpg"), fit: BoxFit.cover),
        ),
        child:Center(
              child: Image.asset(
                "images/logo2.png",
                width: MediaQuery.of(context).size.width * 0.86,
                height: MediaQuery.of(context).size.width * 0.46,
              ),
            ),
        ),
    );
  }
}
