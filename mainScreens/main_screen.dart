import 'dart:async';
import 'dart:convert';
import 'package:arti_eyes/services/blind_user_models/assistance_methods.dart';
import 'package:http/http.dart' as http;
import 'package:arti_eyes/tabPages/search_engine_tab.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:picovoice_flutter/picovoice_error.dart';
// import 'package:picovoice_flutter/picovoice_manager.dart';
// import 'package:rhino_flutter/rhino.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:vibration/vibration.dart';
import '../global/global.dart';
import '../services/date.dart';
import '../services/time.dart';
import '../splashScreen/splash_screen.dart';
import '../tabPages/currency_detection.dart';
import '../tabPages/navigation_tab.dart';
import '../tabPages/optical_character_recognition_tab.dart';
import '../tabPages/object_detection_tab.dart';
import '../tabPages/sos_tab.dart';
import '../widgets/blind_user_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();

}


class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  bool openNavigationDrawer = true;


  //Picovoice
  final String accessKey ="msoa/qJ2l4nnbxf3cw/iu1xFPjSGDjom9j/8cjFpfmUWX5PHhlQROQ==";

  bool isError = false;
  String errorMessage = "";
  bool listeningForCommand = false;
  // PicovoiceManager? _picovoiceManager;
  Timer? _updateTimer;
  bool remoteOnOffCameraSwitch = false;

  //Location services
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;


  //Telephony services to send sms
  final Telephony telephony = Telephony.instance;
  var sosCount = 0;
  var initTime;





  TabController? tabController;
  int selectedIndex = 0;
  bool isEnabled = false;



  late FlutterTts _flutterTts;
  String? _tts;
  TtsState _ttsState = TtsState.stopped;

  //decode userCurrentAddress
  Future<String> getUserCurrentAddress() async{
    var client = http.Client();
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${myPosition!.latitude}&lon=${myPosition!.longitude}&zoom=18&addressdetails=1';
    var response = await client.post(Uri.parse(url));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes))
    as Map<dynamic, dynamic>;

    setState(() {
      blindUserCurrentAddress = decodedResponse['display_name'];
    });

    print(blindUserCurrentAddress);

    return blindUserCurrentAddress!;
  }

  void sendSms() async {
    SharedPreferences signPrefs = await SharedPreferences.getInstance();
    String? n1 = signPrefs.getString('phone1');
    String? n2 = signPrefs.getString('phone2');
    String? n3 = signPrefs.getString('phone3');
    String? name = signPrefs.getString('username');
    String? usermsg = signPrefs.getString('usermsg');

    print(n1);
    print(n2);
    print(n3);
    print(name);
    print(usermsg);

    String errormsg;
    if(n1 == null && n2 == null && n3 == null && name!.length < 3 && usermsg!.length < 20)
      {
          errormsg = "Please enter S.O.S contacts first";
          await speak(errormsg);
          Fluttertoast.showToast(msg: errormsg);
      }
    else if(n1!.length < 9 && n2!.length < 9 && n3!.length < 9)
    {
      errormsg = "Please enter at least one emergency contact";
      await speak(errormsg);
      Fluttertoast.showToast(msg: errormsg);
    }
    else if(name!.length < 3)
    {
      errormsg = "Please enter your username in the S.O.S tab";
      await speak(errormsg);
      Fluttertoast.showToast(msg: errormsg);
    }
    else if(usermsg!.isEmpty)
    {
      errormsg = "Please enter the message you would like to send to your emergency contacts";
      await speak(errormsg);
      Fluttertoast.showToast(msg: errormsg);
    }
    else if(usermsg.length < 10)
    {
      errormsg = "S.O.S message is too short";
      await speak(errormsg);
      Fluttertoast.showToast(msg: errormsg);
    }

    else{
      await telephony.sendSms(
        to: n1.toString(),
        message: "EMERGENCY ALERT FROM $name \n$usermsg\n Last Known Location: $blindUserCurrentAddress",
      );

      await telephony.sendSms(
        to: n2.toString(),
        message: "EMERGENCY ALERT FROM $name \n$usermsg\n Last Known Location: $blindUserCurrentAddress",
      );

      await telephony.sendSms(
        to: n3.toString(),
        message: "EMERGENCY ALERT FROM $name \n$usermsg\n Last Known Location: $blindUserCurrentAddress",
      );
      setState(() {
        _tts = "S.O.S message Sent Successfully";
        Fluttertoast.showToast(msg: _tts!);
      });
      await speak(_tts!);
    }
  }

  // void _initPicovoice() async {
  //   String platform = Platform.isAndroid
  //       ? "android"
  //       : throw PicovoiceRuntimeException("This demo supports iOS and Android only.");
  //   String keywordAsset = "datasets/picovoice/Vanessa_en_android_v2_1_0.ppn";
  //   String contextAsset = "datasets/picovoice/Screen-Navigations_en_android_v2_1_0.rhn";
  //
  //   try {
  //     _picovoiceManager = await PicovoiceManager.create(accessKey, keywordAsset,
  //         _wakeWordCallback, contextAsset, _inferenceCallback,
  //         processErrorCallback: _errorCallback);
  //     await _picovoiceManager?.start();
  //   } on PicovoiceInvalidArgumentException catch (ex) {
  //     _errorCallback(PicovoiceInvalidArgumentException(
  //         "${ex.message}\nEnsure your accessKey '$accessKey' is a valid access key."));
  //   } on PicovoiceActivationException {
  //     _errorCallback(
  //         PicovoiceActivationException("AccessKey activation error."));
  //   } on PicovoiceActivationLimitException {
  //     _errorCallback(PicovoiceActivationLimitException(
  //         "AccessKey reached its device limit."));
  //   } on PicovoiceActivationRefusedException {
  //     _errorCallback(PicovoiceActivationRefusedException("AccessKey refused."));
  //   } on PicovoiceActivationThrottledException {
  //     _errorCallback(PicovoiceActivationThrottledException(
  //         "AccessKey has been throttled."));
  //   } on PicovoiceException catch (ex) {
  //     _errorCallback(ex);
  //   }
  // }
  //
  // void _wakeWordCallback() {
  //   setState(() {
  //     listeningForCommand = true;
  //   });
  // }
  //
  // void _inferenceCallback(RhinoInference inference) {
  //   print(inference);
  //   if (inference.isUnderstood!) {
  //     Map<String, String> slots = inference.slots!;
  //     if (inference.intent == 'objectdetector') {
  //       setState(() {
  //         onItemClicked(0);
  //       });
  //     } else if (inference.intent == 'opticalcharacterrecognition') {
  //       setState(() {
  //         onItemClicked(1);
  //       });
  //     } else if (inference.intent == 'currencydetector') {
  //       setState(() {
  //         onItemClicked(2);
  //       });
  //     } else if (inference.intent == 'currencydetector') {
  //       setState(() {
  //         onItemClicked(3);
  //       });
  //     }  else if (inference.intent == 'help') {
  //       setState(() {
  //         onItemClicked(4);
  //       });
  //     }  else if (inference.intent == 'sendmsg') {
  //           audioPlayer.open(Audio("audios/Mail Sent.mp3"));
  //           audioPlayer.play();
  //
  //           Timer(const Duration(seconds: 2), () async {
  //             sendSms();
  //           });
  //
  //     }else if (inference.intent == 'date') {
  //       setState(() {
  //         GetDate().speakDate();
  //       });
  //     }else if (inference.intent == 'tommorrow') {
  //       setState(() {
  //         GetDate().speakTomorrowDate();
  //       });
  //     }else if (inference.intent == 'time') {
  //       setState(() {
  //         TimerTime().timer();
  //       });
  //     } else if (inference.intent == 'availableCommands') {
  //       String availableCommands = "I am just a prototype, for a blind assistant and object detection app'\n - 'You'll get full features once my development is done'\n - 'For now just navigate between screens by saying Navigate to:, then mention the screen you want to go to'";
  //       speak(availableCommands);
  //     }
  //   } else {
  //     String commandNotUnderstood = "I didn't understand your command! Please try again or go to help screen";
  //     speak(commandNotUnderstood);
  //   }
  //   setState(() {
  //     listeningForCommand = false;
  //   });
  // }
  //
  // void _errorCallback(PicovoiceException error) {
  //   setState(() {
  //     isError = true;
  //     errorMessage = error.message!;
  //     String errorMessageTTs;
  //     if(isError == true)
  //       {
  //         errorMessageTTs = errorMessage;
  //         speak(errorMessageTTs);
  //       }
  //   });
  // }

  void initTts() async {
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

  Future speak(tts) async {
    await _flutterTts.setVolume(1);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setPitch(1);

    if (_tts != null) {
      if (tts!.isNotEmpty) {
        await _flutterTts.speak(tts!);
      }
    }
  }

  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;

      if(index == 0)
        {
          setState(() {
            _tts = "Object Detection";
            speak(_tts);
            Vibration.vibrate(amplitude: 30, duration: 100);
          });
        }

      else if(index == 1)
      {
        setState(() {
          _tts = "Text Recognition";
          speak(_tts);
          Vibration.vibrate(amplitude: 50, duration: 300);
        });
      }

      else if(index == 2)
      {
        setState(() {
          _tts = "Currency Detector";
          speak(_tts);
          Vibration.vibrate(amplitude: 80, duration: 600);
        });
      }

      else if(index == 3)
      {
        setState(() {
          _tts = "Search Screen";
          speak(_tts);
          Vibration.vibrate(amplitude: 120, duration: 900);
        });
      }

      else if(index == 4)
      {
        setState(() {
          _tts = "S.O.S";
          speak(_tts);
          Vibration.vibrate(amplitude: 170, duration: 1200);
        });
      }

      else if(index == 5)
      {
        setState(() {
          _tts = "Navigation";
          speak(_tts);
          Vibration.vibrate(amplitude: 170, duration: 1200);
        });
      }

    });
  }

  void permissionRequests()async{

    await Permission.camera.request();
    await Permission.audio.request();
    await Permission.microphone.request();
    await Permission.sms.request();
    await telephony.requestPhoneAndSmsPermissions;
  }

  @override
  void initState(){
    super.initState();
    permissionRequests();

    // Get the current location
    location.getLocation().then((locationData) {
      setState(() {
        _currentLocation = locationData;
        myPosition = LatLng(_currentLocation!.latitude ?? 0, _currentLocation!.longitude ?? 0);
      });
    });

    // Listen to location updates every second
    _locationSubscription = location.onLocationChanged.listen((locationData) {
      setState(() {
        _currentLocation = locationData;
        getUserCurrentAddress();
        myPosition = LatLng(_currentLocation!.latitude ?? 0, _currentLocation!.longitude ?? 0);
      });
    });


    BlindUserAssistantMethods.readCurrentOnlineBlindUserInfo();

    Timer(const Duration(seconds: 10), () async {
      setState(() {
          userName = blindUserModelCurrentInfo!.name!;
          userEmail = blindUserModelCurrentInfo!.email!;
          userPhone = blindUserModelCurrentInfo!.phone!;
        });
    });




    // _initPicovoice();
    tabController = TabController(length: 6, vsync: this);
    initTts();
    ShakeDetector detector = ShakeDetector.waitForStart(onPhoneShake: () {
      if (sosCount == 0) {
        initTime = DateTime.now();
        ++sosCount;
      } else {
        if (DateTime.now().difference(initTime).inSeconds < 4) {
          ++sosCount;
          if (sosCount == 5) {
            audioPlayer.open(Audio("audios/Mail Sent.mp3"));
            audioPlayer.play();

            Timer(const Duration(seconds: 2), () async {
              sendSms();
              sosCount = 0;
            });
          }
          print(sosCount);
        } else {
          sosCount = 0;
          print(sosCount);
        }
      }
    });

    detector.startListening();

    setState(() {
      _tts = "Object Detection. Tap the screen to detect objects";
      speak(_tts);
    });

  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
          ),
          child: BlindUserDrawer(
            name: userName,
            email: userEmail,
          ),
        ),
      ),

      body: Stack(
        children: [
          TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: tabController,
            children: const [
              ObjectDetectionTabPage(),
              OpticalCharacterRecognitionTab(),
              CurrencyDetectionTab(),
              SearchEngineTab(),
              SOSTabPage(),
              NavigationTab(),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.06,
            left: MediaQuery.of(context).size.height * 0.01,
            child: GestureDetector(
              onTap: () {
                if (openNavigationDrawer) {
                  sKey.currentState!.openDrawer();
                }
                else {
                  //restart the app programatically to update app stats
                  SystemNavigator.pop();
                }
              },
              child: CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 3, 152, 158),
                child: Icon(
                  openNavigationDrawer
                      ? Icons.menu
                      : Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Identity",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_snippet_outlined),
            label: "Text",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange_outlined),
            label: "Currency",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Assistant",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sos_rounded),
            label: "S.O.S",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Navigate",
          ),
        ],
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 3, 152, 158),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
