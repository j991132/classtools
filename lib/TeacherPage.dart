//선생님페이지
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class teacherPage extends StatefulWidget {
  String collectionname = '';
  String teamname = '';
  String pdfexist = '';
  String url = '';
  teacherPage(this.collectionname, this.teamname, this.pdfexist, this.url, {Key? key}) : super(key: key);

  @override
  State<teacherPage> createState() => _teacherPageState();
}

class _teacherPageState extends State<teacherPage> {
  late CollectionReference product;
  final player = AudioPlayer();
  bool _isDialogShowing = false;
  late PlatformFile resurtFile;
  bool _showPdf = false;

  Future playEffectAudio() async {
    final duration = await player.setAsset("assets/buzzer.wav");
    await player.play();
  }

  //선착 모둠명 다이얼로그 띄우기
  // void showPopup(context, String teamname, String docid) {
  void showPopup(context, String teamname) {
    _isDialogShowing = true; // set it `true` since dialog is being displayed
    playEffectAudio();

    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.width * 0.8,
              // width: MediaQuery.of(context).size.width * 0.9,
              // height: 380,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AutoSizeText(teamname,
                      style: TextStyle(
                        //폰트사이즈 꽉차게
                          fontSize: MediaQuery.of(context).size.width,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold),

                      // Set minFontSize as 18
                      maxFontSize: 500,

                      // Set maxLines as 4
                      maxLines: 1,

                      // Set overflow as TextOverflow.ellipsis
                      overflow: TextOverflow.ellipsis),
                  // Text(
                  //   teamname,
                  //   style: TextStyle(
                  //       fontSize: 50,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.redAccent),
                  // ),
                  ElevatedButton.icon(
                    onPressed: () {
                      //도큐먼트 삭제
                      deleteAll();
                      // _delete(docid);
                      _isDialogShowing =
                      false; // set it `false` since dialog is closed
                      //팝업창 내리기
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close),
                    label: Text('닫기'),
                  )
                ],
              ),
            ),
          );
        });

    Timer(Duration(seconds: 3), () {
      if (_isDialogShowing == true) {
        _isDialogShowing = false; // set it `false` since dialog is closed
        Timer(Duration(seconds: 1), () {
          //씹힘방지
          deleteAll();
        });
        Navigator.pop(context);
      }
    });
  }

  Future<void> deleteAll() async {
    final collection = await FirebaseFirestore.instance
        .collection('${widget.collectionname}')
        .doc('connect')
        .collection('teams')
        .get();

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in collection.docs) {
      batch.delete(doc.reference);
    }

    return batch.commit();
  }

  Future<void> _delete(String docid) async {
    await product.doc(docid).delete();
  }

  @override
  Widget build(BuildContext context) {
    product = FirebaseFirestore.instance
        .collection('${widget.collectionname}')
        .doc('connect')
        .collection('teams');

    return Scaffold(
      appBar: AppBar(
        title: Text('QUIZ? 퀴즈!'),
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              widget.pdfexist='false';
            }),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.picture_as_pdf_sharp), tooltip: 'PDF'
              ,onPressed: () async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
    withData: true,
    );

    // result.files.first.bytes

    if (result != null) {
    PlatformFile file = result.files.first;
    resurtFile = file;
    // print(file?.name);
    // print(resurtFile?.bytes);
    // print(file?.size);
    // print(file?.extension);
    // print(resurtFile.bytes as Uint8List);
    print(_showPdf);
    setState(() {
      _showPdf = !_showPdf;
      print(_showPdf);
    });
    // print(file?.path);



    }
              }
          ),
        ],
      ),

      body: StreamBuilder(
        stream: product.orderBy('time', descending: false).snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if(widget.pdfexist == 'false' && _showPdf == false){
            if (streamSnapshot.hasData) {
              // if (streamSnapshot.hasData && pdfexist == false) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                  streamSnapshot.data!.docs[index];
/*
                FirebaseFirestore db = FirebaseFirestore.instance;
                db.runTransaction((transaction) async{
                   DocumentSnapshot _snapshot = await transaction.get(product.doc());
                  if(documentSnapshot.exists){
                    //아래 콜백은 무조건 빌드가 끝난다음에 실행될 수 있도록 하는 장치 - 이게 없으면 빌드가 안끝났는데 팝업을 빌드하려고 해서 에러가 난다
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      showPopup(context, streamSnapshot.data!.docs[0]['teamname']);
                    });
                  } else {throw Exception('Does not exists');}
                } );
*/

                  if (_isDialogShowing == false) {
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      showPopup(
                        // context, streamSnapshot.data!.docs[0]['teamname'], documentSnapshot.id);
                          context,
                          streamSnapshot.data!.docs[0]['teamname']);
                    });
                    // _isDialogShowing = true; // set it `false` since dialog is closed
                  }
                  /*
                if (streamSnapshot.data!.docs.length <=1 ) {
                  debugPrint('스트림 스냅샷 길이'+streamSnapshot.data!.docs.length.toString());
                  //아래 콜백은 무조건 빌드가 끝난다음에 실행될 수 있도록 하는 장치 - 이게 없으면 빌드가 안끝났는데 팝업을 빌드하려고 해서 에러가 난다
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    showPopup(
                        // context, streamSnapshot.data!.docs[0]['teamname'], documentSnapshot.id);
                        context, streamSnapshot.data!.docs[0]['teamname']);
                  });
                }
                 */
                  else {
                    debugPrint('인덱스 번호' +
                        index.toString() +
                        '텍스트내용' +
                        documentSnapshot['teamname'] +
                        '다이얼로그상태' +
                        _isDialogShowing.toString());
                  }

                  //아래 콜백은 무조건 빌드가 끝난다음에 실행될 수 있도록 하는 장치 - 이게 없으면 빌드가 안끝났는데 팝업을 빌드하려고 해서 에러가 난다
                  //  WidgetsBinding.instance!.addPostFrameCallback((_) {
                  //    showPopup(context, streamSnapshot.data!.docs[0]['teamname']);
                  //  });

                  return Card(
                    margin:
                    EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                    child: ListTile(
                      title: Text(documentSnapshot['teamname']),
                      trailing: SizedBox(
                        width: 100,
                      ),
                    ),
                  );
                },

                // showPopup(context, documentSnapshot['teamname'].toString());

              );
            }
          }
          else if(_showPdf == true){
            if (_isDialogShowing == false) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                showPopup(
                  // context, streamSnapshot.data!.docs[0]['teamname'], documentSnapshot.id);
                    context,
                    streamSnapshot.data!.docs[0]['teamname']);
              });
              // _isDialogShowing = true; // set it `false` since dialog is closed
            }
            return Scaffold(

                body:
                SfPdfViewer.memory(resurtFile!.bytes!, pageLayoutMode: PdfPageLayoutMode.single),
            );

          }

          //pdfexist true 일경우

          else{
            if (_isDialogShowing == false) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                showPopup(
                  // context, streamSnapshot.data!.docs[0]['teamname'], documentSnapshot.id);
                    context,
                    streamSnapshot.data!.docs[0]['teamname']);
              });
              // _isDialogShowing = true; // set it `false` since dialog is closed
            }
            return Scaffold(

              body:
//pdf 한페이지씩 보기
//               SfPdfViewer.asset('1.pdf', pageLayoutMode: PdfPageLayoutMode.single ),

              SfPdfViewer.network(widget.url, pageLayoutMode: PdfPageLayoutMode.single),
              // SfPdfViewer.network('https://github.com/j991132/classtools/blob/master/assets/1.pdf', pageLayoutMode: PdfPageLayoutMode.single),
              //'https://pub-9c2cd5cd1ec6403eb4d2d4cc881b3049.r2.dev/1.pdf'
            );
          };

          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          deleteAll();
        },
        child: Icon(Icons.close),
      ),
    );
  }
}
