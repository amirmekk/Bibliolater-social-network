import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_network/pages/home.dart';
import 'package:social_network/widgets/header.dart';
import 'package:social_network/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId, postOwnerId, postMediaUrl;
  Comments({this.postId, this.postMediaUrl, this.postOwnerId});
  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postMediaUrl: this.postMediaUrl,
        postOwnerId: this.postOwnerId,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId, postOwnerId, postMediaUrl;
  CommentsState({this.postId, this.postMediaUrl, this.postOwnerId});

  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .document(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          circularProgress(context);
        }
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  addComment() {
    commentsRef.document(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentController.text,
      'timestamp': timestamp,
      'avatarUrl': currentUser.photoUrl,
      'userId': currentUser.id
    });
    bool isNotPostOwner = currentUser.id != postOwnerId;
    if (isNotPostOwner) {
      activityFeedRef.document(postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'username': currentUser.username,
        'commentData': commentController.text,
        'userId': currentUser.id,
        'userProfileImg': currentUser.photoUrl,
        'postId': postId,
        'mediaUrl': postMediaUrl,
        'timestamp': timestamp,
      });
    }

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Write a comment...',
              ),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username, userId, comment, avatarUrl;
  final Timestamp timestamp;
  Comment(
      {this.avatarUrl,
      this.comment,
      this.timestamp,
      this.userId,
      this.username});
  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      userId: doc['userId'],
      timestamp: doc['timestamp'],
      username: doc['username'],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          //subtitle: Text(timeago.format(timestamp.toDate())),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
        Divider(),
      ],
    );
  }
}
