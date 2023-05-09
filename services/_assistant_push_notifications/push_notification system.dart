import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import '../../global/global.dart';
import '../assistant_user_models/user_assistance_request_information.dart';
import 'notification_dialog_box.dart';

class PushNotificationSystem
{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async
  {
    //1. Terminated
    //When the app is completely closed and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage)
    {
      if(remoteMessage != null)
      {
        //display ride request information - user information who request a ride
        readBlindUserAssistanceRequestInformation(remoteMessage.data["assistanceRequestId"], context);
      }
    });

    //2. Foreground
    //When the app is open and it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage)
    {
      //display ride request information - user information who request a ride
      readBlindUserAssistanceRequestInformation(remoteMessage!.data["assistanceRequestId"], context);
    });


    //3. Background
    //When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage)
    {
      //display ride request information - user information who request assistance
      readBlindUserAssistanceRequestInformation(remoteMessage!.data["assistanceRequestId"], context);
    });
  }

  readBlindUserAssistanceRequestInformation(String userAssistanceRequestId, BuildContext context)
  {
    FirebaseDatabase.instance.ref()
        .child("All Assistance Requests")
        .child(userAssistanceRequestId)
        .once()
        .then((snapData)
    {
      if(snapData.snapshot.value != null)
      {
        audioPlayer.open(Audio("audios/Pikachu - Cute - Tone.mp3"));
        audioPlayer.play();

        double originLat = double.parse((snapData.snapshot.value! as Map)["origin"]["latitude"]);
        double originLng = double.parse((snapData.snapshot.value! as Map)["origin"]["longitude"]);
        String originAddress = (snapData.snapshot.value! as Map)["originAddress"];

        double destinationLat = double.parse((snapData.snapshot.value! as Map)["destination"]["latitude"]);
        double destinationLng = double.parse((snapData.snapshot.value! as Map)["destination"]["longitude"]);
        String destinationAddress = (snapData.snapshot.value! as Map)["destinationAddress"];

        String userName = (snapData.snapshot.value! as Map)["userName"];
        String userPhone = (snapData.snapshot.value! as Map)["userPhone"];

        String? assistanceRequestId = snapData.snapshot.key;

        BlindUserAssistanceRequestInformation userAssistanceRequestDetails = BlindUserAssistanceRequestInformation();

        userAssistanceRequestDetails.originLatLng = LatLng(originLat, originLng);
        userAssistanceRequestDetails.originAddress = originAddress;

        userAssistanceRequestDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
        userAssistanceRequestDetails.destinationAddress = destinationAddress;

        userAssistanceRequestDetails.userName = userName;
        userAssistanceRequestDetails.userPhone = userPhone;

        userAssistanceRequestDetails.assistanceRequestId = assistanceRequestId;

        showDialog(
          context: context,
          builder: (BuildContext context) => NotificationDialogBox(
            blindUserAssistanceRequestDetails: userAssistanceRequestDetails,
          ),
        );
      }
      else
      {
        Fluttertoast.showToast(msg: "This Assistance Request Id do not exists.");
      }
    });
  }

  Future generatingAndGetToken() async
  {
    String? registrationToken = await messaging.getToken();
    print("FCM Registration Token: ");
    print(registrationToken);

    FirebaseDatabase.instance.ref()
        .child("assistantUsers")
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allAssistantUsers");
    messaging.subscribeToTopic("allBlindUsers");
  }
}