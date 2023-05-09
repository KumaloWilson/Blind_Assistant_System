import 'dart:async';
import 'dart:convert';
import 'package:arti_eyes/global/global.dart';
import 'package:arti_eyes/services/assistant_user_models/assistance_methods.dart';
import 'package:arti_eyes/services/assistant_user_models/user_assistance_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import '../widgets/progress_dialog.dart';


class NewTripScreen extends StatefulWidget
{
  BlindUserAssistanceRequestInformation? blindUserAssistanceRequestDetails;

  NewTripScreen({
    this.blindUserAssistanceRequestDetails,
  });

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}




class _NewTripScreenState extends State<NewTripScreen>
{

//Polyline points coordinates
  List<LatLng> routeCoordinates = [];

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.white;
  LocationData? onlineAssistantCurrentPosition;
  String assistanceRequestStatus = "accepted";
  String durationFromOriginToDestination = "";
  bool isRequestDirectionDetails = false;
  var userPickUpLatLng;
  MapController? _mapController;

  Future<List<LatLng>> drawPolyLineFromOriginToDestination(LatLng start, LatLng end) async
  {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Please wait...",),
    );

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

      return routeCoordinates;

    } else {
      throw Exception('Failed to load route.');
    }
  }

  Future<void> fetchRoute() async {
    List<LatLng> coordinates = await drawPolyLineFromOriginToDestination(widget.blindUserAssistanceRequestDetails!.originLatLng!, widget.blindUserAssistanceRequestDetails!.destinationLatLng!);
    setState(() {
      routeCoordinates = coordinates;


      print("ROUTE FETCHED");
      print("ROUTE FETCHED");

      print("ROUTE FETCHED");
      print("ROUTE FETCHED");
      print("ROUTE FETCHED");
      print("ROUTE FETCHED");

      print("ROUTE FETCHED");
      print("ROUTE FETCHED");
      print("ROUTE FETCHED");
      print("ROUTE FETCHED");

      print("ROUTE FETCHED");
      print("ROUTE FETCHED");
      print("ROUTE FETCHED");
      print("ROUTE FETCHED");

      print("ROUTE FETCHED");
      print("ROUTE FETCHED");
      print("ROUTE FETCHED");
      print("ROUTE FETCHED");

      print("ROUTE FETCHED");
      print("ROUTE FETCHED");
    });
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    userPickUpLatLng = widget.blindUserAssistanceRequestDetails!.originLatLng;

    getAssistantUserLocationUpdatesAtRealTime();

    saveAssignedAssistantDetailsToUserRideRequest();
  }



  getAssistantUserLocationUpdatesAtRealTime()
  {
    LatLng oldLatLng = LatLng(0, 0);

    streamSubscriptionAssistantLivePosition = location.onLocationChanged.listen((locationData) {
      assistantCurrentPosition = locationData;
      onlineAssistantCurrentPosition = locationData;

      LatLng latLngLiveAssistantPosition = LatLng(
        onlineAssistantCurrentPosition!.latitude ?? 0,
        onlineAssistantCurrentPosition!.longitude ?? 0,
      );


      setState(() {

      });

      oldLatLng = latLngLiveAssistantPosition;
      updateDurationTimeAtRealTime();

      //updating driver location at real time in Database
      Map assistantLatLngDataMap =
      {
        "latitude": onlineAssistantCurrentPosition!.latitude.toString(),
        "longitude": onlineAssistantCurrentPosition!.longitude.toString(),
      };
      FirebaseDatabase.instance.ref().child("All Assistance Requests")
          .child(widget.blindUserAssistanceRequestDetails!.assistanceRequestId!)
          .child("assistantLocation")
          .set(assistantLatLngDataMap);
    });

  }

  updateDurationTimeAtRealTime() async
  {
    if(isRequestDirectionDetails == false)
    {
      isRequestDirectionDetails = true;

      if(onlineAssistantCurrentPosition == null)
      {
        return;
      }

      var originLatLng = LatLng(
        onlineAssistantCurrentPosition!.latitude ?? 0,
        onlineAssistantCurrentPosition!.longitude ?? 0,
      ); //Driver current Location

      LatLng? destinationLatLng;

      if(assistanceRequestStatus == "accepted")
      {
        destinationLatLng = widget.blindUserAssistanceRequestDetails!.originLatLng; //user PickUp Location
      }
      else
      {
        destinationLatLng = widget.blindUserAssistanceRequestDetails!.destinationLatLng; //user DropOff Location
      }

      isRequestDirectionDetails = false;
    }
  }


  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Stack(
        children: [

          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(assistantCurrentPosition!.latitude ?? 0, assistantCurrentPosition!.longitude ?? 0),
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
                    point: LatLng(assistantCurrentPosition!.latitude ?? 0, assistantCurrentPosition!.longitude ?? 0),
                    width: MediaQuery.of(context).size.height*0.06,
                    height: MediaQuery.of(context).size.height*0.06,
                    builder: (context) => Image.asset("images/origin.png"),
                  ),
                  Marker(
                    point: userPickUpLatLng,
                    width: MediaQuery.of(context).size.height*0.06,
                    height: MediaQuery.of(context).size.height*0.06,
                    builder: (context) => Image.asset("images/destination.png"),
                  ),
                ],
              ),
              PolylineLayer(
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

          //ui
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.00,
            left: MediaQuery.of(context).size.width * 0.06,
            right: MediaQuery.of(context).size.width * 0.06,

            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow:
                [
                  BoxShadow(
                    color: Color.fromARGB(255, 3, 152, 158),
                    blurRadius: 30,
                    spreadRadius: .5,
                    offset: Offset(0.6, 0.6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [

                    //duration
                    Text(
                      durationFromOriginToDestination +" away",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 3, 152, 158),
                      ),
                    ),

                    const SizedBox(height: 18,),

                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Color.fromARGB(255, 3, 152, 158),
                    ),

                    const SizedBox(height: 8,),

                    //user name - icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.blindUserAssistanceRequestDetails!.userName!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 3, 152, 158),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                            color: Color.fromARGB(255, 3, 152, 158),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18,),

                    //user PickUp Address with icon
                    Row(
                      children: [
                        Image.asset(
                          "images/origin.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 14,),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.blindUserAssistanceRequestDetails!.originAddress!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 3, 152, 158),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20.0),

                    //user DropOff Address with icon
                    Row(
                      children: [
                        Image.asset(
                          "images/destination.png",
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 14,),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.blindUserAssistanceRequestDetails!.destinationAddress!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 3, 152, 158),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24,),

                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Color.fromARGB(255, 3, 152, 158),
                    ),

                    const SizedBox(height: 10.0),

                    ElevatedButton.icon(
                      onPressed: () async
                      {
                        //[driver has arrived at user PickUp Location] - Arrived Button
                        if(assistanceRequestStatus == "accepted")
                        {
                          assistanceRequestStatus = "arrived";

                          FirebaseDatabase.instance.ref()
                              .child("All Assistance Requests")
                              .child(widget.blindUserAssistanceRequestDetails!.assistanceRequestId!)
                              .child("status")
                              .set(assistanceRequestStatus);

                          setState(() {
                            buttonTitle = "Start Trip"; //start the trip
                            buttonColor = Color.fromARGB(255, 3, 152, 158);
                          });

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext c)=> ProgressDialog(
                              message: "Loading...",
                            ),
                          );

                          await fetchRoute();

                          Navigator.pop(context);
                        }
                        //[user has already sit in driver's car. Driver start trip now] - Lets Go Button
                        else if(assistanceRequestStatus == "arrived")
                        {
                          assistanceRequestStatus = "ontrip";

                          FirebaseDatabase.instance.ref()
                              .child("All Assistance Requests")
                              .child(widget.blindUserAssistanceRequestDetails!.assistanceRequestId!)
                              .child("status")
                              .set(assistanceRequestStatus);

                          setState(() {
                            buttonTitle = "End Trip"; //end the trip
                            buttonColor = Colors.redAccent;
                          });
                        }
                        //[user/Driver reached to the dropOff Destination Location] - End Trip Button
                        else if(assistanceRequestStatus == "ontrip")
                        {
                          endTripNow();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)
                        ),
                      ),
                      icon: const Icon(
                        Icons.directions_car,
                        color: Color.fromARGB(255, 3, 152, 158),
                        size: 25,
                      ),
                      label: Text(
                        buttonTitle!,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 3, 152, 158),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  endTripNow() async
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)=> ProgressDialog(message: "Please wait...",),
    );

    //get the tripDirectionDetails = distance travelled
    var currentAssistantPositionLatLng = LatLng(
      onlineAssistantCurrentPosition!.latitude ?? 0,
      onlineAssistantCurrentPosition!.longitude ?? 0,
    );

    FirebaseDatabase.instance.ref().child("All Assistance Requests")
        .child(widget.blindUserAssistanceRequestDetails!.assistanceRequestId!)
        .child("status")
        .set("ended");

    streamSubscriptionAssistantLivePosition!.cancel();

    Navigator.pop(context);

  }

  saveAssignedAssistantDetailsToUserRideRequest()
  {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref()
                                          .child("All Assistance Requests")
                                          .child(widget.blindUserAssistanceRequestDetails!.assistanceRequestId!);

    Map assistantUserLocationDataMap =
    {
      "latitude": assistantCurrentPosition!.latitude.toString(),
      "longitude": assistantCurrentPosition!.longitude.toString(),
    };
    databaseReference.child("assistantLocation").set(assistantUserLocationDataMap);

    databaseReference.child("status").set("accepted");
    databaseReference.child("assistantId").set(onlineAssistantUserData.id);
    databaseReference.child("assistantName").set(onlineAssistantUserData.name);
    databaseReference.child("assistantPhone").set(onlineAssistantUserData.phone);
    databaseReference.child("availability_details").set(onlineAssistantUserData.residentialAddress.toString() + " " + onlineAssistantUserData.cityProvince.toString() +" "+ onlineAssistantUserData.nationalIDNumber.toString());

  }

}