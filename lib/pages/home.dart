import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  Widget buildAuthScreen() {
    return Text('user is auth');
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal, Colors.purple],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Bibliolater',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Signatra",
                  fontSize: 100,
                ),
              ),
              GestureDetector(
                onTap: () {
                  print('tapped');
                },
                child: Container(
                  width: 260.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image:
                          AssetImage('assets/images/google_signin_button.png'),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
