import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import '../widgets/progress_dialog.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  updateLoginTextUserMode() async{

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
    if (!emailTextEditingController.text.contains("@")) {
      Fluttertoast.showToast(msg: "Email address is not Valid.");
    } else if (passwordTextEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Password is required.");
    } else {
      loginDriverNow();
    }
  }

  loginDriverNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(
            message: "Please wait...",
          );
        });

    final User? firebaseUser = (await fAuth.signInWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),

    ).catchError((msg) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: $msg");

    })).user;

    if (firebaseUser != null) {
      currentFirebaseUser = firebaseUser;
      Fluttertoast.showToast(msg: "Login Successful.");
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error Occurred during Login.");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    updateLoginTextUserMode();
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
            padding: const EdgeInsets.all(20.0),
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
                Text(
                  "Login as $asUser",
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
                  controller: emailTextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  decoration: const InputDecoration(
                    hintText: "Email",
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
                  controller: passwordTextEditingController,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 3, 152, 158),
                  ),
                  decoration: const InputDecoration(
                    labelText: "Password",
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
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextButton(
                  child: const Text(
                    "Do not have an Account? SignUp Here",
                    style: TextStyle(
                      color: Color.fromARGB(255, 3, 152, 158),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => SignUpScreen()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 3, 152, 158),
                              shape: const CircleBorder(), //<-- SEE HERE
                              padding: const EdgeInsets.all(5),
                            ),
                            child: const Icon(
                              Icons.facebook,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 3, 152, 158),
                              shape: const CircleBorder(), //<-- SEE HERE
                              padding: const EdgeInsets.all(10),
                            ),
                            child: const Icon(
                              Icons.face_unlock_sharp,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 3, 152, 158),
                              shape: const CircleBorder(), //<-- SEE HERE
                              padding: const EdgeInsets.all(10),
                            ),
                            child: const Icon(
                              Icons.fingerprint,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
