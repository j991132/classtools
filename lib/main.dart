import 'dart:convert';
import 'dart:html' as html;
import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'package:wakelock/wakelock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'MyApp.dart';
import 'firebase_options.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 에러방지 코딩셰프 매운맛 26강 참고
  WakelockPlus.enable(); //화면꺼짐방지 -> 이건 안먹힌다 index.html 에서 스크립트 추가해서 해결한다.

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}










//테스트 페이지
class test extends StatefulWidget {
  const test({Key? key}) : super(key: key);

  @override
  State<test> createState() => _testState();
}

class _testState extends State<test> {
  var _openResult = 'Unknown';

  late PdfViewerController _pdfViewerController;
  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    // result.files.first.bytes

    if (result != null) {
      PlatformFile file = result.files.first;

      print(file.name);
      print(utf8.decode(file.bytes!));
      // print(file.size);
      print(file.extension);
      // print(file.path);
      _openResult = "utf8.decode(file.bytes!)";  //바이트속성으로 내용파악
      print(_openResult);
      OpenFile.open(utf8.decode(file.bytes!));
    }

/*
    // opens storage to pick files and the picked file or files
    // are assigned into result and if no file is chosen result is null.
    // you can also toggle "allowMultiple" true or false depending on your need
    final result3 = await FilePicker.platform.pickFiles(allowMultiple: true);

    // if no file is picked
    if (result3 == null) return;
    print(result3.files.first.name);
    print(result3.files.first.size);
    print(result3.files.first.path);
    // we get the file from result object
    final file = result3.files.first;
*/
    // _openFile(file);
  }

  void _openFile(PlatformFile file) {
    OpenFile.open(file.path);
  }
  @override
  void initState() {
    _pdfViewerController = PdfViewerController();

    super.initState();
  }
  @override

  Widget build(BuildContext context) {

    // _pdfViewerController.zoomLevel = 3;
    return Scaffold(
        appBar: AppBar(
          title: Text('뷰 테스트'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.zoom_in,
                color: Colors.white,
              ),
              onPressed: () {
                _pdfViewerController.zoomLevel = 0.5;
              },
            ),
          ],
        ),

        body:
//pdf 한페이지씩 보기
        SfPdfViewer.asset('1.pdf', pageLayoutMode: PdfPageLayoutMode.single ),


            // SfPdfViewer.network('https://firebasestorage.googleapis.com/v0/b/classtools-9d1f1.appspot.com/o/1.pdf', pageLayoutMode: PdfPageLayoutMode.single),
            /*
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Text('open result: $_openResult\n'),
              TextButton(
                child: Text('Tap to open file'),
                onPressed: _pickFile,
              ),
                  SfPdfViewer.network(
                      'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf'),
            ])
        */
            );
  }
}


//테스트용 페이지
class Producttest extends StatefulWidget {
  const Producttest({Key? key}) : super(key: key);

  @override
  State<Producttest> createState() => _ProducttestState();
}

class _ProducttestState extends State<Producttest> {
  CollectionReference product =
      FirebaseFirestore.instance.collection('classname');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  Future<void> _update(DocumentSnapshot documentSnapshot) async {
    nameController.text = documentSnapshot['name'];
    priceController.text = documentSnapshot['price'];

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom // 키보드가 올라왔을대 키보드 위에 창이 위치함
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final String name = nameController.text;
                    final String price = priceController.text;
                    await product
                        .doc(documentSnapshot.id) //현재 도큐먼트 인덱스 아이디 전달
                        .update({"name": name, "price": price});
                    nameController.text = "";
                    priceController.text = "";
                    Navigator.of(context).pop();
                  },
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _create() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom // 키보드가 올라왔을대 키보드 위에 창이 위치함
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final String name = nameController.text;
                    final String price = priceController.text;
                    await product.add({'name': name, 'price': price});

                    nameController.text = "";
                    priceController.text = "";
                    Navigator.of(context).pop();
                  },
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _delete(String productId) async {
    await product.doc(productId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('퀴즈부저'),
      ),
      body: StreamBuilder(
        stream: product.snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin:
                      EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(documentSnapshot['price']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _update(documentSnapshot);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              _delete(documentSnapshot.id);
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _create();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
