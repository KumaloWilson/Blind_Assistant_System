import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../splashScreen/splash_screen.dart';

class AvailabilityInfoScreen extends StatefulWidget {
  const AvailabilityInfoScreen({super.key});


  @override
  State<AvailabilityInfoScreen> createState() => _AvailabilityInfoScreenState();
}

class _AvailabilityInfoScreenState extends State<AvailabilityInfoScreen> {
  TextEditingController cityTextEditingController = TextEditingController();
  TextEditingController provinceTextEditingController = TextEditingController();
  TextEditingController nationalityTextEditingController = TextEditingController();
  TextEditingController nationalIDNumberTextEditingController = TextEditingController();
  TextEditingController residentialAddressTextEditingController = TextEditingController();

  List<String> avatarTypeList = ["mike", "vanessa", "sofia", "mitchel", "scott", "mavis"];
  String? selectedAvatarType;

  saveAdditionalInfo()
  {
    Map assistantMoreInfoMap =
    {
      "national_id_number": nationalIDNumberTextEditingController.text.trim(),
      "residential_address": residentialAddressTextEditingController.text.trim(),
      "city_province": "${cityTextEditingController.text.trim()} " "${provinceTextEditingController.text.trim()}"  " ${nationalityTextEditingController.text.trim()}",
      "avatar_type": selectedAvatarType,
    };

    DatabaseReference assistantsRef = FirebaseDatabase.instance.ref().child("assistantUsers");
    assistantsRef.child(currentFirebaseUser!.uid).child("availability_details").set(assistantMoreInfoMap);

    Fluttertoast.showToast(msg: "Congratulations you're now an Assistant");
    Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
  }

  Widget build(BuildContext context)
  {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/wallpaper1.jpg"), fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                CircleAvatar(
                  backgroundImage: const AssetImage('images/logo1.png'),
                  radius: MediaQuery.of(context).size.height * 0.1,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                const Text(
                  "Availability Information",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 3, 152, 158),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextField(
                  controller: nationalIDNumberTextEditingController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  decoration: const InputDecoration(
                    labelText: "ID Number",
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
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),

                TextField(
                  controller: residentialAddressTextEditingController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  decoration: const InputDecoration(
                    labelText: "Residential Address",
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
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),

                TextField(
                  controller: cityTextEditingController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  decoration: const InputDecoration(
                    labelText: "City",
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
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),

                TextField(
                  controller: provinceTextEditingController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  decoration: const InputDecoration(
                    labelText: "Province",
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
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                TextField(
                  controller: nationalityTextEditingController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  decoration: const InputDecoration(
                    labelText: "Nationality",
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
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                DecoratedBox(
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [
                              Colors.redAccent,
                              Colors.blueAccent,
                              Colors.purpleAccent
                              //add more colors
                            ]),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                              color: Color.fromARGB(255, 3, 152, 158), //shadow for button
                              blurRadius: 5) //blur radius of shadow
                        ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left:10, right:30),
                      child:DropdownButton<String>(
                        dropdownColor: const Color.fromARGB(255, 3, 152, 158),
                        hint: const Text(
                          "Please your avatar",
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black
                          ),
                        ),
                        value: selectedAvatarType,
                        onChanged: (newValue)
                        {
                          setState((){
                            selectedAvatarType = newValue.toString();
                          });
                        },
                        items: avatarTypeList.map((avatar){
                          return DropdownMenuItem(
                            child: Row(
                              children: [
                                Image.asset("images/${avatar}.png"),
                                Text(
                                  avatar,
                                  style: const TextStyle(
                                      color: Colors.white
                                  ),
                                ),
                              ],
                            ),
                            value: avatar,
                          );
                        }).toList(),
                        isExpanded: true, //make true to take width of parent widget
                        underline: Container(), //empty line
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                        iconEnabledColor: Colors.white,
                      ),
                    )
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
                ),

                ElevatedButton(
                  onPressed: ()
                  {
                    if(nationalIDNumberTextEditingController.text.isNotEmpty && residentialAddressTextEditingController.text.isNotEmpty && cityTextEditingController.text.isNotEmpty && selectedAvatarType != null)
                    {
                      saveAdditionalInfo();
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 152, 158),
                    shape: const StadiumBorder(),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 195, 250, 244),
                        width: 2
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    "Save Information",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
