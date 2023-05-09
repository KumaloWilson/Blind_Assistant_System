import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../services/blind_user_models/assistance_methods.dart';


class SelectNearestActiveAssistantScreen extends StatefulWidget
{
  DatabaseReference? referenceAssistanceRequest;

  SelectNearestActiveAssistantScreen({this.referenceAssistanceRequest});

  @override
  State<SelectNearestActiveAssistantScreen> createState() => _SelectNearestActiveAssistantScreenState();
}



class _SelectNearestActiveAssistantScreenState extends State<SelectNearestActiveAssistantScreen>
{

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  "images/wallpaper1.jpg"
              ),
              fit: BoxFit.fill
          )
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text(
            "Online Assistants",
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 3, 152, 158),
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: Color.fromARGB(255, 3, 152, 158),
            ),
            onPressed: () {
              //delete ride request from database
              widget.referenceAssistanceRequest!.remove();
              Fluttertoast.showToast(
                  msg: "You have cancelled your Assistance request");

              SystemNavigator.pop();
            },
          ),
        ),
        body: ListView.builder(
          itemCount: assistantUserList.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  chosenAssistantId = assistantUserList[index]["id"].toString();
                });

                Navigator.pop(context, "assistantChoosed");
              },
              child: Card(
                color: const Color.fromARGB(255, 3, 152, 158),
                elevation: 3,
                shadowColor: Colors.white,
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Image.asset(
                      "images/${assistantUserList[index]["availability_details"]["avatar_type"]}.png",
                      width: 70,
                    ),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        assistantUserList[index]["name"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        assistantUserList[index]["availability_details"]["national_id_number"],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 2.0,),
                      Text(
                        tripDirectionDetailsInfo != null
                            ? tripDirectionDetailsInfo!.duration_text!
                            : "DurationText",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2.0,),
                      Text(
                        tripDirectionDetailsInfo != null
                            ? tripDirectionDetailsInfo!.distance_text!
                            : "DistanceText",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    }
  }
