import 'package:flutter/material.dart';
import 'dart:ui';
import 'constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int height = 0, weight = 0;
  var firebaseUser = FirebaseAuth.instance.currentUser;

  Future<void> _readFromFireStore() async {
    FirebaseFirestore.instance
        .collection('profileInfo')
        .doc((FirebaseAuth.instance.currentUser).uid)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          height = value.data()['Height'];
          weight = value.data()['Weight'];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _readFromFireStore();
  }

  Widget textCard(BuildContext context, String userInformation,
      String userInformationType, Icon iconName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: iconName,
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    userInformation,
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      color: kPrimaryText,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 43),
              child: Text(
                userInformationType,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  color: kPrimaryText,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColor,
      body: Column(
        children: [
          Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.18,
                    color: kPrimaryColor,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Profile',
                        style: TextStyle(
                            fontSize: 35,
                            fontFamily: kFontFamily,
                            letterSpacing: 1.5,
                            color: kSecondaryText,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: kPrimaryColor,
                          child: IconTheme(
                              data: IconThemeData(
                                color: kSecondaryColor,
                                size: 120,
                              ),
                              child: Icon(Icons.person_rounded)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          textCard(
              context, firebaseUser.displayName, "Name", (Icon(Icons.face))),
          textCard(context, firebaseUser.email, "EmailId", (Icon(Icons.mail))),
          textCard(context, height.toString() + "cm", "Height",
              (Icon(Icons.height))),
          textCard(context, weight.toString() + "kg", "Weight",
              (Icon(Icons.line_weight))),
        ],
      ),
    );
  }
}
