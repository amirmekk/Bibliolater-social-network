import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_network/pages/activity_feed.dart';
import 'package:social_network/pages/profile.dart';
import 'package:social_network/pages/search.dart';
import 'package:social_network/pages/timeline.dart';
import 'package:social_network/pages/upload.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController pageController;
  bool isAuth = false;
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
    pageController = PageController();
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

  logIn() {
    googleSignIn.signIn();
  }

  logOut() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.jumpToPage(pageIndex);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera, size: 35.0),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            title: Text(''),
          ),
        ],
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: pageIndex,
        onTap: (index) {
          onTap(index);
        },
      ),
    );
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

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
