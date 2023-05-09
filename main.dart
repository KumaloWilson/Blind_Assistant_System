import 'package:arti_eyes/authentication/userType.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splashScreen/splash_screen.dart';

bool showSelectUserTypeAndOnBoardingScreenPrefs = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  showSelectUserTypeAndOnBoardingScreenPrefs =
      prefs.getBool("ON_BOARDING") ?? true;

  runApp(
    MyApp(
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: showSelectUserTypeAndOnBoardingScreenPrefs
            ? const selectUserType()
            : const MySplashScreen(),
        debugShowCheckedModeBanner: true,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget? child;

  const MyApp({super.key, this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
