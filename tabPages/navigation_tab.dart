import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../global/global.dart';
import '../mainScreens/select_nearest_assistant_screen.dart';
import '../services/blind_user_models/active_nearby_available_assistants.dart';
import '../services/blind_user_models/assistance_methods.dart';
import '../services/blind_user_models/geofire_assistant.dart';
import '../services/search_places.dart';

class NavigationTab extends StatefulWidget {
  const NavigationTab({super.key});

  @override
  State<NavigationTab> createState() => _NavigationTabState();
}

class _NavigationTabState extends State<NavigationTab> with WidgetsBindingObserver{
  LatLng? _destinationLocation;

  //search places controller
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  MapController? _mapController;


  List<SearchPlacesData> _options = <SearchPlacesData>[];
  bool isPlaceTileActive = false;
  bool isDestinationFound = false;
  bool drawPolyline = false;
  final FlutterTts _flutterTts = FlutterTts();

  Timer? timer;

//Polyline points coordinates
  late LatLng polyLineStartingPoint;
  late LatLng polylineEndingPoint;
  List<LatLng> routeCoordinates = [];



  LatLng? mapCenter;

  String? userDestinationAddress;

  bool navigationMode = false;

  CameraImage? imgCamera;
  CameraController? _cameraController;
  bool isWorking = false;

  late final Future<void> _future;
  String result = "";
  // ignore: non_constant_identifier_names
  double result_confidence = 0;

  //Text to speech variables
  String forTTS = ""; //for text to speech
  String? _tts;


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


  //decode user destination address
  Future<String> getUserDestinationAddress() async{
    if(_destinationLocation != null){

      var dclient = http.Client();
      String url ='https://nominatim.openstreetmap.org/reverse?format=json&lat=${_destinationLocation!.latitude}&lon=${_destinationLocation!.longitude}&zoom=18&addressdetails=1';
      var response = await dclient.post(Uri.parse(url));
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes))
      as Map<dynamic, dynamic>;

      setState(() {
        userDestinationAddress = decodedResponse['display_name'];
        blindUserDropOffAddress = userDestinationAddress!;
      });

