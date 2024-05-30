import 'dart:convert';
import 'dart:html' as html;
import 'dart:html';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'package:wakelock/wakelock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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

// A function that calls the Wake Lock API
// Future<html.WakeLockSentinel> preventDisplaySleep() async {
//   // Request a screen wake lock
//   return await html.window.navigator.wakeLock.request('screen');
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      home: LogIn(),
    );
  }
}

class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  bool pdfexist = false;
  var result;
  final db = FirebaseFirestore.instance;
  WebViewController? _webViewController;

  //컬렉션 이름확인->교사용 페이지 이동 메서드
  gototeacherpage(String collectionname) async {
    result = await db.collection(collectionname).doc('connect').get();
    print(collectionname);
    print(result.data());
    if (result.data() == null) {
      CollectionReference product =
          await FirebaseFirestore.instance.collection(collectionname);
      await product.doc('connect').set({'name': 'connect', 'price': 'ok'});
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => teacherPage(
                  (controller.text + controller2.text).trim(),
                  controller3.text.trim(), pdfexist.toString())));
    } else if (result.data().toString().contains('ok')) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => teacherPage(
                  (controller.text + controller2.text).trim(),
                  controller3.text.trim(), pdfexist.toString())));
    } else {
      showSnackBar(context, Text('학교이름과 방번호를 다시 살펴보세요'));
    }
  }

  //컬렉션 이름확인->학생용 부저페이지 이동 메서드
  confirmcollection(String collectionname) async {
    result = await db.collection(collectionname).doc('connect').get();
    print(collectionname);
    print(result.data());
    if (result.data() != null) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => QuizBuzzer(
                  (controller.text + controller2.text).trim(),
                  controller3.text.trim())));
    } else {
      showSnackBar(context, Text('학교이름과 방번호를 다시 살펴보세요'));
    }
  } // 컬렉션이름 확인 메서드 끝

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Tools'),
        elevation: 0.0,
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) => test()));
            }),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {
            pdfexist = true;
          })
        ],
      ),
      // 입력하는 부분을 제외한 화면을 탭하면, 키보드 사라지게 GestureDetector 사용
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 50)),
              Center(
                child: Image(
                  image: AssetImage('images/classicon.png'),
                  width: 170.0,
                ),
              ),
              Form(
                  child: Theme(
                data: ThemeData(
                    primaryColor: Colors.grey,
                    inputDecorationTheme: InputDecorationTheme(
                        labelStyle:
                            TextStyle(color: Colors.teal, fontSize: 15.0))),
                child: Container(
                    padding: EdgeInsets.all(40.0),
                    child: Builder(builder: (context) {
                      return Column(
                        children: [
                          TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: InputDecoration(labelText: '학교이름',hintText: "대화초"),
                            keyboardType: TextInputType.text,
                          ),
                          TextField(
                            controller: controller2,
                            decoration: InputDecoration(labelText: '방번호',hintText: "1234"),
                            keyboardType: TextInputType.number,
                            // obscureText: true, // 비밀번호 안보이도록 하는 것
                          ),
                          TextField(
                            controller: controller3,
                            decoration: InputDecoration(labelText: '모둠이름',hintText: "1모둠, 본인이름 등"),
                            keyboardType: TextInputType.text,
                            // obscureText: true, // 비밀번호 안보이도록 하는 것
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          ButtonTheme(
                              minWidth: 100.0,
                              height: 50.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (controller3.text.contains("t")) {
                                    gototeacherpage(
                                        (controller.text + controller2.text)
                                            .trim());
                                  } else {
                                    confirmcollection(
                                        (controller.text + controller2.text)
                                            .trim());
                                  }
                                  /*       if (controller.text == '1' &&
                                      controller2.text == '2') {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                Producttest()));
                                  } else if (controller.text == '1' &&
                                      controller2.text != '2') {
                                    showSnackBar(
                                        context, Text('Wrong password'));
                                  } else if (controller.text != '1' &&
                                      controller2.text == '2') {
                                    showSnackBar(context, Text('Wrong email'));
                                  } else {
                                    showSnackBar(
                                        context, Text('Check your info again'));
                                  }

                           */
                                },
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 35.0,
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent),
                              ))
                        ],
                      );
                    })),
              ))
            ],
          ),
        ),
      ),
    );
  }
}

