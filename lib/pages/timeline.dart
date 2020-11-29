import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_network/widgets/header.dart';
import 'package:social_network/widgets/progress.dart';

final CollectionReference usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress(context);
            }
            return Container(
              child: ListView(
                children: snapshot.data.documents
                    .map((e) => ListTile(
                          title: Text(e['username']),
                        ))
                    .toList(),
              ),
            );
          },
          stream: usersRef.snapshots()),
    );
  }
}
