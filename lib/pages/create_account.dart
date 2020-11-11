import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_network/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String username;
  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(content: Text('welcome $username'));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(
        context,
        titleText: 'Set up your profile',
        removeBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Center(
              child: Text(
                'Choose a username',
                style: TextStyle(
                  fontSize: 26,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                onSaved: (value) {
                  setState(() => username = value);
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (val) {
                  if (val.trim().length < 3 || val.isEmpty) {
                    return 'username too short';
                  } else if (val.trim().length > 20) {
                    return 'username too long';
                  } else if (val.contains(' ')) {
                    return 'username can\'t contain whitespace';
                  }

                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                  labelStyle: TextStyle(
                    fontSize: 15,
                  ),
                  hintText: 'Must be at least 3 caracters',
                ),
              ),
            ),
          ),
          ButtonTheme(
            minWidth: MediaQuery.of(context).size.width / 100 * 90,
            height: 50,
            child: RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: submit,
              child: Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
