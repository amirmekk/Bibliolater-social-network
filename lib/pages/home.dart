import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_network/models/user.dart';
import 'package:social_network/pages/activity_feed.dart';
import 'package:social_network/pages/create_account.dart';
import 'package:social_network/pages/profile.dart';
import 'package:social_network/pages/search.dart';
//import 'package:social_network/pages/timeline.dart';
import 'package:social_network/pages/upload.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final CollectionReference usersRef = Firestore.instance.collection('users');
final CollectionReference postsRef = Firestore.instance.collection('posts');

final StorageReference storageRef = FirebaseStorage.instance.ref();
final DateTime timestamp = DateTime.now();
User currentUser;

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
      createUserInFirestore();
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

  createUserInFirestore() async {
    //1- check if user exists in database(according to their ID)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();
    if (!doc.exists) {
      //2- if user doesnt exist we want them to create account page
      final String username = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );
      //3- get username from create account, use it to make new user document in users collection
      usersRef.document(user.id).setData({
        'id': user.id,
        'username': username,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'displayName': user.displayName,
        'bio': '',
        'timestamp': timestamp,
      });
      doc = await usersRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.email);

    setState(() {
      // this.currentUser = currentUser;
    });
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
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          //Timeline(),
          RaisedButton(onPressed: logOut, child: Text('log out ')),
          ActivityFeed(),
          Upload(currentUser: currentUser),
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