void showSnackBar(BuildContext context, Text text) {
  final snackBar = SnackBar(
    content: text,
    backgroundColor: Color.fromARGB(255, 112, 48, 48),
  );

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

//선생님페이지
class teacherPage extends StatefulWidget {
  String collectionname = '';
  String teamname = '';
  String pdfexist = '';
  teacherPage(this.collectionname, this.teamname, this.pdfexist, {Key? key}) : super(key: key);

  @override
  State<teacherPage> createState() => _teacherPageState();
}

class _teacherPageState extends State<teacherPage> {
  late CollectionReference product;
  final player = AudioPlayer();
  bool _isDialogShowing = false;


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
        title: Text('선생님 페이지'),
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              widget.pdfexist='false';
            }),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.zoom_in,
              color: Colors.white,
            ),
            onPressed: () {
              widget.pdfexist='true';
            },
          ),
        ],
      ),

      body: StreamBuilder(
        stream: product.orderBy('time', descending: false).snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if(widget.pdfexist == 'false'){
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
              appBar: AppBar(
                title: Text('뷰 테스트'),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // _pdfViewerController.zoomLevel = 0.5;
                    },
                  ),
                ],
              ),

              body:
//pdf 한페이지씩 보기
//               SfPdfViewer.asset('1.pdf', pageLayoutMode: PdfPageLayoutMode.single ),

                SfPdfViewer.network('https://pub-9c2cd5cd1ec6403eb4d2d4cc881b3049.r2.dev/1.pdf', pageLayoutMode: PdfPageLayoutMode.single),
              // SfPdfViewer.network('https://github.com/j991132/classtools/blob/master/assets/1.pdf', pageLayoutMode: PdfPageLayoutMode.single),

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
      allowedExtensions: ['txt'],
    );

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

//학생용 버튼 페이지
class QuizBuzzer extends StatefulWidget {
  String collectionname = '';
  String teamname = '';

  QuizBuzzer(this.collectionname, this.teamname, {Key? key}) : super(key: key);

  @override
  State<QuizBuzzer> createState() => _QuizBuzzerState();
}

class _QuizBuzzerState extends State<QuizBuzzer> {
  late CollectionReference product;
  var result;

  //모둠명 이름확인 메서드
  confirmteamname() async {
    result = await product.doc().get();
    print('부저페이지' + result.data().toString());
  }

  Future<void> buzzerPush(String teamname) async {
    await product.add({'teamname': teamname, 'time': Timestamp.now()});
  }

  @override
  Widget build(BuildContext context) {
    product = FirebaseFirestore.instance
        .collection('${widget.collectionname}')
        .doc('connect')
        .collection('teams');
    confirmteamname();
    return Scaffold(
        appBar: AppBar(
          title: Text('퀴즈부저'),
        ),
        body: StreamBuilder(
          stream: product.snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            List? list =
                streamSnapshot.data?.docs.map((e) => e.data()).toList();
// print('퀴즈부저스트림빌더'+list.toString());

            // final DocumentSnapshot documentSnapshot =
            // streamSnapshot.data!.docs[0];

            return Container(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                    // scrollDirection: Axis.horizontal,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      InkWell(
                        onTap: () {
                          print('퀴즈부저스트림빌더' + list.toString());
                          if (list.toString().contains('${widget.teamname}')) {
                            debugPrint('이미 모둠명 있음' + '${widget.teamname}');
                          } else {
                            buzzerPush('${widget.teamname}');
                          }
                        },
                        child: Image(
                          image: AssetImage('images/button.png'),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.9,
                          // fit: BoxFit.cover,
                        ),
                      ),

                      // return Center(child: CircularProgressIndicator());
                    ])));
          },
        ));
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
