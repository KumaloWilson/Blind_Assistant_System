import 'dart:convert';
import 'package:arti_eyes/services/assistant_user_models/direction_details_info.dart';
import 'package:arti_eyes/services/assistant_user_models/directions.dart';
import 'package:arti_eyes/services/assistant_user_models/request_assistant.dart';
import 'package:arti_eyes/services/assistant_user_models/assistant_user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../global/global.dart';

class AssistantUserAssistantMethods
{
  static void readCurrentOnlineAssistantUserInfo() async
  {
    currentFirebaseUser = fAuth.currentUser;

    DatabaseReference assistantUserRef = FirebaseDatabase.instance.ref().child("assistantUsers").child(currentFirebaseUser!.uid);

    assistantUserRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        assistantUserModelCurrentInfo = AssistantUserModel.fromSnapShot(snap.snapshot);
        print('ASSISTANT DETAILS CALLED SUCCESSFULLY');
      }
      else{
        print('ASSISTANT DETAILS CALL FAILED');
      }
    });
  }


  static Future<String> searchAddressForGeographicCoOrdinates(LocationData position, context) async
  {
    var dclient = http.Client();
    String apiUrl = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1';

    String humanReadableAddress = "";

    var response = await dclient.post(Uri.parse(apiUrl));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes))
    as Map<dynamic, dynamic>;

    humanReadableAddress = decodedResponse['display_name'];

    Directions blindUserPickUpAddress = Directions();
    blindUserPickUpAddress.locationLatitude = position.latitude;
    blindUserPickUpAddress.locationLongitude = position.longitude;
    blindUserPickUpAddress.locationName = humanReadableAddress;

    userPickUpLocation = blindUserPickUpAddress;


    return humanReadableAddress;
  }

  // static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng start, LatLng end) async
  // {
  //   String urlOriginToDestinationDirectionDetails = 'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';
  //
  //   var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);
  //
  //   if(responseDirectionApi == "Error Occurred, Failed. No Response.")
  //   {
  //     return null;
  //   }
  //
  //   DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
  //   directionDetailsInfo.e_points = responseDirectionApi['routes'][0]['geometry']['coordinates'];
  //
  //   directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
  //   directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
  //
  //   directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
  //   directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
  //
  //   return directionDetailsInfo;
  // }

  static pauseLiveLocationUpdates()
  {
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static resumeLiveLocationUpdates()
  {
    streamSubscriptionPosition!.resume();
    Geofire.setLocation(
        currentFirebaseUser!.uid,
        assistantCurrentPosition!.latitude ?? 0,
        assistantCurrentPosition!.longitude ?? 0
    );
  }
}