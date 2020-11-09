import 'package:SocialNetwork/pages/home_page.dart';
import 'package:SocialNetwork/widgets/post/post.dart';
import 'package:SocialNetwork/widgets/progress.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;
  PostScreen({this.userId, this.postId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(post.description),
            ),
            body: ListView(
              children: [
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
