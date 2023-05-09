import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SOSTabPage extends StatefulWidget {
  const SOSTabPage({Key? key}) : super(key: key);

  @override
  _SOSTabPageState createState() => _SOSTabPageState();

  static GlobalKey<_SOSTabPageState> createKey() => GlobalKey<_SOSTabPageState>();
}



class _SOSTabPageState extends State<SOSTabPage> {

  late final FlutterTts _flutterTts = FlutterTts();

  TextEditingController phone1Controller = TextEditingController();
  TextEditingController phone2Controller = TextEditingController();
  TextEditingController phone3Controller = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController userMsgController = TextEditingController();

  late String phone1;
  late String phone2;
  late String phone3;
  late String username;
  late String usermsg;

  sosInfoValidator() async{
    String errorMsg;
    if (phone1Controller.text.isEmpty && phone3Controller.text.isEmpty && phone2Controller.text.isEmpty ) {
      errorMsg = "Please enter at least one emergency contact.";
      Fluttertoast.showToast(msg: errorMsg);
      await _flutterTts.speak(errorMsg);
    } else if (userNameController.text.length < 3) {
      errorMsg = "Username is too short.";
      Fluttertoast.showToast(msg: errorMsg);
      await _flutterTts.speak(errorMsg);
    } else if (userMsgController.text.length < 3) {
      errorMsg = "Message is too short.";
      Fluttertoast.showToast(msg: errorMsg);
      await _flutterTts.speak(errorMsg);
    } else if (userNameController.text.isEmpty) {
      errorMsg = "Please enter your username.";
      Fluttertoast.showToast(msg: errorMsg);
      await _flutterTts.speak(errorMsg);
    } else {
      errorMsg = "S.O.S contacts saved successfully";
      convertSignature();
      await _flutterTts.speak(errorMsg);
    }
  }


  void convertSignature(){
    String phone1 = phone1Controller.text;
    String phone2 = phone2Controller.text;
    String phone3 = phone3Controller.text;
    String username = userNameController.text;
    String usermsg = userMsgController.text;

    setSignature(phone1, phone2, phone3, username, usermsg);
  }

  void setSignature(String phone1, String phone2, String phone3, String username, String usermsg) async{
    SharedPreferences signPrefs = await SharedPreferences.getInstance();
    signPrefs.setString('phone1', phone1);
    signPrefs.setString('phone2', phone2);
    signPrefs.setString('phone3', phone3);
    signPrefs.setString('username', username);
    signPrefs.setString('usermsg', usermsg);
  }

  Future<String?> getPhone1() async {
    SharedPreferences signPrefs = await SharedPreferences.getInstance();
    phone1 = signPrefs.getString('phone1')!;

    return phone1;
  }

  Future<String> getPhone2() async {
    SharedPreferences signPrefs = await SharedPreferences.getInstance();
    phone2 = signPrefs.getString('phone2')!;

    return phone2;
  }

  Future<String> getPhone3() async {
    SharedPreferences signPrefs = await SharedPreferences.getInstance();
    phone3 = signPrefs.getString('phone3')!;

    return phone3;
  }

  Future<String> getUsername() async {
    SharedPreferences signPrefs = await SharedPreferences.getInstance();
    username = signPrefs.getString('username')!;

    return username;
  }
  Future<String> getUsermsg() async {
    SharedPreferences signPrefs = await SharedPreferences.getInstance();
    usermsg = signPrefs.getString('usermsg')!;

    return usermsg;
  }



  @override
  void initState() {
    super.initState();
    getPhone1();
    getPhone2();
    getPhone3();
    getUsername();
    getUsermsg();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      phone1Controller.text = (await getPhone1())!;
      phone2Controller.text = (await getPhone2());
      phone3Controller.text = (await getPhone3());
      userNameController.text = (await getUsername());
      userMsgController.text =(await getUsermsg());
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Emergency Contacts",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  child: Lottie.asset("images/4096-heal.json",
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.25
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const SizedBox(
                  height: 5,
                ),
                IntlPhoneField(
                  dropdownTextStyle: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  controller: phone1Controller,
                  cursorColor: const Color.fromARGB(255, 3, 152, 158),
                  style:
                  const TextStyle(color: Color.fromARGB(255, 3, 152, 158)),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number 1',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 3, 152, 158)),
                    ),
                  ),
                  initialCountryCode: 'ZW',
                  onChanged: (phone) {
                    print(phone.completeNumber);
                  },
                ),

                const SizedBox(
                  height: 5,
                ),
                IntlPhoneField(
                  dropdownTextStyle: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  controller: phone2Controller,
                  cursorColor: const Color.fromARGB(255, 3, 152, 158),
                  style:
                  const TextStyle(color: Color.fromARGB(255, 3, 152, 158)),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number 2',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 3, 152, 158)),
                    ),
                  ),
                  initialCountryCode: 'ZW',
                  onChanged: (phone) {
                    print(phone.completeNumber);
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                IntlPhoneField(
                  dropdownTextStyle: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  controller: phone3Controller,
                  cursorColor: const Color.fromARGB(255, 3, 152, 158),
                  style:
                  const TextStyle(color: Color.fromARGB(255, 3, 152, 158)),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number 3',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 3, 152, 158)),
                    ),
                  ),
                  initialCountryCode: 'ZW',
                  onChanged: (phone) {
                    print(phone.completeNumber);
                  },
                ),

                const SizedBox(
                  height: 5,
                ),
                TextField(
                  controller: userNameController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  decoration: const InputDecoration(
                    labelText: "Username",
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
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: userMsgController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  decoration: const InputDecoration(
                    labelText: "Message",
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

                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    sosInfoValidator();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 152, 158),
                    shape: const StadiumBorder(),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 195, 250, 244), width: 2),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    "Save Information",
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
    );

  }
}
