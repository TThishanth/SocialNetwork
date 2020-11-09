import 'package:SocialNetwork/Services/auth_services.dart';
import 'package:SocialNetwork/pages/auth/reset_password.dart';
import 'package:SocialNetwork/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AuthForm extends StatefulWidget {
  AuthForm(this.submitFn, this.isLoading);
  final bool isLoading;
  final void Function(
    String username,
    String email,
    String password,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  Authentication _authentication = Authentication();
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _retypePasswordController = new TextEditingController();

  void _submitForm() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();

      widget.submitFn(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _isLogin,
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
                _isLogin ? 'Welcome\nBack' : 'Create\nAccount',
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
                  top: 30.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isLogin)
                        TextFormField(
                          controller: _nameController,
                          autocorrect: true,
                          textCapitalization: TextCapitalization.words,
                          enableSuggestions: false,
                          validator: (value) {
                            if (value.isEmpty || value.length < 4) {
                              return 'Username must be at least 4 letters long.';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        controller: _emailController,
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
                        height: 20.0,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter password';
                          } else if (value.trim().length < 7) {
                            return 'Password must be atleast 7 characters!';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          prefixIcon: Icon(Icons.vpn_key),
                        ),
                      ),
                      if (!_isLogin)
                        SizedBox(
                          height: 20.0,
                        ),
                      if (!_isLogin)
                        TextFormField(
                          controller: _retypePasswordController,
                          obscureText: true,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Re-enter password';
                            } else if (value.trim() !=
                                _passwordController.text.trim()) {
                              return 'Password did\'t match. Please re-enter password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Re-type password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            prefixIcon: Icon(Icons.vpn_key),
                          ),
                        ),
                      if (_isLogin)
                        Container(
                          alignment: Alignment.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResetPassword(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
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
                                onPressed: _submitForm,
                                child: Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.all(15.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _isLogin ? 'SIGN IN' : 'REGISTER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      if (_isLogin)
                        Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 100.0,
                                child: Divider(
                                  color: Colors.grey[900],
                                ),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                'or',
                                style: TextStyle(fontSize: 15.0),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              SizedBox(
                                width: 100.0,
                                child: Divider(
                                  color: Colors.grey[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_isLogin)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 15.0,
                            top: 10.0,
                          ),
                          child: FlatButton.icon(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            color: Colors.grey[300],
                            onPressed: () async {
                              try {
                                await _authentication
                                    .googleSignIn()
                                    .whenComplete(() {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomePage(),
                                    ),
                                  );
                                });
                              } catch (err) {
                                print(err);
                              }
                            },
                            icon: FaIcon(
                              FontAwesomeIcons.google,
                              color: Colors.deepOrange,
                            ),
                            label: Text('Sign in with google'),
                          ),
                        ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_isLogin
                                ? "Don't have an account?"
                                : "Already have an account?"),
                            FlatButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin ? 'Register' : 'Sign in',
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
