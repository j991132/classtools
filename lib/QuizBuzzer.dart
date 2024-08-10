//학생용 버튼 페이지
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
