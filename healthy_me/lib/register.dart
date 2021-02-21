import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'navigation.dart';
import 'constants.dart';
import 'databasemanager.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _displayName = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kPrimaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
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
                Text('Register NOW!',
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
            height: 20,
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _displayName,
                    cursorColor: kSecondaryColor,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      color: kSecondaryText,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: IconTheme(
                        data: IconThemeData(color: kSecondaryColor),
                        child: Icon(Icons.face),
                      ),
                      labelStyle: TextStyle(
                        color: kSecondaryColor,
                        fontFamily: kFontFamily,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: kSecondaryColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: kSecondaryColor, width: 2),
                      ),
                    ),
                    validator: (val) {
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
                    controller: _emailController,
                    cursorColor: kSecondaryColor,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      color: kSecondaryText,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Email ID",
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
                        borderSide:
                            BorderSide(color: kSecondaryColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: kSecondaryColor, width: 2),
                      ),
                    ),
                    validator: (val) {
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
                    controller: _passwordController,
                    obscureText: true,
                    cursorColor: kSecondaryColor,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      color: kSecondaryText,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Password",
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
                        borderSide:
                            BorderSide(color: kSecondaryColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: kSecondaryColor, width: 2),
                      ),
                    ),
                    validator: (val) {
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
                    controller: _heightController,
                    cursorColor: kSecondaryColor,
                    keyboardType: TextInputType.number,

                    style: TextStyle(
                      fontFamily: kFontFamily,
                      color: kSecondaryText,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Height(cm)",
                      prefixIcon: IconTheme(
                        data: IconThemeData(color: kSecondaryColor),
                        child: Icon(Icons.height),
                      ),
                      labelStyle: TextStyle(
                        color: kSecondaryColor,
                        fontFamily: kFontFamily,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: kSecondaryColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: kSecondaryColor, width: 2),
                      ),
                    ),
                    validator: (val) {
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
                    controller: _weightController,
                    cursorColor: kSecondaryColor,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      color: kSecondaryText,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Weight(kg)",
                      prefixIcon: IconTheme(
                        data: IconThemeData(color: kSecondaryColor),
                        child: Icon(Icons.line_weight),
                      ),
                      labelStyle: TextStyle(
                        color: kSecondaryColor,
                        fontFamily: kFontFamily,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: kSecondaryColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: kSecondaryColor, width: 2),
                      ),
                    ),
                    validator: (val) {
                      if (val.isEmpty) {
                        return ('Please enter some text');
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_formKey.currentState.validate()) {
                        _registerAccount();
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
                        'Register',
                        style: TextStyle(
                          color: kPrimaryText,
                          fontFamily: kFontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _registerAccount() async {
    final User user = (await _auth.createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text))
        .user;
    if (user != null) {
      if (user.emailVerified) {
        await user.sendEmailVerification();
      }
      await user.updateProfile(displayName: _displayName.text);
      final user1 = _auth.currentUser;
      DatabaseManager().setUid();
      DatabaseManager().setName();
      DatabaseManager().setEmailId();
      DatabaseManager().setHeight(int.parse(_heightController.text));
      DatabaseManager().setWeight(int.parse(_weightController.text));
      DatabaseManager().setMailed(1);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return Nav(
          user: user1,
        );
      }));
    }
  }
}
