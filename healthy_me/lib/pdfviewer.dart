import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'constants.dart';

class PdfViewPage extends StatefulWidget {
  const PdfViewPage({Key key}) : super(key: key);
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  bool _isLoading = true;
  PDFDocument document;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      loadDocument();
    } catch (e) {
      print(e);
    }
  }

  loadDocument() async {
    String data = ModalRoute.of(context).settings.arguments;
    document = await PDFDocument.fromURL(data);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Healthy Me'),
      ),
      body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(document: document)),
    );
  }
}
