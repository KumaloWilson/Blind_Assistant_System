import 'package:arti_eyes/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import '../global/global.dart';



class BlindUserDrawer extends StatefulWidget
{
  String? name;
  String? email;

  BlindUserDrawer({this.name, this.email});

  @override
  _BlindUserDrawerState createState() => _BlindUserDrawerState();
}

class _BlindUserDrawerState extends State<BlindUserDrawer>
{
  @override
  Widget build(BuildContext context)
  {
    return Drawer(
      backgroundColor: Colors.white54,
      child: ListView(
        children: [
          //drawer header
          Container(
            height:  MediaQuery.of(context).size.height * 0.30,
            color: Colors.white,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                  color:Color.fromARGB(255, 3, 152, 158)
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person,
                    size: MediaQuery.of(context).size.height * 0.15,
                    color: Colors.white,
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.height * 0.03,
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.email.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.005,
          ),

          //History Button
          ElevatedButton(
            onPressed: ()
            {

            },

            style: ElevatedButton.styleFrom(
              primary: Colors.white,
            ),

            child: const Text(
              "History",
              style: TextStyle(
                color: Color.fromARGB(255, 3, 152, 158),
                fontSize: 18,
              ),
            ),
          ),

          //Visit profile Button
          ElevatedButton(
            onPressed: ()
            {

            },

            style: ElevatedButton.styleFrom(
              primary: Colors.white,
            ),

            child: const Text(
              "Visit profile",
              style: TextStyle(
                color:Color.fromARGB(255, 3, 152, 158),
                fontSize: 18,
              ),
            ),
          ),

          //About Button
          ElevatedButton(
            onPressed: ()
            {

            },

            style: ElevatedButton.styleFrom(
              primary: Colors.white,
            ),

            child: const Text(
              "About",
              style: TextStyle(
                color:Color.fromARGB(255, 3, 152, 158),
                fontSize: 18,
              ),
            ),
          ),

          //SignOut Button
          ElevatedButton(
            onPressed: ()
            {
              fAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
            },

            style: ElevatedButton.styleFrom(
              primary: Colors.redAccent,
            ),

            child: const Text(
              "SignOut",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
