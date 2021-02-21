import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'pdfviewer.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  List<Modal> itemList = List();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final mainReference = FirebaseDatabase.instance
      .reference()
      .child(FirebaseAuth.instance.currentUser.uid.toString());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String name, path;
  int size = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kSecondaryColor,
      body: StreamBuilder(
          stream: mainReference.onValue,
          builder: (context, AsyncSnapshot<Event> snapshot) {
            if (snapshot.hasData) {
              print(snapshot.hasData);
              DataSnapshot data = snapshot.data.snapshot;
              var values = data.value;
              itemList.clear();
              if (values != null) {
                values.forEach((key, value) {
                  Modal m = new Modal(value['PDF'], value['FileName'],
                      value['FilePath'], value['FileSize']);
                  itemList.add(m);
                });
              }
              return itemList.length == 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            color: kPrimaryColor,
                            size: 70,
                          ),
                          Text(
                            "No files to display!",
                            style: TextStyle(
                              color: kPrimaryText,
                              fontSize: 20,
                              fontFamily: kFontFamily,
                            ),
                          )
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: itemList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              String passData = itemList[index].link;
                              print("Upload Screen" + passData.toString());
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfViewPage(),
                                  settings: RouteSettings(
                                    arguments: passData,
                                  ),
                                ),
                              );
                            },
                            
                              child: Card(
                                color: kPrimaryColor,
                                elevation: 10.0,
                                child: Container(
                                  //height: 140,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child: Text(itemList[index].name,
                                            style: TextStyle(
                                                fontFamily: kFontFamily,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: kSecondaryText)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child: Text(
                                          "Path: " + itemList[index].path,
                                          style: TextStyle(
                                              fontFamily: kFontFamily,
                                              fontSize: 15,
                                              color: kSecondaryText),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child: Text(
                                            "Size: " +
                                                (itemList[index].size)
                                                    .toString() +
                                                " Bytes",
                                            style: TextStyle(
                                                fontFamily: kFontFamily,
                                                fontSize: 15,
                                                color: kSecondaryText)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            
                          ),
                        );
                      },
                    );
            }
            return Container(
              height: 0,
              width: 0,
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getPdfAndUpload();
        },
        child: Icon(
          Icons.add,
          color: kPrimaryColor,
        ),
        backgroundColor: kBackgroundColor,
      ),
    );
  }

  Future getPdfAndUpload() async {
    var rng = new Random();
    String randomName = "";
    for (var i = 0; i < 20; i++) {
      print(rng.nextInt(100));
      randomName += rng.nextInt(100).toString();
    }
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.custom);
    if (result != null) {
      File file = File(result.files.single.path);
      PlatformFile fileRead = result.files.first;
      setState(() {
        name = fileRead.name;
        path = fileRead.path;
        size = (fileRead.size);
      });

      String fileName = '${randomName}.pdf';
      savePdf(file.readAsBytesSync(), fileName);
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: kBackgroundColor,
        content: Text(
          'No Document Selected.',
          style: TextStyle(
            fontFamily: kFontFamily,
            color: kPrimaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));
    }
  }

  savePdf(List<int> asset, String name) async {
    Reference reference = FirebaseStorage.instance.ref().child(name);
    UploadTask uploadTask = reference.putData(asset);
    String url = await (await uploadTask).ref.getDownloadURL();
    documentFileUpload(url);
  }

  String CreateCryptoRandomString([int length = 32]) {
    //generate key
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  void documentFileUpload(String str) {
    var data = {
      "PDF": str,
      "FileName": name,
      "FilePath": path,
      "FileSize": size,
    };

    mainReference.child(CreateCryptoRandomString()).set(data).then((v) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: kBackgroundColor,
        content: Text(
          'File uploaded successfully!',
          style: TextStyle(
            fontFamily: kFontFamily,
            color: kPrimaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ));

      print("Store Successfully");
    });
  }
}

class Modal {
  String link, name, path;
  int size;
  Modal(this.link, this.name, this.path, this.size);
}
