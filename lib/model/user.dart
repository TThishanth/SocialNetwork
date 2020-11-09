import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  User({
    this.id,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['userId'],
      email: doc['email'],
      photoUrl: doc['profilePhoto'],
      displayName: doc['name'],
      bio: doc['bio'],
    );
  }
}

