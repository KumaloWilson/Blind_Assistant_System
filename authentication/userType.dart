import 'package:arti_eyes/global/global.dart';
import 'package:arti_eyes/introduction_screen/_assistant_onboarding_screen.dart';
import 'package:arti_eyes/introduction_screen/_blinduseronboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class selectUserType extends StatefulWidget {
  const selectUserType({super.key});

  @override
  _selectUserTypeState createState() => _selectUserTypeState();
}

class _selectUserTypeState extends State<selectUserType> {


  void setBlindUser() async{
    SharedPreferences signPrefs = await SharedPreferences.getInstance();
    signPrefs.setBool('blindUser', true);
    signPrefs.setBool('assistantUser', false);

    getUserMode();
  }

  void setAssistant() async{
    SharedPreferences signPrefs = await SharedPreferences.getInstance();
    signPrefs.setBool('assistantUser', true);
    signPrefs.setBool('blindUser', false);

    getUserMode();
  }

  void getUserMode() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    assistantMode = (prefs.getBool('assistantUser') ?? false);
    blindMode = (prefs.getBool('blindUser') ?? false);

    if(assistantMode == true){
      userType = UserType.assistant;
      print("THE CURRENT USER TYPE IS $userType");

      proceedToSplashOnBoardingScreensIfUserModeIsSet();
    }

    if(blindMode == true){
      userType = UserType.blindPerson;
      print("THE CURRENT USER TYPE IS $userType");

      proceedToSplashOnBoardingScreensIfUserModeIsSet();
    }

    if(blindMode == false && assistantMode == false){
      userType = null;
      print("THE CURRENT USER TYPE IS $userType");
    }
  }

  void proceedToSplashOnBoardingScreensIfUserModeIsSet() async{
    if(userType == UserType.blindPerson){
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => BlindUserOnBoardingPage()));
      print("Proceeded With Extreme Caution Now In Blind User Mode");
    }

    if(userType == UserType.assistant){
      await Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => AssistantUserBoardingPage()));
      print("Proceeded With Extreme Caution Now In Assistant Mode");
    }
  }



  @override
  Widget build(BuildContext context) {
    getUserMode();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("images/wallpaper1.jpg"), fit: BoxFit.cover),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 3, 152, 158),
          title: const Center(
              child: Text(
               'Arti-Eyes',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ),
        ), //AppBar
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              const Center(
                child: Text(
                  "Join the Arti_eyes Community. See the world Together",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 3, 152, 158),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
              Center(
                child: Image.asset(
                  "images/pngegg.png",
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.10,
              ),
               Center(
                 child: Padding(
                   padding: EdgeInsets.symmetric(
                     horizontal: MediaQuery.of(context).size.width * 0.10,
                   ),
                   child: Row(
                     crossAxisAlignment: CrossAxisAlignment.center,
                      children:  [
                        Column(
                          children: [
                            Text("Blind"),
                            Text("259 000"),
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.30,
                        ),
                        Column(
                          children: [
                            Text("Volunteers"),
                            Text("1 659 000"),
                          ],
                        ),
                      ],
              ),
                 ),
               ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setAssistant();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 152, 158),
                      shape: const StadiumBorder(),
                      side: const BorderSide(
                          color: Color.fromARGB(255, 195, 250, 244), width: 2),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      "Assistant",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setBlindUser();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 152, 158),
                      shape: const StadiumBorder(),
                      side: const BorderSide(
                          color: Color.fromARGB(255, 195, 250, 244), width: 2),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      "Visually Impaired",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
