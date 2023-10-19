import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:auto_size_text/auto_size_text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 에러방지 코딩셰프 매운맛 26강 참고
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

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
  var result;
  final db = FirebaseFirestore.instance;

  //컬렉션 이름확인 메서드
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
        leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {})
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
                            decoration: InputDecoration(labelText: '학교이름'),
                            keyboardType: TextInputType.text,
                          ),
                          TextField(
                            controller: controller2,
                            decoration: InputDecoration(labelText: '방번호'),
                            keyboardType: TextInputType.number,
                            // obscureText: true, // 비밀번호 안보이도록 하는 것
                          ),
                          TextField(
                            controller: controller3,
                            decoration: InputDecoration(labelText: '모둠이름'),
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                teacherPage(
                                                    controller.text +
                                                        controller2.text,
                                                    controller3.text)));
                                  } else {
                                    confirmcollection(
                                        controller.text + controller2.text);
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

void showPopup(context, String teamname) {
  showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AutoSizeText(
                teamname,
                style: TextStyle(fontSize: 100, color: Colors.redAccent, fontWeight: FontWeight.bold),

                // Set minFontSize as 18
                maxFontSize: 200,

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
}

class teacherPage extends StatefulWidget {
  String collectionname = '';
  String teamname = '';

  teacherPage(this.collectionname, this.teamname, {Key? key}) : super(key: key);

  @override
  State<teacherPage> createState() => _teacherPageState();
}

class _teacherPageState extends State<teacherPage> {
  late CollectionReference product;

  @override
  Widget build(BuildContext context) {
    product = FirebaseFirestore.instance
        .collection('${widget.collectionname}')
        .doc('connect')
        .collection('teams');
    return Scaffold(
      appBar: AppBar(
        title: Text('선생님 페이지'),
      ),
      body: StreamBuilder(
        stream: product.orderBy('time', descending: false).snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                if(streamSnapshot.data!.docs.length == 1){
                  //아래 콜백은 무조건 빌드가 끝난다음에 실행될 수 있도록 하는 장치 - 이게 없으면 빌드가 안끝났는데 팝업을 빌드하려고 해서 에러가 난다
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    showPopup(context,
                        streamSnapshot.data!.docs[0]['teamname']);
                  });
                }
                else {
                    debugPrint('인덱스 번호' +
                        index.toString() +
                        '텍스트내용' +
                        documentSnapshot['teamname']);
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
                showPopup(context, documentSnapshot['teamname'].toString());
              },

            );

          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class QuizBuzzer extends StatefulWidget {
  String collectionname = '';
  String teamname = '';

  QuizBuzzer(this.collectionname, this.teamname, {Key? key}) : super(key: key);

  @override
  State<QuizBuzzer> createState() => _QuizBuzzerState();
}

class _QuizBuzzerState extends State<QuizBuzzer> {
  late CollectionReference product;

  Future<void> buzzerPush(String teamname) async {
    await product.add({'teamname': teamname, 'time': Timestamp.now()});
  }


  @override
  Widget build(BuildContext context) {
    product = FirebaseFirestore.instance
        .collection('${widget.collectionname}')
        .doc('connect')
        .collection('teams');
    return Scaffold(
      appBar: AppBar(
        title: Text('퀴즈부저'),
      ),
      // body: StreamBuilder(
      //   stream: product.snapshots(),
      //   builder: (BuildContext context,
      //       AsyncSnapshot<QuerySnapshot> streamSnapshot) {
      //
      //     return Center(child: CircularProgressIndicator());
      //   },
      // ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
            onTap: (){
      buzzerPush('${widget.teamname}');
      },
        child: Image(
          image: AssetImage('images/button.png'),
          width: 170.0,
        ),
            )],
        )




        ),


    );
  }
}

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
