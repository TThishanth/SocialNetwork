import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final timestamp = DateTime.now();
  BuildContext context;

  Future<String> googleSignIn() async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential authCredential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(authCredential);

    final User user = userCredential.user;

    if (user != null) {
      assert(user.displayName != null);
      assert(user.email != null);

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _firebaseAuth.currentUser;

      assert(currentUser.uid == user.uid);

      print('SignInWithGoogle succeeded: $user');

      List<String> splitList = currentUser.displayName.split(' ');
      List<String> indexList = [];

      for (int i = 0; i < splitList.length; i++) {
        for (int j = 0; j < splitList[i].length + i; j++) {
          indexList.add(splitList[i].substring(0, j).toLowerCase());
        }
      }

      FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
        "userId": currentUser.uid,
        "name": currentUser.displayName,
        "email": currentUser.email,
        "profilePhoto": currentUser.photoURL,
        "bio": '',
        "searchIndex": indexList,
        "timestamp": timestamp,
      });

      return '$user';
    }

    return null;
  }

  // Send Reset Password Email
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Logout
  Future<void> googleSignOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
