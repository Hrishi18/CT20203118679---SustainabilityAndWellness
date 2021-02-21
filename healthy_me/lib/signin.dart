import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthy_me/constants.dart';
import 'navigation.dart';
import 'register.dart';
import 'databasemanager.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            child: Stack(
              children: <Widget>[
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/loginui.png"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                Text('Hello, \nWelcome Back!',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: kFontFamily,
                      color: kSecondaryText,
                      fontWeight: FontWeight.bold,
                    ))
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          withEmailPassword(),
        ],
      ),
    );
  }

  Widget withEmailPassword() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.transparent,
        ),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              cursorColor: kSecondaryColor,
              style: TextStyle(
                fontFamily: kFontFamily,
                color: kSecondaryText,
              ),
              decoration: InputDecoration(
                labelText: 'Email ID',
                prefixIcon: IconTheme(
                  data: IconThemeData(color: kSecondaryColor),
                  child: Icon(Icons.email),
                ),
                labelStyle: TextStyle(
                  color: kSecondaryColor,
                  fontFamily: kFontFamily,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: kSecondaryColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: kSecondaryColor, width: 2),
                ),
              ),
              validator: (String val) {
                if (val.isEmpty) {
                  return ('Please enter some text');
                }
                return null;
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              obscureText: true,
              controller: _passwordController,
              cursorColor: kSecondaryColor,
              style: TextStyle(
                fontFamily: kFontFamily,
                color: kSecondaryText,
              ),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: IconTheme(
                  data: IconThemeData(color: kSecondaryColor),
                  child: Icon(Icons.lock),
                ),
                labelStyle: TextStyle(
                  color: kSecondaryColor,
                  fontFamily: kFontFamily,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: kSecondaryColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: kSecondaryColor, width: 2),
                ),
              ),
              validator: (String val) {
                if (val.isEmpty) {
                  return ('Please enter some text');
                }
                return null;
              },
            ),
            SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () async {
                if (_formKey.currentState.validate()) {
                  _signInWithEmailPassword();
                }
              },
              child: Container(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 70),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: kSecondaryColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: kPrimaryText,
                    fontFamily: kFontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () async {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Register();
                }));
              },
              child: Text(
                'Create Account',
                style: TextStyle(
                  color: kSecondaryText,
                  fontFamily: kFontFamily,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.double,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signInWithEmailPassword() async {
    try {
      final User user = (await _auth.signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text))
          .user;
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
      DatabaseManager().setUid();

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return Nav(
          user: user,
        );
      }));
    } catch (e) {
      _emailController.clear();
      _passwordController.clear();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: kSecondaryColor,
        content: Text(
          'Invalid User Credentials. Please Try Again!',
          style: TextStyle(
            fontFamily: kFontFamily,
            color: kPrimaryText,
          ),
        ),
      ));
      print(e);
    }
  }
}
