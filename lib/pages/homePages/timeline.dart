import 'package:SocialNetwork/pages/home_page.dart';
import 'package:SocialNetwork/widgets/post/post.dart';
import 'package:SocialNetwork/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Timeline extends StatefulWidget {
  final User currentUser;
  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;

  @override
  void initState() {
    super.initState();
    getTimeline();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(widget.currentUser.uid)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();

    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();

    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return noPostMsg();
    } else {
      return ListView(
        children: posts,
      );
    }
  }

  noPostMsg() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: SvgPicture.asset(
              'assets/images/no_content.svg',
              height: 200.0,
            ),
          ),
          Container(
            child: Text(
              "No Posts",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Timeline',
          textAlign: TextAlign.center,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
