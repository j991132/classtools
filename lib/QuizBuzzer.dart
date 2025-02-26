import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizBuzzer extends StatefulWidget {
  String collectionname = '';
  String teamname = '';

  QuizBuzzer(this.collectionname, this.teamname, {Key? key}) : super(key: key);

  @override
  State<QuizBuzzer> createState() => _QuizBuzzerState();
}

class _QuizBuzzerState extends State<QuizBuzzer> with SingleTickerProviderStateMixin {
  late CollectionReference product;
  var result;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // 탭 변경 시 화면 갱신
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('퀴즈부저'),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Theme.of(context).primaryColor, // 탭바 배경색
              child: TabBar(
                controller: _tabController,
                indicatorWeight: 4,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicator: BoxDecoration(
                  // 선택된 탭 배경색 (전체 탭 너비)
                  color: Colors.blue.shade700,
                ),
                tabs: [
                  Tab(
                    icon: Icon(Icons.touch_app),
                    text: "부저",

                  ),
                  Tab(
                    icon: Icon(Icons.check_circle_outline),
                    text: "OX퀴즈",
                  ),
                  Tab(
                    icon: Icon(Icons.format_list_numbered),
                    text: "선다형",
                  ),
                ],
              ),
            ),
          ),
        ),
        // 각 탭의 배경색을 명확하게 설정
        body: Stack(
          children: [
            // 선택된 탭에 따라 배경색 변경
            Positioned.fill(
              child: ColoredBox(
                color: _tabController.index == 0
                    ? Colors.red.shade100
                    : (_tabController.index == 1
                    ? Colors.blue.shade100
                    : Colors.green.shade100),
              ),
            ),

            // 탭 뷰
            TabBarView(
              controller: _tabController,
              children: [
                // 첫 번째 탭 - 기존 퀴즈 부저
                _buildOriginalBuzzerTab(),

                // 두 번째 탭 - OX 퀴즈
                _buildOXQuizTab(),

                // 세 번째 탭 - 선다형
                SafeArea(child: _buildMultipleChoiceTab()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 첫 번째 탭 - 원래 코드 그대로 유지
  Widget _buildOriginalBuzzerTab() {
    return Container(
        color: Colors.transparent, // 배경 투명하게 설정
        child:StreamBuilder(
      stream: product.snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        List? list =
        streamSnapshot.data?.docs.map((e) => e.data()).toList();

        return Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
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
                        ),
                      ),
                    ])));
      },
        ), );
  }

  // 두 번째 탭 - OX 퀴즈 - 완전히 수정
  Widget _buildOXQuizTab() {
    return Container(
      color: Colors.blue.shade50, // 배경색 명시적 지정
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'OX 퀴즈',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // O 버튼
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            buzzerPush('${widget.teamname} - O 선택');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade200,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'O',
                                style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // X 버튼
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            buzzerPush('${widget.teamname} - X 선택');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.shade200,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'X',
                                style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 세 번째 탭 - 선다형 - 완전히 수정
  Widget _buildMultipleChoiceTab() {
    // 화면 비율에 맞는 버튼 크기 계산
    double buttonHeight = MediaQuery.of(context).size.height * 0.25;

    return Container(
      color: Colors.green.shade50, // 배경색 명시적 지정
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '선다형 퀴즈',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 상단 행 (1, 2번)
                  Row(
                    children: [
                      _buildChoiceButtonSimple('1', Colors.blue, buttonHeight),
                      _buildChoiceButtonSimple('2', Colors.green, buttonHeight),
                    ],
                  ),
                  // 하단 행 (3, 4번)
                  Row(
                    children: [
                      _buildChoiceButtonSimple('3', Colors.orange, buttonHeight),
                      _buildChoiceButtonSimple('4', Colors.purple, buttonHeight),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 간소화된 선다형 버튼 위젯
  Widget _buildChoiceButtonSimple(String number, MaterialColor color, double height) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            buzzerPush('${widget.teamname} - ${number}번 선택');
          },
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: color.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: color.shade700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}