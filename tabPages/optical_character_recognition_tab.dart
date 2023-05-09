import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/results_dialog.dart';

class OpticalCharacterRecognitionTab extends StatefulWidget {
  const OpticalCharacterRecognitionTab({super.key});

  @override
  State<OpticalCharacterRecognitionTab> createState() => _OpticalCharacterRecognitionTabState();
}

class _OpticalCharacterRecognitionTabState extends State<OpticalCharacterRecognitionTab> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  bool onOffCameraSwitch = false;

  String? _tts;
  final FlutterTts _flutterTts = FlutterTts();

  late final Future<void> _future;
  CameraController? _cameraController;

  final textRecognizer = TextRecognizer();

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

  Future<void> _scanImage() async {
    if (_cameraController == null) return;

    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);


      // ignore: use_build_context_synchronously
      final navigator = showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext c) {
            return GestureDetector(
              onDoubleTap: (){
                Navigator.pop(context);
              },
              child: Center(
                child: SingleChildScrollView(
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  child: ResultsDialog(
                    text: recognizedText.text,
                  ),
                ),
              ),
            );
          });

      await navigator;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text, please try again'),
        ),

      );
      _tts = "An error occurred when scanning text, please try again";
      _flutterTts.speak(_tts!);
    }
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
    textRecognizer.close();
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
                        onPressed: (){
                          setState(() {
                            if(onOffCameraSwitch == false)
                              {
                                onOffCameraSwitch = true;
                                _startCamera();

                                _tts = "OCR has started successfully. Long press the Screen to Read out detected text";
                                _flutterTts.speak(_tts!);
                              }
                            else
                              {
                                onOffCameraSwitch = false;
                                _stopCamera();
                                _tts = "OCR has been stopped successfully";
                                _flutterTts.speak(_tts!);
                              }
                          });
                        },
                        onLongPress: _scanImage,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 3, 152, 158),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side:  const BorderSide(color: Color.fromARGB(255, 3, 152, 158))
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
                          ?Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.white,
                            ),

                            height: 270,
                            width: 360,
                            child: const Icon(
                              Icons.menu_book_outlined,
                              color: Color.fromARGB(255, 3, 152, 158),
                              size: 100,
                            ),
                          )


                          :FutureBuilder<List<CameraDescription>>(
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
                                          child: Lottie.asset("images/91605-document-scan.json",
                                              width: MediaQuery.of(context).size.width * 0.9
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
                   Container(
                     child: const Center(
                       child: Text(
                           "Permission to preview camera is declined"
                       ),
                     ),
                   )
              ],
            ),
          ),
        );
      },
    );
  }

}
