import 'package:SocialNetwork/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SocialNetwork/pages/home_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  _CommentsState createState() => _CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaUrl: this.postMediaUrl,
      );
}

class _CommentsState extends State<Comments> {
  final currentUser = FirebaseAuth.instance.currentUser;
  TextEditingController _commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  _CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data.docs.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  addComment() {
    commentsRef.doc(postId).collection('comments').add({
      'username': currentUser.displayName,
      'comment': _commentController.text,
      'timestamp': timestamp,
      'avatarUrl': currentUser.photoURL,
      'userId': currentUser.uid,
    });
    bool isNotPostOwner = postOwnerId != currentUser.uid;
    if (isNotPostOwner) {
      activityFeedRef.doc(postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'commentData': _commentController.text,
        'username': currentUser.displayName,
        'userId': currentUser.uid,
        'userProfileImg': currentUser.photoURL,
        'postId': postId,
        'mediaUrl': postMediaUrl,
        'timestamp': timestamp,
      });
    }
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: "Write a comment...",
              ),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text(timeago.format(timestamp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
