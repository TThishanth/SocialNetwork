import 'dart:io';
import 'package:SocialNetwork/Services/auth_services.dart';
import 'package:SocialNetwork/pages/homePages/profile.dart';
import 'package:SocialNetwork/pages/homePages/activity_feed.dart';
import 'package:SocialNetwork/pages/homePages/search.dart';
import 'package:SocialNetwork/pages/homePages/timeline.dart';
import 'package:SocialNetwork/pages/homePages/upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');
Authentication authentication = Authentication();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final commentsRef = FirebaseFirestore.instance.collection('comments');
final activityFeedRef = FirebaseFirestore.instance.collection('feed');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final timestamp = DateTime.now();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  PageController pageController = new PageController();
  String userId = FirebaseAuth.instance.currentUser.uid;
  User currentUser = FirebaseAuth.instance.currentUser;
  int currentIndex = 0;

  void onTap(int page) {
    setState(() {
      currentIndex = page;
    });
    pageController.jumpToPage(page);
    configurePushNotifications();
  }

  configurePushNotifications() {
    if (Platform.isIOS) getIosPermission();

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      usersRef.doc(currentUser.uid).update({"androidNotificationToken": token});
    });

    _firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {},
      onMessage: (Map<String, dynamic> message) async {
        print("on message: $message\n");
        final String recipientId = message['data']['recipient'];
        final String body = message['notification']['body'];

        if (recipientId != currentUser.uid) {
          print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: Text(
            body,
            overflow: TextOverflow.ellipsis,
          ));
          _scaffoldKey.currentState.showSnackBar(snackbar);
        }
        print("Notification not shown");
      },
    );
  }

  getIosPermission() {
    _firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(
        alert: true,
        badge: true,
        sound: true,
      ),
    );
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print("Setting registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        controller: pageController,
        children: [
          Timeline(currentUser: currentUser),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: userId),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTap,
        backgroundColor: Colors.grey.shade900,
        selectedIconTheme: IconThemeData(
          color: Colors.white,
        ),
        unselectedIconTheme: IconThemeData(
          color: Colors.white54,
        ),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 26.0,
        selectedFontSize: 14.0,
        unselectedFontSize: 12.0,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.airbnb,
              size: 25,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.bell,
              size: 25.0,
            ),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.camera,
              size: 40.0,
            ),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.search,
              size: 25,
            ),
            label: 'search',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.user,
              size: 25,
            ),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
