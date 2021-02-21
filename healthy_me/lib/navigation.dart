import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signin.dart';
import 'constants.dart';
import 'profilepage.dart';
import 'uploadscreen.dart';

class Nav extends StatefulWidget {
  final User user;
  Nav({Key key, this.user}) : super(key: key);

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _selectedIndex = 1;
  List<Widget> _widgetOptions() => <Widget>[
        UploadScreen(),
        MyHomePage(),
        ProfilePage(),
      ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future _signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = _widgetOptions();
    print(widget.user.uid);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kPrimaryColor,
        elevation: 0,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () async {
                _signOut().whenComplete(() {
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) {
                    return SignIn();
                  }));
                });
              },
              child: Icon(Icons.logout, color: kSecondaryColor),
            ),
          ),
        ],
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: kSecondaryColor,
        color: kPrimaryColor,
        index: 1,
        items: [
          Icon(
            Icons.add_circle_rounded,
            color: kSecondaryColor,
          ),
          Icon(
            Icons.home,
            color: kSecondaryColor,
          ),
          Icon(
            Icons.person,
            color: kSecondaryColor,
          ),
        ],
        onTap: _onItemTap,
      ),
    );
  }
}
