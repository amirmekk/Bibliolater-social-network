import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Text("Post");
  }
}
