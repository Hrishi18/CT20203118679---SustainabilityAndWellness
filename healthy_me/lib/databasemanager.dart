import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseManager {
  final CollectionReference profileList =
      FirebaseFirestore.instance.collection('profileInfo');
  var firebaseUser = FirebaseAuth.instance.currentUser;

  Future setUid() async {
    return await profileList
        .doc(firebaseUser.uid)
        .set({"Uid": firebaseUser.uid}, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }

  Future setName() async {
    return await profileList.doc(firebaseUser.uid).set(
        {"Name": firebaseUser.displayName}, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }

  Future setEmailId() async {
    return await profileList.doc(firebaseUser.uid).set(
        {"EmailId": firebaseUser.email}, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }

  Future setHeight(int height) async {
    return await profileList
        .doc(firebaseUser.uid)
        .set({"Height": height}, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }

  Future setWeight(int weight) async {
    return await profileList
        .doc(firebaseUser.uid)
        .set({"Weight": weight}, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }

  Future setHeartRate(int heartrate) async {
    return await profileList
        .doc(firebaseUser.uid)
        .set({"HeartRate": heartrate}, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }

  Future setSteps(int steps) async {
    return await profileList
        .doc(firebaseUser.uid)
        .set({"Steps": steps}, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }

  Future setWater(int water) async {
    return await profileList
        .doc(firebaseUser.uid)
        .set({"Water": water}, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }

  Future setBMI(double bmi) async {
    return await profileList
        .doc(firebaseUser.uid)
        .set({"BMI": bmi}, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }

  Future setSymptoms(List symptoms) async {
    return await profileList.doc(firebaseUser.uid).set(
        {"Symptoms": (FieldValue.arrayUnion(symptoms))},
        SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }

  Future deleteSymptoms(List symptoms) async {
    return await profileList.doc(firebaseUser.uid).set(
        {"Symptoms": (FieldValue.arrayRemove(symptoms))},
        SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }

  Future setMailed(int mailed) async {
    return await profileList
        .doc(firebaseUser.uid)
        .set({"Mailed": mailed}, SetOptions(merge: true)).then((_) {
      print("success!");
    }).catchError((e) {
      print(e);
    });
  }
}
