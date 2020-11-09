import 'package:SocialNetwork/pages/auth/auth_page.dart';
import 'package:SocialNetwork/pages/home_page.dart';
import 'package:SocialNetwork/pages/splash_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Network',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal[900],
        accentColor: Colors.blueGrey[900],
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashPage();
          }
          if (snapshot.hasData) {
            return HomePage();
          }
          return AuthPage();
        },
      ),
    );
  }
}
