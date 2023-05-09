import 'dart:convert';
import 'package:arti_eyes/services/blind_user_models/request_assistant.dart';
import 'package:arti_eyes/services/blind_user_models/blind_user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../global/global.dart';
import '../assistant_user_models/direction_details_info.dart';
import '../assistant_user_models/directions.dart';

class BlindUserAssistantMethods {
  static Future<String> searchAddressForGeographicCoOrdinates(
      LocationData position, context) async
  {
    var dclient = http.Client();
    String apiUrl = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position
        .latitude}&lon=${position.longitude}&zoom=18&addressdetails=1';

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


  static void readCurrentOnlineBlindUserInfo() async
  {
    currentFirebaseUser = fAuth.currentUser;

    DatabaseReference blindUserRef = FirebaseDatabase.instance.ref().child("blindUsers").child(currentFirebaseUser!.uid);

    blindUserRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        blindUserModelCurrentInfo = BlindUserModel.fromSnapShot(snap.snapshot);
        print('BLIND USER DETAILS CALLED SUCCESSFULLY');
      }
      else{
        print('BLIND USER DETAILS CALL FAILED');
      }
    });
  }


  static Future<
      DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(
      LatLng start, LatLng end) async
  {
    String urlOriginToDestinationDirectionDetails = 'http://router.project-osrm.org/route/v1/driving/${start
        .longitude},${start.latitude};${end.longitude},${end
        .latitude}?geometries=geojson';

    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    if (responseDirectionApi == "Error Occurred, Failed. No Response.") {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
    responseDirectionApi['routes'][0]['geometry']['coordinates'];

    directionDetailsInfo.distance_text =
    responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
    responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
    responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
    responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }


  static sendNotificationToAssistantNow(String deviceRegistrationToken, String blindUserAssistanceRequestId, context) async
  {
    String currentAddress = blindUserCurrentAddress;

    Map<String, String> headerNotification =
    {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification =
    {
      "body": "Current Address: \n$currentAddress",
      "title": "New Assistant Request Alert!!!"
    };

    Map dataMap =
    {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "assistanceRequestId": blindUserAssistanceRequestId
    };

    Map officialNotificationFormat =
    {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };

    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }


  //retrieve the trips KEYS for online user
  //trip key = assistance request key
  static void readTripsKeysForOnlineBlindUser(context) {
    FirebaseDatabase.instance.ref().child("All Assistance Requests")
        .orderByChild("blindUserName").equalTo(blindUserModelCurrentInfo!.name)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        countTotalTrips = overAllTripsCounter;

        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        historyTripsKeysList = tripsKeysList;
      }
    });
  }
}