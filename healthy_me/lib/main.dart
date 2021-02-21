import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splashscreen/splashscreen.dart';
import 'constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'signin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox<int>('steps');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        primaryColor: kPrimaryColor,
        fontFamily: 'Times New Roman',
        textTheme: Theme.of(context).textTheme.apply(bodyColor: kTextColor),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: new FirstScreen(),
    );
  }
}

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  Image image1;
  @override
  void initState() {
    super.initState();
    image1 = Image.asset('assets/images/healthymeicon.png');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(image1.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 8,
      backgroundColor: Colors.white,
      image: image1,
      photoSize: 90.0,
      title: new Text(
        'Healthy Me',
        style: new TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
          color: Colors.black,
          fontFamily: 'YatraOne',
        ),
        textAlign: TextAlign.center,
      ),
      loaderColor: Colors.grey,
      navigateAfterSeconds: SignIn(),
      loadingText: Text(
        "Developed By,\nHrishikesh Gawas",
        style: TextStyle(
            color: Colors.black, fontSize: 17.0, fontFamily: 'YatraOne'),
        textAlign: TextAlign.center,
      ),
    );
  }
}
