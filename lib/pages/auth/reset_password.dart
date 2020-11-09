import 'dart:async';

import 'package:SocialNetwork/Services/auth_services.dart';
import 'package:SocialNetwork/pages/auth/auth_page.dart';
import 'package:SocialNetwork/widgets/auth/reset_password_form.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _resetPassKey = GlobalKey<ScaffoldState>();
  Authentication _authentication = Authentication();
  final _isLoading = false;

  void _submitResetPasswordForm(
    String email,
    BuildContext ctx,
  ) async {
    try {
      await _authentication.resetPassword(email);

      SnackBar snackBar = SnackBar(
        content: Text('A password reset link has been sent to ' + email),
        backgroundColor: Theme.of(ctx).primaryColor,
      );
      _resetPassKey.currentState.showSnackBar(snackBar);

      Timer(
        Duration(milliseconds: 700),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AuthPage(),
          ),
        ),
      );
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _resetPassKey,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: ResetPasswordForm(
            _submitResetPasswordForm,
            _isLoading,
          ),
        ),
      ),
    );
  }
}
