import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import '../global/global.dart';
import '../widgets/note_result_widget.dart';

int total = 0;

class CurrencyDetectionTab extends StatefulWidget {
  const CurrencyDetectionTab({Key? key}) : super(key: key);

  @override
  _CurrencyDetectionTabState createState() => _CurrencyDetectionTabState();
}

class _CurrencyDetectionTabState extends State<CurrencyDetectionTab> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool onOffCameraSwitch = false;
  bool _isPermissionGranted = false;
  late final Future<void> _future;
  final FlutterTts _flutterTts = FlutterTts();
  String? text;

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  if (_isPermissionGranted)
                  Container(
                    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.043,),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (onOffCameraSwitch == false) {
                            setState(() {
                              onOffCameraSwitch = true;
                              text =
                              "Currency Detection has initialized successfully";
                              _flutterTts.speak(text!);
                            });
                          }
                          else if (onOffCameraSwitch == true) {
                            setState(() {
                              onOffCameraSwitch = false;
                              text =
                              "Currency Detection has been stopped successfully";
                              _flutterTts.speak(text!);
                              total = 0;
                            });
                          }
                        },
                        onLongPress: () async {
                          if (onOffCameraSwitch == true) {
                            try {
                              audioPlayer.open(Audio("audios/mixkit-classic-camera-click-1440.wav"));
                              audioPlayer.play();
                              final image = await _cameraController!
                                  .takePicture();

                              if (!mounted) return;


                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DisplayPictureScreen(
                                        image.path,
                                      ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'An error occurred, please try again'),
                                ),

                              );
                              text = "An error occurred, Please try again";
                              _flutterTts.speak(text!);
                            }
                          }

                          else {
                            text =
                            "Please turn on the camera by tapping the screen";
                            _flutterTts.speak(text!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                                255, 3, 152, 158),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: const BorderSide(
                                    color: Color.fromARGB(255, 3, 152, 158)
                                )
                            )
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          margin: const EdgeInsets.all(0),
                          height: MediaQuery.of(context).size.height * 0.86,
                          width: 350,
                          child: onOffCameraSwitch == false
                              ? Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.white,
                            ),

                            height: 270,
                            width: 360,
                            child: const Icon(
                              Icons.money,
                              color: Color.fromARGB(255, 3, 152, 158),
                              size: 100,
                            ),
                          ) :FutureBuilder<List<CameraDescription>>(
                            future: availableCameras(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                _initCameraController(snapshot.data!);

                                return CameraPreview(
                                  _cameraController!,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Lottie.asset("images/41671-scan.json",
                                              width: MediaQuery.of(context).size.width * 0.8,
                                              height: MediaQuery.of(context).size.height * 1

                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return const Center(child: CircularProgressIndicator());
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  if(!_isPermissionGranted)
                    const Center(
                      child: Text(
                          "Permission to preview camera is declined"
                      ),
                    )
                ],
              ),
            ),
          );
        }
    );
  }
}
