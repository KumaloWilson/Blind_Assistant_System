import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class ObjectDetectionTabPage extends StatefulWidget {
  const ObjectDetectionTabPage({Key? key}) : super(key: key);

  @override
  _ObjectDetectionTabPageState createState() => _ObjectDetectionTabPageState();

}
//Camera variables
class _ObjectDetectionTabPageState extends State<ObjectDetectionTabPage> with WidgetsBindingObserver{
  bool onOffCameraSwitch = false;
  bool isWorking = false;
  CameraImage? imgCamera;
  CameraController? _cameraController;
  bool _isPermissionGranted = false;
  late final Future<void> _future;
  String result = "";
  // ignore: non_constant_identifier_names
  double result_confidence = 0;

  //Text to speech variables
  String forTTS = ""; //for text to speech
  FlutterTts _flutterTts = FlutterTts();
  String? _tts;

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera(){
    if (_cameraController != null) {
      _cameraController?.dispose();
      _cameraController?.stopImageStream();
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

    await _cameraController!.initialize().then((value) {
      setState(() {
        _cameraController!.startImageStream((imagesFromStream) => {
          if (!isWorking)
            {
              isWorking = true,
              imgCamera = imagesFromStream,
              runModelStreamFrames(),
            }
        });
      });
    });
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

//Function for loading the model and its labels
  loadModel() async {
    await Tflite.loadModel(
      model: "datasets/object_detection_model/mobilenet_v1_1.0_224.tflite",
      labels: "datasets/object_detection_model/labels.txt",
    );
  }


  //Function for initializing the camera

  //function for detecting and identifying objects
  runModelStreamFrames() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera!.height,
        imageWidth: imgCamera!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 1,
        threshold: 0.1,
        asynch: true,
      );

      result = "";

      recognitions?.forEach((response) {
        result += response["label"] +
            "  " +
            (response["confidence"] as double).toStringAsFixed(2) +
            " detected";

        //confidence level as a percentage
        result_confidence = response["confidence"] * 100;

        //result without confidence for TEXT TO SPEECH
        forTTS = response["label"] + " detected";
      });

      setState(() {
        result;
        result_confidence;
        _tts = forTTS;

        // condition for TTS if result confidence for detected object is greater than 70%
        if (result_confidence > 60.0) {
          _flutterTts.speak(_tts!);
        }
      });

      isWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    WidgetsBinding.instance.addObserver(this);
    _future = _requestCameraPermission();
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();

    super.dispose();
    _flutterTts.stop();

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
    return  FutureBuilder(
        future: _future,
        builder: (context, snapshot){
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
                        if(onOffCameraSwitch == false)
                          {
                            setState(() {
                              onOffCameraSwitch = true;
                              _tts = "Object detection has initialized Successfully";
                              _flutterTts.speak(_tts!);
                              _startCamera();
                            });
                          }
                        else if(onOffCameraSwitch == true)
                          {
                            setState(() {
                              onOffCameraSwitch = false;
                              _tts = "Object detection has Stopped Successfully";
                              _flutterTts.speak(_tts!);
                              _stopCamera();
                            });

                          }

                      },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 3, 152, 158),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side:  const BorderSide(color: Color.fromARGB(255, 3, 152, 158))
                            )
                        ),
                      child: Stack(
                        children: [
                          Container (
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
                                Icons.dashboard_outlined,
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
                                            child: Lottie.asset("images/10257-object-detection-iris-scan.json",
                                                width: MediaQuery.of(context).size.width * 0.7
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
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: SingleChildScrollView(
                      child: Text(
                        result,
                        // ignore: prefer_const_constructors
                        style: TextStyle(
                            backgroundColor: Colors.transparent,
                            fontSize: 10.0,
                            color: Colors.black),
                        textAlign: TextAlign.center,
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
