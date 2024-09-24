import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'QuizBuzzer.dart';
import 'TeacherPage.dart';  // 파일 이름이 TeacherPage.dart라고 가정
import 'main.dart';
import 'util.dart';

class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  bool pdfexist = false;
  var result;
  final db = FirebaseFirestore.instance;
  WebViewController? _webViewController;
  int _selectedValue = 1;

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
              builder: (BuildContext context) => TeacherPage(
                  (controller.text + controller2.text).trim(),
                  controller3.text.trim(), pdfexist.toString(),controller4.text.trim() )));
    } else if (result.data().toString().contains('ok')) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => TeacherPage(
                  (controller.text + controller2.text).trim(),
                  controller3.text.trim(), pdfexist.toString(),controller4.text.trim())));
    } else {
      showSnackBar(context, Text('학교이름과 방번호를 다시 살펴보세요'));
    }
  }

  //컬렉션 이름확인->학생용 부저페이지 이동 메서드
  confirmcollection(String collectionname) async {
    result = await db.collection(collectionname).doc('connect').get();
    print("컬렉션네임"+collectionname);
    print(result.data());
    if (result.data() != null && controller3.text.trim() !="") {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => QuizBuzzer(
                  (controller.text + controller2.text).trim(),
                  controller3.text.trim())));
    } else {
      showSnackBar(context, Text('학교이름과 방번호 또는 모둠이름을 다시 살펴보세요'));
    }
  } // 컬렉션이름 확인 메서드 끝

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Tools'),
        elevation: 0.0,
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (BuildContext context) => test()));
            }),

        actions:

        <Widget>[

          /*
          TextField(
            controller: controller3,
            decoration: InputDecoration(labelText: 'URL',hintText: "url",),
            keyboardType: TextInputType.text,),
          */


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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  Container(
                    alignment: Alignment.centerRight,
                    width: MediaQuery.of(context).size.width*0.2,

                    child: TextField(
                      controller: controller4,
                      decoration: InputDecoration(labelText: 'URL',hintText: "url",),
                      keyboardType: TextInputType.text,),
                  ),
                  IconButton(icon: Icon(Icons.picture_as_pdf_sharp), tooltip: 'PDF'
                      ,onPressed: () {
                        // pdfexist = true;
                      }
                  ),
                  Switch(value: pdfexist, onChanged: (value){
                    print(value);
                    setState(() {
                      pdfexist=value;
                    });

                  })
                ],),


              Padding(padding: EdgeInsets.only(top: 50)),
              Center(
                child: Image(
                  image: AssetImage('images/classicon.png'),
                  width: 170.0,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRadioButton('참가자', 1, isSmallScreen),
                  SizedBox(width: 10),
                  _buildRadioButton('출제자', 2, isSmallScreen),
                ],
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
                                decoration: InputDecoration(labelText: '학교이름',hintText: "(예) 대화초",hintStyle: TextStyle(
                                  color: Colors.pink,),),
                                keyboardType: TextInputType.text,
                              ),
                              TextField(
                                controller: controller2,
                                decoration: InputDecoration(labelText: '방번호',hintText: "(예) 1234",hintStyle: TextStyle(
                                  color: Colors.pink,),),
                                keyboardType: TextInputType.number,
                                // obscureText: true, // 비밀번호 안보이도록 하는 것
                              ),
                              TextField(
                                controller: controller3,
                                decoration: InputDecoration(labelText: '모둠이름',hintText: "(예) 1모둠, 본인이름 등",hintStyle: TextStyle(
                                  color: Colors.pink,),),
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
                                      if(_selectedValue == 2){
                                      // if (controller3.text.contains("t")) {
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
  Widget _buildRadioButton(String title, int value, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: value == 1 ? Colors.lightBlueAccent : Colors.tealAccent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: value == 1 ? Colors.blue : Colors.teal,
            width: 2
        ),
      ),
      width: isSmallScreen ? 80 : 120,
      height: isSmallScreen ? 80 : 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Radio<int>(
            value: value,
            groupValue: _selectedValue,
            onChanged: (int? newValue) {
              setState(() {
                _selectedValue = newValue!;
              });
            },
            activeColor: Colors.red,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}