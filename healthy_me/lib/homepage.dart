import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import 'multiselect.dart';
import 'constants.dart';
import 'tile.dart';
import 'databasemanager.dart';

class MyHomePage extends StatefulWidget {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var firebaseUser = FirebaseAuth.instance.currentUser;
  DatabaseManager _databaseManager = DatabaseManager();

  int stepCountInteger;

  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;
  int heartrate, water = 0;
  int height = 0, weight = 0;
  int mailed = 1;
  double bmi = 0.0;
  double requiredWater = 0.0;
  String bluetoothText = "Searching...";
  bool buttonViewVisible = true;
  bool textViewVisible = false;
  bool searchTextVisible = true;

  StreamSubscription<StepCount> _subscription;
  Box<int> stepsBox = Hive.box('steps');
  int todaySteps;

  List<dynamic> symptomsList = [];

  _addDeviceTolist(final BluetoothDevice device) {
    print("called");

    if (!widget.devicesList.contains(device)) {
      if (mounted) {
        setState(() {
          widget.devicesList.add(device);
        });
      }
    }
  }

  Future<void> _readFromFireStore() async {
    FirebaseFirestore.instance
        .collection('profileInfo')
        .doc((FirebaseAuth.instance.currentUser).uid)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          heartrate = value.data()['HeartRate'];
          water = value.data()['Water'];
          height = value.data()['Height'];
          weight = value.data()['Weight'];
          print(weight);
          symptomsList = value.data()['Symptoms'];
          mailed = value.data()['Mailed'];
        });
      }
    });
  }
  
  int getRequiredWater() {    
    requiredWater = (weight*2*2.205)/(33.814 * 3);
    print(requiredWater);
    return requiredWater.round();
  }

  double calculateBMI() {
    bmi = (weight * 10000) / (height * height);
    _databaseManager.setBMI(double.parse(bmi.toStringAsFixed(2)));

    return bmi;
  }


  @override
  void initState() {
    super.initState();
    checkBluetooth();

    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        print(result.device);
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
    startListening();
    _databaseManager.setSymptoms(symptomsList);
    _readFromFireStore();
  }



  ListView _buildListViewOfDevices() {
    print(textViewVisible);

    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in widget.devicesList) {
      if (device.name.toString() == "Mi Band 1" ||
          device.name.toString() == "Mi Band 2" ||
          device.name.toString() == "Mi Band 3" ||
          device.name.toString() == "Mi Band 4") {
        searchTextVisible = false;
        containers.add(
          Container(
            height: 100,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        device.name == '' ? '(unknown device)' : device.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: kFontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(device.id.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: kFontFamily,
                          )),
                    ],
                  ),
                ),
                Visibility(
                  maintainAnimation: true,
                  maintainState: true,
                  visible: buttonViewVisible,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(22),
                            bottomRight: Radius.circular(22)),
                        side: BorderSide(color: kPrimaryColor)),
                    color: kPrimaryColor,
                    child: Text(
                      'Connect',
                      style: TextStyle(
                          color: kSecondaryText,
                          fontSize: 15,
                          fontFamily: kFontFamily),
                    ),
                    onPressed: () async {
                      widget.flutterBlue.stopScan();
                      try {
                        await device.connect();
                      } catch (e) {
                        if (e.code != 'already_connected') {
                          throw e;
                        }
                      } finally {
                        _services = await device.discoverServices();
                        if (mounted) {
                          setState(() {
                            _connectedDevice = device;
                            readHeartRate();
                            buttonViewVisible = false;
                            textViewVisible = true;
                          });
                        }
                      }
                    },
                  ),
                ),
                Visibility(
                  maintainAnimation: true,
                  maintainState: true,
                  visible: textViewVisible,
                  child: Text(
                    'Connected',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: kFontFamily),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      children: <Widget>[
        ...containers,
      ],
    );
  }

  void readHeartRate() {
    for (BluetoothService service in _services) {
      if (service.uuid.toString() == "0000180d-0000-1000-8000-00805f9b34fb") {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.notify) {
            characteristic.setNotifyValue(true);
            characteristic.value.listen((value) {
              widget.readValues[characteristic.uuid] = value;
              if (mounted) {
                setState(() {
                  if (value.isEmpty) {
                    print("this" + value.toString());
                  } else {
                    heartrate = value[1];
                    _databaseManager.setHeartRate(heartrate);
                    print(heartrate);
                  }
                });
              }
            });
          }
        }
      }
    }
  }

  
  Future<Null> refreshView() async {
    if (mounted) {
      setState(() {
        searchTextVisible = true;
        bluetoothText = "Searching...";
      });
    }
    return null;
  }

  Future<Null> checkBluetooth() async {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          bluetoothText = "Check if your bluetooth\n and gps is on!";
        });
      }
    });
  }

  void startListening() {
    _subscription = Pedometer.stepCountStream.listen(
      getTodaySteps,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  void _onDone() => print("Finished pedometer tracking");
  void _onError(error) => print("Flutter Pedometer Error: $error");

  Future<int> getTodaySteps(StepCount value) async {
    stepCountInteger = int.parse(((value.toString()).split(" "))[2]);

    int savedStepsCountKey = 999999;
    int savedStepsCount = stepsBox.get(savedStepsCountKey, defaultValue: 0);

    int todayDayNo = Jiffy(DateTime.now()).dayOfYear;
    if (stepCountInteger < savedStepsCount) {
      savedStepsCount = 0;
      stepsBox.put(savedStepsCountKey, savedStepsCount);
    }

    int lastDaySavedKey = 888888;
    int lastDaySaved = stepsBox.get(lastDaySavedKey, defaultValue: 0);

    if (lastDaySaved < todayDayNo) {
      lastDaySaved = todayDayNo;
      savedStepsCount = stepCountInteger;
      water = 0;
      _databaseManager.setWater(water);
      stepsBox
        ..put(lastDaySavedKey, lastDaySaved)
        ..put(savedStepsCountKey, savedStepsCount);
    }

    setState(() {
      todaySteps = stepCountInteger - savedStepsCount;
      _databaseManager.setSteps(todaySteps);
    });
    stepsBox.put(todayDayNo, todaySteps);
    return todaySteps;
  }

  void stopListening() {
    _subscription.cancel();
  }

  @override
  void dispose() {
    widget.flutterBlue.stopScan();
    stopListening();
    super.dispose();
  }

  List<MultiSelectDialogItem<int>> multiItem = List();

  final valuesToPopulate = {
    1: "itching",
    2: "skin_rash",
    3: "nodal_skin_eruptions",
    4: "continuous_sneezing",
    5: "shivering",
    6: "chills",
    7: "joint_pain",
    8: "stomach_pain",
    9: "acidity",
    10: "ulcers_on_tongue",
    11: "muscle_wasting",
    12: "vomiting",
    13: "burning_micturition",
    14: "spotting_urination",
    15: "fatigue",
    16: "weight_gain",
    17: "anxiety",
    18: "cold_hands_and_feets",
    19: "mood_swings",
    20: "weight_loss",
    21: "restlessness",
    22: "lethargy",
    23: "patches_in_throat",
    24: "irregular_sugar_level",
    25: "cough",
    26: "high_fever",
    27: "sunken_eyes",
    28: "breathlessness",
    29: "sweating",
    30: "dehydration",
    31: "indigestion",
    32: "headache",
    33: "yellowish_skin",
    34: "dark_urine",
    35: "nausea",
    36: "loss_of_appetite",
    37: "pain_behind_the_eyes",
    38: "back_pain",
    39: "constipation",
    40: "abdominal_pain",
    41: "diarrhoea",
    42: "mild_fever",
    43: "yellow_urine",
    44: "yellowing_of_eyes",
    45: "acute_liver_failure",
    46: "fluid_overload",
    47: "swelling_of_stomach",
    48: "swelled_lymph_nodes",
    49: "malaise",
    50: "blurred_and_distorted_vision",
    51: "phlegm",
    52: "throat_irritation",
    53: "redness_of_eyes",
    54: "sinus_pressure",
    55: "runny_nose",
    56: "congestion",
    57: "chest_pain",
    58: "weakness_in_limbs",
    59: "fast_heart_rate",
    60: "pain_during_bowel_movements",
    61: "pain_in_anal_region",
    62: "bloody_stool",
    63: "irritation_in_anus",
    64: "neck_pain",
    65: "dizziness",
    66: "cramps",
    67: "bruising",
    68: "obesity",
    69: "swollen_legs",
    70: "swollen_blood_vessels",
    71: "puffy_face_and_eyes",
    72: "enlarged_thyroid",
    73: "brittle_nails",
    74: "swollen_extremeties",
    75: "excessive_hunger",
    76: "extra_marital_contacts",
    77: "drying_and_tingling_lips",
    78: "slurred_speech",
    79: "knee_pain",
    80: "hip_joint_pain",
    81: "muscle_weakness",
    82: "stiff_neck",
    83: "swelling_joints",
    84: "movement_stiffness",
    85: "spinning_movements",
    86: "loss_of_balance",
    87: "unsteadiness",
    88: "weakness_of_one_body_side",
    89: "loss_of_smell",
    90: "bladder_discomfort",
    91: "foul_smell_of urine",
    92: "continuous_feel_of_urine",
    93: "passage_of_gases",
    94: "internal_itching",
    95: "toxic_look_(typhos)",
    96: "depression",
    97: "irritability",
    98: "muscle_pain",
    99: "altered_sensorium",
    100: "red_spots_over_body",
    101: "belly_pain",
    102: "abnormal_menstruation",
    103: "dischromic _patches",
    104: "watering_from_eyes",
    105: "increased_appetite",
    106: "polyuria",
    107: "family_history",
    108: "mucoid_sputum",
    109: "rusty_sputum",
    110: "lack_of_concentration",
    111: "visual_disturbances",
    112: "receiving_blood_transfusion",
    113: "receiving_unsterile_injections",
    114: "coma",
    115: "stomach_bleeding",
    116: "distention_of_abdomen",
    117: "history_of_alcohol_consumption",
    118: "fluid_overload",
    119: "blood_in_sputum",
    120: "prominent_veins_on_calf",
    121: "palpitations",
    122: "painful_walking",
    123: "pus_filled_pimples",
    124: "blackheads",
    125: "scurring",
    126: "skin_peeling",
    127: "silver_like_dusting",
    128: "small_dents_in_nails",
    129: "inflammatory_nails",
    130: "blister",
    131: "red_sore_around_nose",
    132: "yellow_crust_ooze",
  };

  void populateMultiSelect() {
    for (int v in valuesToPopulate.keys) {
      multiItem.add(MultiSelectDialogItem(v, valuesToPopulate[v]));
    }
  }

  void getValueFromKey(Set selection) {
    _databaseManager.deleteSymptoms(symptomsList);
    symptomsList = [];

    if (selection != null) {
      for (int x in selection.toList()) {
        symptomsList.add(valuesToPopulate[x].toString());
        print(valuesToPopulate[x]);
      }
      _databaseManager.setSymptoms(symptomsList);
      _databaseManager.setMailed(0);
    }
    print(symptomsList);
  }

  void _showMultiSelect(BuildContext context) async {
    multiItem = [];
    populateMultiSelect();
    final items = multiItem;

    final selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: items,
        );
      },
    );

    print(selectedValues);
    getValueFromKey(selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kSecondaryColor,
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: size.height * 0.3,
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(80.0),
                              bottomLeft: Radius.circular(80.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 10),
                                blurRadius: 50,
                                color: kPrimaryColor.withOpacity(0.23),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                          child: Container(
                            child: Text(
                              "Hello,",
                              style: TextStyle(
                                  fontSize: 27,
                                  color: kSecondaryText,
                                  fontFamily: kFontFamily),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 55.0, 20.0, 20.0),
                          child: Container(
                            child: Text(
                              firebaseUser.displayName,
                              style: TextStyle(
                                  fontSize: 27,
                                  color: kSecondaryText,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: kFontFamily),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 130.0, 20.0, 0.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: 140,
                                  alignment: Alignment.center,
                                  child: _buildListViewOfDevices(),
                                ),
                                Visibility(
                                  maintainAnimation: true,
                                  maintainState: true,
                                  visible: searchTextVisible,
                                  child: Container(
                                    height: 140,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "$bluetoothText",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: kFontFamily,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      refreshView();
                                      checkBluetooth();
                                      print('tap');
                                    },
                                    child: Icon(
                                      Icons.refresh,
                                      size: 30,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Tile(
                                backgroundColor: kPrimaryColor,
                                borderColor: kPrimaryColor,
                                textColor: kSecondaryText,
                                title: heartrate?.toString() ?? '0',
                                subtitle: 'bpm',
                                icon: Icons.favorite_outlined,
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Expanded(
                              flex: 1,
                              child: Tile(
                                backgroundColor: kPrimaryColor,
                                borderColor: kPrimaryColor,
                                textColor: kSecondaryText,
                                title: todaySteps?.toString() ?? '0',
                                subtitle: 'steps',
                                icon: Icons.directions_run,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                height: 180.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: kPrimaryColor,
                                      style: BorderStyle.solid,
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: kPrimaryColor,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 5,
                                              right: 12,
                                              left: 45,
                                            ),
                                            child: IconButton(
                                              color: kSecondaryText,
                                              icon: Icon(
                                                Icons.arrow_drop_up,
                                              ),
                                              onPressed: () {
                                                if (water == 10) {
                                                } else {
                                                  if (mounted) {
                                                    setState(() {
                                                      water = water + 1;
                                                      _databaseManager
                                                          .setWater(water);
                                                    });
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 20, right: 20),
                                          child: Opacity(
                                            opacity: 1,
                                            child: Icon(
                                              Icons.opacity,
                                              color: kSecondaryText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                water?.toString() ??
                                                    (water = 0).toString(),
                                                style: TextStyle(
                                                  fontSize: 35.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: kSecondaryText,
                                                  fontFamily: kFontFamily,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Text(
                                                "/" +
                                                    getRequiredWater()
                                                        .toString(),
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: kSecondaryText,
                                                  fontFamily: kFontFamily,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "litres",
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            color: kSecondaryText,
                                            fontFamily: kFontFamily,
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2,
                                                    right: 55,
                                                    left: 45,
                                                    bottom: 2),
                                                child: IconButton(
                                                  color: kSecondaryText,
                                                  icon: Icon(
                                                      Icons.arrow_drop_down),
                                                  onPressed: () {
                                                    if (water == 0) {
                                                    } else {
                                                      if (mounted) {
                                                        setState(() {
                                                          water = water - 1;
                                                          _databaseManager
                                                              .setWater(water);
                                                        });
                                                      }
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Expanded(
                              child: Tile(
                                backgroundColor: kPrimaryColor,
                                borderColor: kPrimaryColor,
                                textColor: kSecondaryText,
                                title:
                                    calculateBMI()?.toStringAsFixed(1) ?? '0',
                                subtitle: 'bmi',
                                icon: Icons.emoji_events,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(20.0),
                                height: 180.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: kPrimaryColor,
                                      style: BorderStyle.solid,
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: kPrimaryColor,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Opacity(
                                          opacity: 1,
                                          child: Icon(
                                            Icons.sick_outlined,
                                            color: kSecondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            "Not feeling well?",
                                            style: TextStyle(
                                              fontSize: 25.0,
                                              fontWeight: FontWeight.w400,
                                              color: kSecondaryText,
                                              fontFamily: kFontFamily,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "Check your symptoms now!",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: kSecondaryText,
                                            fontFamily: kFontFamily,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: OutlineButton(
                                            child: Text(
                                              "+",
                                              style: TextStyle(
                                                fontFamily: kFontFamily,
                                                color: kSecondaryText,
                                                fontSize: 35,
                                              ),
                                            ),
                                            onPressed: () {
                                              _showMultiSelect(context);
                                            },
                                            borderSide: BorderSide(
                                                color: kSecondaryText),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            )),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
