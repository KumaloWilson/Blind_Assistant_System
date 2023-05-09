import 'package:arti_eyes/services/assistant_user_models/assistance_methods.dart';
import 'package:arti_eyes/services/assistant_user_models/user_assistance_request_information.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../assistant_side/new_trip_screen.dart';
import '../../global/global.dart';


class NotificationDialogBox extends StatefulWidget
{
  BlindUserAssistanceRequestInformation? blindUserAssistanceRequestDetails;

  NotificationDialogBox({this.blindUserAssistanceRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}




class _NotificationDialogBoxState extends State<NotificationDialogBox>
{
  @override
  Widget build(BuildContext context) 
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [


            SizedBox(
                height: MediaQuery.of(context).size.height * 0.012
            ),

            Image.asset(
              "images/pngegg.png",
              width: MediaQuery.of(context).size.width * 0.2,
            ),

            SizedBox(
                height: MediaQuery.of(context).size.height * 0.01
            ),

            //title
            const Text(
              "New Assistance Request",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color.fromARGB(255, 3, 152, 158),
              ),
            ),

            SizedBox(
                height: MediaQuery.of(context).size.height * 0.01
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color.fromARGB(255, 3, 152, 158),
            ),

            //addresses origin destination
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //origin location with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/origin.png",
                        width: 30,
                        height: 30,
                      ),

                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03
                      ),
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


                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02
                  ),

                  //destination location with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/destination.png",
                        width: 30,
                        height: 30,
                      ),

                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.03
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            widget.blindUserAssistanceRequestDetails!.destinationAddress!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 3, 152, 158),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            const Divider(
              height: 1,
              thickness: 1,
              color: Color.fromARGB(255, 3, 152, 158),
            ),

            //buttons cancel accept
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)
                      ),
                    ),
                    onPressed: ()
                    {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      //cancel the rideRequest
                      FirebaseDatabase.instance.ref()
                          .child("All Assistance Requests")
                          .child(widget.blindUserAssistanceRequestDetails!.assistanceRequestId!)
                          .remove().then((value)
                      {
                        FirebaseDatabase.instance.ref()
                            .child("assistantUsers")
                            .child(currentFirebaseUser!.uid)
                            .child("newAssistanceStatus")
                            .set("idle");
                      }).then((value)
                      {
                        FirebaseDatabase.instance.ref()
                            .child("assistantUsers")
                            .child(currentFirebaseUser!.uid)
                            .child("tripsHistory")
                            .child(widget.blindUserAssistanceRequestDetails!.assistanceRequestId!)
                            .remove();
                      }).then((value)
                      {
                        Fluttertoast.showToast(msg: "Assistance Request has been Cancelled, Successfully. Restart App Now.");
                      });

                      Future.delayed(const Duration(milliseconds: 3000), ()
                      {
                        SystemNavigator.pop();
                      });
                    },
                    child: const Text(
                      "Reject",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                  ),


                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.058
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 3, 152, 158),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)
                      ),
                    ),
                    onPressed: ()
                    {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      //accept the rideRequest
                      acceptAssistanceRequest(context);
                    },
                    child: const Text(
                      "Accept",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  acceptAssistanceRequest(BuildContext context)
  {
    String getAssistanceRequestId = "";
    FirebaseDatabase.instance.ref()
        .child("assistantUsers")
        .child(currentFirebaseUser!.uid)
        .child("newAssistanceStatus")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
        {
          getAssistanceRequestId = snap.snapshot.value.toString();
        }
      else
        {
          Fluttertoast.showToast(msg: "Invalid Assistance Request");
        }

      if(getAssistanceRequestId == widget.blindUserAssistanceRequestDetails!.assistanceRequestId)
        {

          FirebaseDatabase.instance.ref()
              .child("assistantUsers")
              .child(currentFirebaseUser!.uid)
              .child("newAssistanceStatus")
              .set("accepted");

          AssistantUserAssistantMethods.pauseLiveLocationUpdates();

          //send new Ride Screen to TripScreen
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => NewTripScreen(
                blindUserAssistanceRequestDetails: widget.blindUserAssistanceRequestDetails,
              )
            )
          );


          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');

          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');

          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');

          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');

          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');

          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');

          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');

          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');

          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
          print('ASSISTANCE REQUEST HAS BEEN ACCEPTED SUCCESSFULLY');
        }

      else
        {
          Fluttertoast.showToast(msg: "This Assistance request got deleted by the user");
        }

    });
  }

}
