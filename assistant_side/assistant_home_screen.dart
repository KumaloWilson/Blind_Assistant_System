import 'dart:async';
import 'package:arti_eyes/services/assistant_user_models/assistant_user_model.dart';
import 'package:arti_eyes/widgets/assistant_user_drawer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import '../global/global.dart';
import '../services/_assistant_push_notifications/push_notification system.dart';
import '../services/assistant_user_models/assistance_methods.dart';


class AssistantHomeScreen extends StatefulWidget {
  const AssistantHomeScreen({super.key});

  @override
  State<AssistantHomeScreen> createState() => _AssistantHomeScreenState();
}

class _AssistantHomeScreenState extends State<AssistantHomeScreen> with WidgetsBindingObserver{
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;



  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  bool openNavigationDrawer = true;

  MapController? _mapController;

  Timer? timer;
  bool isCurrentLocationFound = false;
  bool noNetwork = false;

  LatLng? mapCenter;

  String? userCurrentAddress;

  Color buttonColor = const Color.fromARGB(255, 3, 152, 158);


  //decode user current address
  Future<String> locateAssistantPosition() async{
    var client = http.Client();
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${_currentLocation!.latitude}&lon=${_currentLocation!.longitude}&zoom=18&addressdetails=1';
    var response = await client.post(Uri.parse(url));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes))
    as Map<dynamic, dynamic>;

    setState(() {
      userCurrentAddress = decodedResponse['display_name'];
    });

    print(userCurrentAddress);

    return userCurrentAddress!;
  }

  Future<void> _updateMapController() async {
    setState(() {
      _mapController!.move(
        LatLng(_currentLocation!.latitude ?? 0, _currentLocation!.longitude ?? 0),
        18.0,
      );
    });
  }

  readCurrentAssistantInformation() async
  {
    currentFirebaseUser = fAuth.currentUser;

    FirebaseDatabase.instance.ref().child("assistantUsers")
        .child(currentFirebaseUser!.uid)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        onlineAssistantUserData.id = (snap.snapshot as Map)["id"];
        onlineAssistantUserData.name = (snap.snapshot as Map)["name"];
        onlineAssistantUserData.phone = (snap.snapshot as Map)["phone"];
        onlineAssistantUserData.email = (snap.snapshot as Map)["email"];
        onlineAssistantUserData.age = (snap.snapshot as Map)["age"];
        onlineAssistantUserData.residentialAddress = (snap.snapshot as Map)["availability_details"]["residential_address"];
        onlineAssistantUserData.cityProvince = (snap.snapshot as Map)["availability_details"]["city_province"];
        onlineAssistantUserData.nationalIDNumber = (snap.snapshot as Map)["availability_details"]["national_id_number"];

        assistantAvatarType = onlineAssistantUserData.nationalIDNumber = (snap.snapshot as Map)["availability_details"]["avatar_type"];

      }
    });

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generatingAndGetToken();

  }

  assistantIsOnLineNow() async
  {

    assistantCurrentPosition = _currentLocation;

    Geofire.initialize("activeAssistants");
    Geofire.setLocation(
        currentFirebaseUser!.uid,
        assistantCurrentPosition!.latitude ?? 0,
        assistantCurrentPosition!.longitude ?? 0
    );
    DatabaseReference ref = FirebaseDatabase.instance.ref()
        .child("assistantUsers")
        .child(currentFirebaseUser!.uid)
        .child("newAssistanceStatus");

    ref.set("idle");//Waiting for new Assistance request
    ref.onValue.listen((event) { });
  }

  updateAssistantLocationAtRealTime()
  {
    streamSubscriptionPosition = location.onLocationChanged.listen((locationData) {
      setState(() {
        assistantCurrentPosition = locationData;

        if(isAssistantUserActive == true)
        {
          Geofire.setLocation(
              currentFirebaseUser!.uid,
              assistantCurrentPosition!.latitude ?? 0,
              assistantCurrentPosition!.longitude ?? 0
          );
        }

        LatLng latLng = LatLng(
            assistantCurrentPosition!.latitude ?? 0,
            assistantCurrentPosition!.longitude ?? 0
        );

        // _mapController!.move(latLng, 16);

      });
    });
  }

  assistantIsOfflineNow()
  {
    Geofire.removeLocation(currentFirebaseUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance.ref().child("assistantUsers").child(currentFirebaseUser!.uid).child("newAssistanceStatus");

    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000), ()
    {
      Fluttertoast.showToast(msg: "You are now offline");
    });

  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize the location plugin
    _mapController = MapController();
    _updateMapController();
    readCurrentAssistantInformation();

    // Get the current location
    location.getLocation().then((locationData) {
      setState(() {
        _currentLocation = locationData;
      });
      if(_currentLocation == null){
        setState(() {
          isCurrentLocationFound = false;
        });
      }else{
        setState(() {
          isCurrentLocationFound = true;
        });
      }
    });

    // Listen to location updates every second
    _locationSubscription = location.onLocationChanged.listen((locationData) {
      setState(() {
        _currentLocation = locationData;
        locateAssistantPosition();
      });
    });

    AssistantUserAssistantMethods.readCurrentOnlineAssistantUserInfo();

    Timer(const Duration(seconds: 10), () async {
      if(currentFirebaseUser != null){
        setState(() {
          userName = currentFirebaseUser!.displayName!;
          userEmail = currentFirebaseUser!.email!;
        });
      }
    });

    Timer(const Duration(seconds: 30), () async {
      if(_currentLocation == null){
        setState(() {
          noNetwork = true;
        });
      }
    });

  }

  @override
  void dispose() {
    // Cancel the location subscription when the widget is disposed
    _locationSubscription!.cancel();
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
            child: AssistantDrawer(
              name: userName,
              email: userEmail,
            ),
          ),
        ),
        body: isCurrentLocationFound ? Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(_currentLocation!.latitude ?? 0, _currentLocation!.longitude ?? 0,),
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
                      point: LatLng(_currentLocation!.latitude ?? 0, _currentLocation!.longitude ?? 0,),
                      width: MediaQuery.of(context).size.height*0.06,
                      height: MediaQuery.of(context).size.height*0.06,
                      builder: (context) => Image.asset("images/origin.png"),
                    ),
                  ],
                ),
              ],
            ),

            assistantStatusText != "Now Online"
                ? Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              color: Colors.black87,
            )
                : Container(),

            //button for online offline mode
            Positioned(
              top: assistantStatusText != "Now Online"
                  ? MediaQuery.of(context).size.height * 0.46
                  :25,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: ()
                    {
                      if(isAssistantActive != true)//offline
                          {
                        assistantIsOnLineNow();
                        updateAssistantLocationAtRealTime();

                        setState(()
                        {
                          assistantStatusText = "Now Online";
                          isAssistantActive = true;
                          buttonColor = Colors.transparent;
                        });
                        //display Toast
                        Fluttertoast.showToast(msg: "You are now Online!");

                      }
                      else
                      {
                        assistantIsOfflineNow();
                        setState(()
                        {
                          assistantStatusText = "Now Offline";
                          isAssistantActive = false;
                          buttonColor = Color.fromARGB(255, 3, 152, 158);
                        });
                        Fluttertoast.showToast(msg: "You are now Offline!");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)
                      ),
                    ),
                    child: assistantStatusText != "Now Online"
                        ? Row(
                      children: [
                        Text(
                          assistantStatusText,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Icon(
                          Icons.wifi_off,
                          color: Colors.white,
                        ),
                      ],
                    )
                        : Row(
                      children: [
                        Text(
                          assistantStatusText,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 3, 152, 158),
                          ),
                        ),

                        const Icon(
                          Icons.wifi,
                          color: Color.fromARGB(255, 3, 152, 158),
                          size: 26,
                        ),
                      ],
                    ),

                  ),
                ],
              ),
            ),

            //Menu Button
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

            //UI Tile showing Current Location
            if(assistantStatusText == "Now Online")Positioned(
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
                                    "$userCurrentAddress",
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
          ],
        )
            :Container(
              color: Colors.black87,
              child: Stack(
                children: [
                  //Menu Button
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

                  //Checking Internet Connection UI
                  Positioned(
                    bottom: noNetwork ? MediaQuery.of(context).size.height*0.33 : MediaQuery.of(context).size.height*0.43,
                    left: MediaQuery.of(context).size.width*0.05,
                    right: MediaQuery.of(context).size.width*0.05,
                    child: Container(
                      margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: noNetwork ? BorderRadius.circular(30) : BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                        child: !noNetwork ? Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02,
                            ),
                             const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromARGB(255, 3, 152, 158)),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.04,
                            ),
                            const Text(
                              'Loading Map. Please wait.....',
                              style: TextStyle(
                                color: Color.fromARGB(255, 3, 152, 158),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                            : Column(
                          children: [
                            Icon(
                              Icons.wifi_off_sharp,
                              size: MediaQuery.of(context).size.height* 0.2,
                              color: const Color.fromARGB(255, 3, 152, 158),
                            ),
                            const Center(
                              child: Text(
                                'No Internet!\n'
                                    'Please check your internet Connection',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 3, 152, 158),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],

                        )
                      ),
                    ),
                  ),

                ],
        ),
            ),
    );
  }
}