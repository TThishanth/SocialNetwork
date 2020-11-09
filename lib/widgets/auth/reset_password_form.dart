import 'package:SocialNetwork/pages/auth/auth_page.dart';
import 'package:flutter/material.dart';

class ResetPasswordForm extends StatefulWidget {
  ResetPasswordForm(this.resetSubmitFn, this.isLoading);
  final bool isLoading;
  final void Function(
    String resetEmail,
    BuildContext ctx,
  ) resetSubmitFn;

  @override
  _ResetPasswordFormState createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _resetFormKey = GlobalKey<FormState>();
  final TextEditingController _resetPasswordEmailController = TextEditingController();

  void _submitResetForm() {
    final isValid = _resetFormKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _resetFormKey.currentState.save();

      widget.resetSubmitFn(
        _resetPasswordEmailController.text.trim(),
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.8),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 50.0,
                top: 40.0,
              ),
              child: Text(
                'Reset\nPassword',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: 40.0,
                ),
                child: Form(
                  key: _resetFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _resetPasswordEmailController,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter an Email Address';
                          } else if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        alignment: Alignment.center,
                        child: (widget.isLoading)
                            ? CircularProgressIndicator()
                            : RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.8),
                                onPressed: _submitResetForm,
                                child: Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.all(15.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'SUBMIT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Return to"),
                            FlatButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AuthPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
