import 'package:SocialNetwork/pages/home_page.dart';
import 'package:SocialNetwork/widgets/auth/auth_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _auth = FirebaseAuth.instance;
  final timestamp = DateTime.now();
  var _isLoading = false;

  void _submitAuthForm(
    String username,
    String email,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential userCredential;

    try {
      setState(() {
        _isLoading = true;
      });

      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await userCredential.user.updateProfile(
          displayName: username,
          photoURL:
              'https://ui-avatars.com/api/?name=$username&background=ff5733&color=fff&length=1',
        );

        List<String> splitList = username.split(' ');
        List<String> indexList = [];

        for (int i = 0; i < splitList.length; i++) {
          for (int j = 0; j < splitList[i].length + i; j++) {
            indexList.add(splitList[i].substring(0, j).toLowerCase());
          }
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user.uid)
            .set({
          "userId": userCredential.user.uid,
          "name": username,
          "email": email,
          "searchIndex": indexList,
          "bio": '',
          "profilePhoto": userCredential.user.photoURL ??
              'https://ui-avatars.com/api/?name=$username&background=ff5733&color=fff&length=1',
          "timestamp": timestamp,
        }).then((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        });
      }
    } on PlatformException catch (err) {
      var message = 'An error occured, Please check your credentials.';

      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: AuthForm(
            _submitAuthForm,
            _isLoading,
          ),
        ),
      ),
    );
  }
}
