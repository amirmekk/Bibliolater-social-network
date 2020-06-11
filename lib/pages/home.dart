import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    //detects when user is signed in
    googleSignIn.onCurrentUserChanged.listen(
      (account) {
        handleSignIn(account);
      },
      onError: (err) =>
          print('an error ocured when signing using google : $err'),
    );
    //Re-Auth the user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('an error ocured when signing using google : $err');
    });
  }

  void handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      print('my user account is  : $account');
      setState(() {
        isAuth = true;
      });
    } else {
      print('no user');
      setState(() {
        isAuth = false;
      });
    }
  }

  bool isAuth = false;
  logIn() {
    googleSignIn.signIn();
  }

  logOut() {
    googleSignIn.signOut();
  }

  Widget buildAuthScreen() {
    return RaisedButton(onPressed: logOut , child: Text('log out '),);
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
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
                onTap: logIn,
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
