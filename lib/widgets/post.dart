import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_network/models/user.dart';
import 'package:social_network/pages/timeline.dart';
import 'package:social_network/widgets/custom_image.dart';
import 'package:social_network/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId, ownerId, username, location, description, mediaUrl;
  final dynamic likes;
  Post(
      {this.postId,
      this.description,
      this.likes,
      this.location,
      this.mediaUrl,
      this.ownerId,
      this.username});
  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      description: doc['description'],
      postId: doc['postId'],
      likes: doc['likes'],
      location: doc['location'],
      mediaUrl: doc['mediaUrl'],
      ownerId: doc['ownerId'],
      username: doc['username'],
    );
  }
  int getLikesCount(likes) {
    // if there is no likes return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    //if the key is set to true add +1 to like count
    likes.values.forEach((val) {
      if (val == true) {
        count++;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        description: this.description,
        likes: this.likes,
        location: this.location,
        mediaUrl: this.mediaUrl,
        ownerId: this.ownerId,
        username: this.username,
        likeCount: getLikesCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId, ownerId, username, location, description, mediaUrl;
  int likeCount;
  Map likes;
  _PostState(
      {this.postId,
      this.description,
      this.likes,
      this.location,
      this.mediaUrl,
      this.ownerId,
      this.likeCount,
      this.username});
  FutureBuilder buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () {},
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => print('delete post '),
          ),
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () {
        print('switch like status');
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl), 
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40, left: 20)),
            GestureDetector(
              onTap: () => print('liking again'),
              child: Icon(
                Icons.favorite_border,
                size: 28,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20)),
            GestureDetector(
              onTap: () => print('commenting '),
              child: Icon(
                Icons.chat,
                size: 28,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$likeCount likes',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$username',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(description),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
