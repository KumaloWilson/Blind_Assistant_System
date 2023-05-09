import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assistant_side/assistant_home_screen.dart';
import '../global/global.dart';
import '../mainScreens/main_screen.dart';
import '../splashScreen/splash_screen.dart';
import '../widgets/progress_dialog.dart';
import 'availability_info_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {


  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  List<String> ageRangeList = ["10-15", "16-20", "21-30", "31+"];
  String? ageRange;

  updateSignUpTextUserMode() async{

    if(userType == UserType.assistant){
      setState(() {
        asUser = 'Assistant';
      });
    }

    if(userType == UserType.blindPerson){
      setState(() {
        asUser = 'Visually Impaired';
      });
    }
  }

  validateForm() {
    if (nameTextEditingController.text.length < 3) {
      Fluttertoast.showToast(msg: "name must be at least 3 Characters.");
    } else if (!emailTextEditingController.text.contains("@")) {
      Fluttertoast.showToast(msg: "Email address is not Valid.");
    } else if (phoneTextEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Phone Number is required.");
    } else if (passwordTextEditingController.text.length < 6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 Characters.");
    } else {
      saveDriverInfoNow();
    }
  }

  saveDriverInfoNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(
            message: "Please wait...",
          );
        });

    final User? firebaseUser = (await fAuth.createUserWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
            .catchError((msg) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "ERROR: $msg");
    }))
        .user;

    if (firebaseUser != null) {

      if(userType == UserType.blindPerson){
        Map userMap =
        {
          "id": firebaseUser.uid,
          "name": nameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "phone": phoneTextEditingController.text.trim(),
          "age" : ageRange,
        };
        DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("blindUsers");
        usersRef.child(firebaseUser.uid).set(userMap);

        currentFirebaseUser = firebaseUser;
        Fluttertoast.showToast(msg: "Account has been created successfully");
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MySplashScreen()));
      }

      if(userType == UserType.assistant){
        Map assistantMap =
        {
          "id": firebaseUser.uid,
          "name": nameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "phone": phoneTextEditingController.text.trim(),
          "age" : ageRange,
        };
        DatabaseReference assistantRef = FirebaseDatabase.instance.ref().child("assistantUsers");
        assistantRef.child(firebaseUser.uid).set(assistantMap);

        currentFirebaseUser = firebaseUser;
        Fluttertoast.showToast(msg: "Account has been created successfully");
        Navigator.push(context, MaterialPageRoute(builder: (c)=> AvailabilityInfoScreen()));
      }

    } else {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been Created.");
    }
  }

  @override
  void initState() {
    super.initState();
    updateSignUpTextUserMode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage("images/wallpaper1.jpg"), fit: BoxFit.cover),
      ),
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
                  backgroundImage: AssetImage('images/logo1.png'),
                  radius: MediaQuery.of(context).size.height * 0.1,
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                ),
                Text(
                  "Register as $asUser",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 3, 152, 158),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                TextField(
                  controller: nameTextEditingController,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 3, 152, 158)),
                  decoration: const InputDecoration(
                    hintText: "Name",
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 3, 152, 158)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 3, 152, 158)),
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
                  controller: emailTextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 3, 152, 158)),
                  decoration: const InputDecoration(
                    hintText: "Email",
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 3, 152, 158)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 3, 152, 158)),
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
                              color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                              blurRadius: 5) //blur radius of shadow
                        ]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left:10, right:30),
                      child:DropdownButton(
                        dropdownColor: Colors.grey,
                        hint: const Text(
                          "Choose age range",
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black
                          ),
                        ),
                        value: ageRange,
                        onChanged: (newValue)
                        {
                          setState((){
                            ageRange = newValue.toString();
                          });
                        },
                        items: ageRangeList.map((age){
                          return DropdownMenuItem(
                            value: age,
                            child: Text(
                              age,
                              style: const TextStyle(
                                  color: Colors.black
                              ),
                            ),
                          );
                        }).toList(),
                        isExpanded: true, //make true to take width of parent widget
                        underline: Container(), //empty line
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        iconEnabledColor: Colors.white,
                      ),
                    )
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),

                TextField(
                  controller: phoneTextEditingController,
                  keyboardType: TextInputType.phone,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 3, 152, 158)),
                  decoration: const InputDecoration(
                    hintText: "Phone",
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 3, 152, 158)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 3, 152, 158)),
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
                  controller: passwordTextEditingController,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 3, 152, 158)),
                  decoration: const InputDecoration(
                    hintText: "Password",
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 3, 152, 158)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 3, 152, 158)),
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
                  height: MediaQuery.of(context).size.height * 0.04,
                ),

                ElevatedButton(
                  onPressed: () {
                    validateForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 152, 158),
                    shape: const StadiumBorder(),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 195, 250, 244), width: 2),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextButton(
                  child: const Text(
                    "Already have an Account? Login Here",
                    style: TextStyle(color: Color.fromARGB(255, 3, 152, 158)),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => LoginScreen()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