      print(userDestinationAddress);

    }

    else{
      print("ERROR IN FINDING DESTINATION COORDINATES");
    }
    return userDestinationAddress!;
  }

  //Fetch route to draw a polyline
  Future<List<LatLng>> fetchRouteCoordinates(LatLng start, LatLng end) async {
    String url = 'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';

    print("URL: $url");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var steps = jsonResponse['routes'][0]['legs'][0]['steps'];
      var geometry = jsonResponse['routes'][0]['geometry']['coordinates'];
      var totalDistance = jsonResponse['routes'][0]['distance'] / 1000;

      for (var i = 0; i < geometry.length; i++) {
        routeCoordinates.add(LatLng(geometry[i][1], geometry[i][0]));
      }

      print("Route Coordinates: $routeCoordinates");

      // Speak out each turn
      double distance = 0;
      for (var i = 0; i < steps.length; i++) {
        if (steps[i]['maneuver']['type'] == 'turn') {
          String direction;
          if (steps[i]['maneuver']['modifier'] == 'left') {
            direction = 'left';
          } else if (steps[i]['maneuver']['modifier'] == 'right') {
            direction = 'right';
          } else {
            direction = 'straight';
          }
          double stepDistance = steps[i]['distance'] / 1000;
          distance += stepDistance;

          if(distance < 1){
            distance = distance * 1000;
            await _flutterTts.speak('In ${stepDistance.toStringAsFixed(1)} meters, turn $direction');
          }
          else{
            await _flutterTts.speak('In ${stepDistance.toStringAsFixed(1)} kilometers, turn $direction');
          }
        }
      }

      if(totalDistance < 1){
        totalDistance = totalDistance * 1000;
        await _flutterTts.speak('Navigating to $userDestinationAddress, the Total trip distance is ${totalDistance.toStringAsFixed(1)} meters');
      }
      else{
        await _flutterTts.speak('Navigating to $userDestinationAddress, Total trip distance is ${totalDistance.toStringAsFixed(1)} kilometers');
      }

      _mapController!.move(LatLng((start.latitude +end.latitude) / 2,
          (start.longitude + end.longitude) / 2), 18);

      return routeCoordinates;

    } else {
      throw Exception('Failed to load route.');
    }
  }

  Future<void> fetchRoute() async {
    List<LatLng> coordinates = await fetchRouteCoordinates(polyLineStartingPoint, polylineEndingPoint);
    setState(() {
      routeCoordinates = coordinates;
    });
  }

  Future<void> _updateMapController() async {
    setState(() {
      _mapController!.move(
        LatLng(myPosition!.latitude, myPosition!.longitude),
        18.0,
      );
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize the location plugin

    _mapController = MapController();
    _updateMapController();

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
  void dispose() {
    super.dispose();
    _stopCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !navigationMode ? Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(myPosition!.latitude, myPosition!.longitude,),
              zoom: 18,
              maxZoom: 25,
              minZoom: 5,
            ),
            children: [
              // Layer that adds the map
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              // Layer that adds points the map
              MarkerLayer(
                markers: [
                  // First Marker
                  Marker(
                    point: LatLng(myPosition!.latitude, myPosition!.longitude,),
                    width: MediaQuery.of(context).size.height*0.06,
                    height: MediaQuery.of(context).size.height*0.06,
                    builder: (context) => Image.asset("images/origin.png"),
                  ),
                  // Second Marker
                  if(isDestinationFound) Marker(
                    point: LatLng(_destinationLocation!.latitude, _destinationLocation!.longitude),
                    width: MediaQuery.of(context).size.height*0.06,
                    height: MediaQuery.of(context).size.height*0.06,
                    builder: (context) => Image.asset("images/destination.png"),
                  )
                  else Marker(
                    point: LatLng(myPosition!.latitude, myPosition!.longitude,),
                    width: MediaQuery.of(context).size.height*0.06,
                    height: MediaQuery.of(context).size.height*0.06,
                    builder: (context) => Image.asset("images/origin.png"),
                  ),
                ],
              ),

              // Polylines layer
              if(drawPolyline) PolylineLayer(
                polylineCulling: true,
                polylines: [
                  Polyline(
                    points: routeCoordinates,
                    color: const Color.fromARGB(255, 3, 152, 158),
                    borderColor: Colors.red,
                    borderStrokeWidth: 3,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ],
          ),

          //TextField for Searching a location
          if(!isDestinationFound)Positioned(
            top: MediaQuery.of(context).size.height*0.06,
            left: MediaQuery.of(context).size.width*0.16,
            right: MediaQuery.of(context).size.width*0.03,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextFormField(
                      keyboardType: TextInputType.streetAddress,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 3, 152, 158),
                      ),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: Color.fromARGB(255, 3, 152, 158),
                        ),
                        labelText: "Search Location",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 3, 152, 158),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 3, 152, 158),
                          ),
                        ),
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 3, 152, 158),
                          fontSize: 14,
                        ),
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 3, 152, 158),
                          fontSize: 14,
                        ),
                      ),
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: (String value) async {
                        if (_debounce?.isActive ?? false) _debounce?.cancel();

                        if(value.isNotEmpty){
                          setState(() {
                            isPlaceTileActive = true;
                          });
                        }
                        else{
                          setState(() {
                            isPlaceTileActive = false;
                          });
                        }
                        _debounce =
                            Timer(const Duration(milliseconds: 2000), () async {
                              if (kDebugMode) {
                                print(value);
                              }
                              var client = http.Client();
                              try {
                                String url =
                                    'https://nominatim.openstreetmap.org/search?q=$value&format=json&polygon_geojson=1&addressdetails=1';
                                if (kDebugMode) {
                                  print(url);
                                }
                                var response = await client.post(Uri.parse(url));
                                var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
                                if (kDebugMode) {
                                  print(decodedResponse);
                                }
                                _options = decodedResponse
                                    .map((e) => SearchPlacesData(
                                    displayAddressName: e['display_name'],
                                    lat: double.parse(e['lat']),
                                    lon: double.parse(e['lon'])))
                                    .toList();
                                _options = _options.reversed.toList();
                                setState(() {});
                              } finally {
                                client.close();
                              }
                              setState(() {});
                            });

                      }
                  ),
                ),
                StatefulBuilder(
                  builder: ((context, setState) {
                    return Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 3, 152, 158),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: isPlaceTileActive
                            ?ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _options.length > 5
                                ? 5
                                : _options.length,
                            itemBuilder: (context, index) {
                              return SingleChildScrollView(
                                child: ListTile(
                                  title: Text(
                                    _options[index].displayAddressName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                      '${_options[index].lat},${_options[index].lon}'
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _destinationLocation = LatLng(_options[index].lat, _options[index].lon);

                                      mapCenter = LatLng(_destinationLocation!.latitude, _destinationLocation!.longitude);

                                      polyLineStartingPoint = LatLng(myPosition!.latitude, myPosition!.longitude,);
                                      polylineEndingPoint = LatLng(_destinationLocation!.latitude, _destinationLocation!.longitude);


                                      getUserDestinationAddress();
                                      _startCamera();
                                      fetchRoute();

                                      //initialize GeoFire
                                      initializeGeoFireListener();

                                      _mapController?.move(mapCenter!, 15);
                                      if(_destinationLocation != null){
                                        setState(() async{
                                          isPlaceTileActive = false;
                                          isDestinationFound = true;
                                          drawPolyline = true;

                                          Timer(const Duration(seconds: 10), () async {
                                            navigationMode = true;

                                            setState(() {});
                                          });
                                        });
                                      }
                                      if(navigationMode){
                                        // loadModel();
                                      }

                                      _focusNode.unfocus();
                                      _options.clear();
                                    });
                                  },
                                ),
                              );
                            }
                        )
                            : Container()
                    );
                  }
                  ),
                ),

              ],
            ),
          ),

          //UI Tile showing Current Location
          if(!isDestinationFound)Positioned(
            bottom: MediaQuery.of(context).size.height*0.00,
            left: MediaQuery.of(context).size.width*0.06,
            right: MediaQuery.of(context).size.width*0.06,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: MediaQuery.of(context).size.width * 0.15,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),

                child: Padding(
                  padding:  EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.02,
                      vertical: MediaQuery.of(context).size.width * 0.03,
                  ),
                  child: Column(
                    children: [
                      //fromLocation
                      Row(
                        children: [
                          const Icon(
                            Icons.my_location,
                            color: Color.fromARGB(255, 3, 152, 158),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.69,
                                child: Text(
                                  blindUserCurrentAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade ,
                                  softWrap: false,
                                  style: const TextStyle
                                    (
                                      color: Color.fromARGB(255, 3, 152, 158),
                                      fontSize: 15
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color.fromARGB(255, 3, 152, 158),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //UI Tile showing Current Location and Destination
          if(isDestinationFound)Positioned(
            bottom: MediaQuery.of(context).size.height * 0.00,
            left: MediaQuery.of(context).size.width * 0.06,
            right: MediaQuery.of(context).size.width * 0.06,

            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: MediaQuery.of(context).size.width * 0.52,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),

                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15
                  ),
                  child: Column(
                    children: [
                      //fromLocation
                      Row(
                        children: [
                          const Icon(
                            Icons.my_location,
                            color: Color.fromARGB(255, 3, 152, 158),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.69,
                                child: Text(
                                  "FROM: $blindUserCurrentAddress",
                                  maxLines: 1,
                                  overflow: TextOverflow.fade ,
                                  softWrap: false,
                                  style: const TextStyle
                                    (
                                      color: Color.fromARGB(255, 3, 152, 158),
                                      fontSize: 15
                                  ),
                                ),
                              ),


                            ],
                          ),

                        ],
                      ),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color.fromARGB(255, 3, 152, 158),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.05,
                      ),

                      //ToLocation
                      Row(
                        children: [
                          const Icon(
                            Icons.add_location_alt_outlined,
                            color: Color.fromARGB(255, 3, 152, 158),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.69,
                                child: Text(
                                  "TO: $userDestinationAddress",
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: const TextStyle
                                    (
                                      color: Color.fromARGB(255, 3, 152, 158),
                                      fontSize: 15
                                  ),
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color.fromARGB(255, 3, 152, 158),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.05,
                      ),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            drawPolyline = false;
                            isDestinationFound = false;
                            _searchController.text = "";
                            _flutterTts.speak("Navigation has been cancelled");


                            mapCenter = LatLng(myPosition!.latitude, myPosition!.longitude,);

                            _mapController?.move(mapCenter!, 15);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 3, 152, 158),
                          shape: const StadiumBorder(),
                          side: const BorderSide(
                              color: Color.fromARGB(255, 195, 250, 244), width: 2),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text(
                          "Cancel Navigation",
                          style: TextStyle(
                            color:  Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ),
          ),
        ],
      )
          : Stack(
        children: [
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onLongPress: (){
                    if (_destinationLocation != null) {
                      saveAssistanceRequestInformation();

                    } else {
                      Fluttertoast.showToast(
                        msg: "Please select destination location",
                      );
                    }
                  },

                  child: Container (
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    margin: const EdgeInsets.all(0),
                    height: MediaQuery.of(context).size.height * 1,
                    width: MediaQuery.of(context).size.width * 1,
                    child: FutureBuilder<List<CameraDescription>>(
                      future: availableCameras(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _initCameraController(snapshot.data!);

                          return CameraPreview(
                            _cameraController!,
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Column(
                children: [
                  Text(
                    result,
                    style: const TextStyle(
                        backgroundColor: Colors.transparent,
                        fontSize: 10.0,
                        color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.width * 0.06,
            right: MediaQuery.of(context).size.width * 0.06,

            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                padding: const EdgeInsets.all(9),
                height: MediaQuery.of(context).size.width * 0.52,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: GestureDetector(

                  //Long press the map to cancel navigation mode
                  onDoubleTap: (){
                    setState(() {
                      drawPolyline = false;
                      isDestinationFound = false;
                      _searchController.text = "";
                      navigationMode = false;
                      _flutterTts.speak("Navigation has been cancelled");


                      mapCenter = LatLng(myPosition!.latitude, myPosition!.longitude,);

                      routeCoordinates = [];
                      _stopCamera();
                      _mapController?.move(mapCenter!, 15);
                    });
                  },
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: LatLng(myPosition!.latitude, myPosition!.longitude,),
                      zoom: 18,
                      maxZoom: 25,
                      minZoom: 5,
                    ),
                    children: [
                      // Layer that adds the map
                      TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                      ),
                      // Layer that adds points the map
                      MarkerLayer(
                        markers: [
                          // First Marker
                          Marker(
                            point: LatLng(myPosition!.latitude , myPosition!.longitude,),
                            width: MediaQuery.of(context).size.height*0.06,
                            height: MediaQuery.of(context).size.height*0.06,
                            builder: (context) => Image.asset("images/origin.png"),
                          ),
                          // Second Marker
                          if(isDestinationFound) Marker(
                            point: LatLng(_destinationLocation!.latitude, _destinationLocation!.longitude),
                            width: MediaQuery.of(context).size.height*0.06,
                            height: MediaQuery.of(context).size.height*0.06,
                            builder: (context) => Image.asset("images/destination.png"),
                          )
                          else Marker(
                            point: LatLng(myPosition!.latitude, myPosition!.longitude,),
                            width: MediaQuery.of(context).size.height*0.06,
                            height: MediaQuery.of(context).size.height*0.06,
                            builder: (context) => Image.asset("images/origin.png"),
                          ),
                        ],
                      ),

                      // Polylines layer
                      if(drawPolyline) PolylineLayer(
                        polylineCulling: true,
                        polylines: [
                          Polyline(
                            points: routeCoordinates,
                            color: const Color.fromARGB(255, 3, 152, 158),
                            borderColor: Colors.red,
                            borderStrokeWidth: 3,
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ActiveNearByAvailableAssistants> onlineNearByAvailableAssistantsList = [];

  DatabaseReference? referenceAssistanceRequest;
  String assistantActivityStatus = "Assistant is Coming";
  StreamSubscription<DatabaseEvent>? assistanceRequestInfoStreamSubscription;

  String blindUserAssistanceRequestStatus = "";
  bool requestPositionInfo = true;


  saveAssistanceRequestInformation() {
    //1. save the AssistanceRequest Information
    referenceAssistanceRequest = FirebaseDatabase.instance.ref().child("All Assistance Requests").push();


    var originLocation = myPosition;
    var destinationLocation = _destinationLocation;

    print("THIS IS THE ORIGIN LOCATION DATA ""$originLocation");
    print("THIS IS THE ORIGIN LOCATION DATA ""$originLocation");
    print("THIS IS THE ORIGIN LOCATION DATA ""$originLocation");
    print("THIS IS THE ORIGIN LOCATION DATA ""$originLocation");
    print("THIS IS THE ORIGIN LOCATION DATA ""$originLocation");
    print("THIS IS THE ORIGIN LOCATION DATA ""$originLocation");
    print("THIS IS THE ORIGIN LOCATION DATA ""$originLocation");


    print("THIS IS THE DESTINATION LOCATION DATA ""$destinationLocation");
    print("THIS IS THE DESTINATION LOCATION DATA ""$destinationLocation");
    print("THIS IS THE DESTINATION LOCATION DATA ""$destinationLocation");
    print("THIS IS THE DESTINATION LOCATION DATA ""$destinationLocation");
    print("THIS IS THE DESTINATION LOCATION DATA ""$destinationLocation");
    print("THIS IS THE DESTINATION LOCATION DATA ""$destinationLocation");
    print("THIS IS THE DESTINATION LOCATION DATA ""$destinationLocation");
    print("THIS IS THE DESTINATION LOCATION DATA ""$destinationLocation");


    Map originLocationMap = {
      //"key": value,
      "latitude": originLocation!.latitude.toString(),
      "longitude": originLocation.longitude.toString(),
    };

    Map destinationLocationMap = {
      //"key": value,
      "latitude": destinationLocation!.latitude.toString(),
      "longitude": destinationLocation.longitude.toString(),
    };

    Map blindUserInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userName,
      "userPhone": userPhone,
      "originAddress": blindUserCurrentAddress,
      "destinationAddress": userDestinationAddress,
      "assistantId": "waiting",
    };

    print(blindUserInformationMap);

    referenceAssistanceRequest!.set(blindUserInformationMap);

    assistanceRequestInfoStreamSubscription = referenceAssistanceRequest!.onValue.listen((eventSnap) async {
          if (eventSnap.snapshot.value == null) {
            return;
          }

          if ((eventSnap.snapshot.value as Map)["car_details"] != null) {
            setState(() {
              assistantCarDetails =
                  (eventSnap.snapshot.value as Map)["car_details"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["assistantPhone"] != null) {
            setState(() {
              assistantPhone =
                  (eventSnap.snapshot.value as Map)["assistantPhone"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["assistantName"] != null) {
            setState(() {
              assistantName =
                  (eventSnap.snapshot.value as Map)["assistantName"].toString();
            });
          }

          if ((eventSnap.snapshot.value as Map)["status"] != null) {
            blindUserAssistanceRequestStatus =
                (eventSnap.snapshot.value as Map)["status"].toString();
          }

          if ((eventSnap.snapshot.value as Map)["assistantLocation"] != null) {
            double assistantCurrentPositionLat = double.parse(
                (eventSnap.snapshot.value as Map)["assistantLocation"]["latitude"]
                    .toString());
            double assistantCurrentPositionLng = double.parse(
                (eventSnap.snapshot.value as Map)["assistantLocation"]["longitude"]
                    .toString());

            LatLng assistantCurrentPositionLatLng =
            LatLng(assistantCurrentPositionLat, assistantCurrentPositionLng);

            //status = accepted
            if (blindUserAssistanceRequestStatus == "accepted") {
              updateArrivalTimeToUserPickupLocation(assistantCurrentPositionLatLng);
            }

            //status = arrived
            if (blindUserAssistanceRequestStatus == "arrived") {
              setState(() {
                assistantActivityStatus = "Assistant has Arrived";
              });
            }

            //status = busy
            if (blindUserAssistanceRequestStatus == "busy") {
              updateReachingTimeToUserDropOffLocation(assistantCurrentPositionLatLng);
            }

            //status = ended
            if (blindUserAssistanceRequestStatus == "ended") {
              //Implement code for when the journey has ended
            }
          }
        });

    onlineNearByAvailableAssistantsList = GeoFireAssistant.activeNearByAvailableAssistantsList;
    searchNearestOnlineAssistant();
  }

  updateArrivalTimeToUserPickupLocation(assistantCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      LatLng userPickUpPosition = LatLng(myPosition!.latitude, myPosition!.longitude);

      var directionDetailsInfo =
      await BlindUserAssistantMethods.obtainOriginToDestinationDirectionDetails(
        assistantCurrentPositionLatLng,
        userPickUpPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        assistantActivityStatus = "Assistant is Coming : " +
            directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(assistantCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation = _destinationLocation;

      LatLng blindUserDestinationPosition = LatLng(dropOffLocation!.latitude,dropOffLocation.longitude);

      var directionDetailsInfo = await BlindUserAssistantMethods.obtainOriginToDestinationDirectionDetails(
        assistantCurrentPositionLatLng,
        blindUserDestinationPosition,
      );

      if (directionDetailsInfo == null) {
        return;
      }

      setState(() {
        assistantActivityStatus = "Going towards Destination : " +
            directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  searchNearestOnlineAssistant() async {
    //if there are no active assistants available
    if (onlineNearByAvailableAssistantsList.length == 0) {
      //delete assistance request information

      referenceAssistanceRequest!.remove();
      setState(() {
      });

      Fluttertoast.showToast(msg: "No online nearest Assistants are available");

      _flutterTts.speak("No online nearest assistants are available please. Please contact your emergency contacts to get assistance");

      Future.delayed(Duration(milliseconds: 4000), () {
        // SystemNavigator.pop();
      });

      return;
    }

    //active assistants available
    await retrieveOnlineAssistantsInformation(onlineNearByAvailableAssistantsList);

    var response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => SelectNearestActiveAssistantScreen(
                referenceAssistanceRequest: referenceAssistanceRequest
            )
        )
    );

    //response from SelectActiveNearestAssistantScreen
    if (response == "assistantChoosed") {
      FirebaseDatabase.instance
          .ref()
          .child("assistantUsers")
          .child(chosenAssistantId!)
          .once()
          .then((snap) {
        if (snap.snapshot.value != null) {
          //send notification to that specific assistantUser
          sendNotificationToAssistantNow(chosenAssistantId!);

          //Display Waiting Response UI from a assistantUser
          //  showWaitingResponseFromAssistantUI(TO BE IMPLEMENTED);

          //Response from a assistantUser
          FirebaseDatabase.instance
              .ref()
              .child("assistantUsers")
              .child(chosenAssistantId!)
              .child("newAssistanceStatus")
              .onValue
              .listen((eventSnapshot) {
            //1. assistantUser has cancel the assistanceRequest :: Push Notification
            // (newAssistanceStatus = idle)
            if (eventSnapshot.snapshot.value == "idle") {
              Fluttertoast.showToast(
                  msg:
                  "The assistant has cancelled your request. Please choose another assistant."
              );

              _flutterTts.speak("Your assistance request has been rejected. Please try again or shake your phone for 5 seconds to reach your emergency contacts");
              // Future.delayed(const Duration(milliseconds: 3000), () {
              //   Fluttertoast.showToast(msg: "Please Restart App Now.");
              //
              //   SystemNavigator.pop();
              // });
            }

            //2. assistantUsers has accept the assistanceRequest :: Push Notification
            // (newAssistanceStatus = accepted)
            if (eventSnapshot.snapshot.value == "accepted") {
              //design and display ui for displaying assigned assistantUser information {NOT Implemented}
              // showUIForAssignedAssistantInfo();
              _flutterTts.speak("Your assistance request has been accepted. Please stay close to your current location");
            }
          });
        } else {
          Fluttertoast.showToast(msg: "This assistant does not exist. Try again.");
        }
      });
    }
  }


  sendNotificationToAssistantNow(String chosenAssistantId) {
    //assign/SET assistanceRequestId to newAssistanceStatus in
    // assistantUser Parent node for that specific chosen assistantUser
    FirebaseDatabase.instance
        .ref()
        .child("assistantUsers")
        .child(chosenAssistantId)
        .child("newAssistanceStatus")
        .set(referenceAssistanceRequest!.key);

    //automate the push notification service
    FirebaseDatabase.instance
        .ref()
        .child("assistantUsers")
        .child(chosenAssistantId)
        .child("token")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String deviceRegistrationToken = snap.snapshot.value.toString();

        //send Notification Now
        BlindUserAssistantMethods.sendNotificationToAssistantNow(
          deviceRegistrationToken,
          referenceAssistanceRequest!.key.toString(),
          context,
        );

        Fluttertoast.showToast(msg: "Assistance request has been sent Successfully.");
        _flutterTts.speak("Assistance request has been sent Successfully.");
      } else {
        Fluttertoast.showToast(msg: "Please choose another assistant.");
        return;
      }
    });
  }

  retrieveOnlineAssistantsInformation(List onlineNearestAssistantList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("assistantUsers");
    for (int i = 0; i < onlineNearestAssistantList.length; i++) {
      await ref
          .child(onlineNearestAssistantList[i].assistantId.toString())
          .once()
          .then((dataSnapshot) {
        var assistantKeyInfo = dataSnapshot.snapshot.value;
        assistantUserList.add(assistantKeyInfo);
      });
    }
  }

  initializeGeoFireListener() {
    Geofire.initialize("activeAssistants");

    Geofire.queryAtLocation(
        myPosition!.latitude, myPosition!.longitude, 10
    )!.listen((map) {
      print(map);

      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
        //whenever assistant becomes online add to the list
          case Geofire.onKeyEntered:
            ActiveNearByAvailableAssistants activeNearByAvailableAssistants = ActiveNearByAvailableAssistants();

            activeNearByAvailableAssistants.locationLatitude = map['latitude'];
            activeNearByAvailableAssistants.locationLongitude = map['longitude'];
            activeNearByAvailableAssistants.assistantId = map['key'];
            GeoFireAssistant.activeNearByAvailableAssistantsList.add(activeNearByAvailableAssistants);

            break;

        //whenever assistant becomes offline remove from the list
          case Geofire.onKeyExited:
            GeoFireAssistant.deleteOfflineAssistantFromList(map['key']);
            break;

        //whenever assistant moves update location
          case Geofire.onKeyMoved:
            ActiveNearByAvailableAssistants activeNearByAvailableAssistants = ActiveNearByAvailableAssistants();

            activeNearByAvailableAssistants.locationLatitude = map['latitude'];
            activeNearByAvailableAssistants.locationLongitude = map['longitude'];
            activeNearByAvailableAssistants.assistantId = map['key'];

            GeoFireAssistant.updateActiveNearByAvailableAssistantLocation(activeNearByAvailableAssistants);

            break;
        }
      }

      setState(() {});
    });
  }

}

