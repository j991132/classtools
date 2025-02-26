import 'dart:async';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/foundation.dart';

class TeacherPage extends StatefulWidget {
  final String collectionName;
  final String teamName;
  final String pdfExists;
  final String url;

  const TeacherPage(this.collectionName, this.teamName, this.pdfExists, this.url, {Key? key}) : super(key: key);

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}



class _TeacherPageState extends State<TeacherPage> {
  late CollectionReference _teamsCollection;
  final AudioPlayer _player = AudioPlayer();
  final GlobalKey<_ResultDialogState> _dialogKey = GlobalKey<_ResultDialogState>();
  bool _isDialogShowing = false;
  late Timer? _popupTimer;
  late PlatformFile _resultFile;
  bool _showPdf = false;
  bool _hasShownFirstTeam = false;
  late PdfViewerController _pdfViewerController;
  int _dialogDisplayTime = 3; // 기본값 3초
  List<int> _displayTimeOptions = [0, 1, 3, 5, 7, 10]; // 0은 '닫기버튼'을 의미
  int _selectedBuzzerSound = 1; // 기본값은 1번 부저음
  List<String> _buzzerSoundOptions = ['부저1', '부저2', '부저3']; // 효과음 옵션
  List<String> _buzzerSoundFiles = ['buzzer.wav', 'buzzer2.wav', 'buzzer3.wav']; // 효과음 파일명

  @override
  void initState() {
    super.initState();
    _teamsCollection = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc('connect')
        .collection('teams');
    _initAudioPlayer();
    _pdfViewerController = PdfViewerController();
    _popupTimer = null;
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _player.setAsset(_buzzerSoundFiles[_selectedBuzzerSound - 1]);
    } catch (e) {
      print("오디오 파일 로드 실패: $e");
    }
  }

  // 효과음 변경 메서드 추가
  Future<void> _changeBuzzerSound(int soundIndex) async {
    try {
      _selectedBuzzerSound = soundIndex;
      // 'assets/' 접두사 제거
      await _player.setAsset(_buzzerSoundFiles[_selectedBuzzerSound - 1]);
    } catch (e) {
      print("효과음 변경 실패: $e");
    }
  }


  Future<void> _playEffectAudio() async {
    try {
      await _player.stop();
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      print("효과음 재생 실패: $e");
    }
  }

  void _showPopup(BuildContext context, String teamName, {List<QueryDocumentSnapshot>? documents}) {
    if (_isDialogShowing || _hasShownFirstTeam) return;

    setState(() {
      _isDialogShowing = true;
      _hasShownFirstTeam = true;
    });
    _playEffectAudio();

    // 디버깅을 위한 로그 추가
    print("_showPopup 호출됨. 문서 수: ${documents?.length ?? 0}");

    // 2등과 3등 정보를 준비합니다
    String secondTeamName = "";
    String secondTimeDiff = "";
    String thirdTeamName = "";
    String thirdTimeDiff = "";

    if (documents != null && documents.length > 1) {
      // 첫 번째 문서의 시간을 기준 시간으로 설정
      final Timestamp firstTime = documents[0]['time'] as Timestamp;

      // 2등 정보 설정
      final Timestamp secondTime = documents[1]['time'] as Timestamp;
      final int timeDifference = secondTime.millisecondsSinceEpoch - firstTime.millisecondsSinceEpoch;
      secondTeamName = documents[1]['teamname'] as String;
      secondTimeDiff = "+${(timeDifference / 1000.0).toStringAsFixed(2)}초";

      print("2등: $secondTeamName, 시간차: $secondTimeDiff");

      // 3등 정보 설정
      if (documents.length > 2) {
        final Timestamp thirdTime = documents[2]['time'] as Timestamp;
        final int timeDifference = thirdTime.millisecondsSinceEpoch - firstTime.millisecondsSinceEpoch;
        thirdTeamName = documents[2]['teamname'] as String;
        thirdTimeDiff = "+${(timeDifference / 1000.0).toStringAsFixed(2)}초";

        print("3등: $thirdTeamName, 시간차: $thirdTimeDiff");
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 5,
                  child: Center(
                    child: AutoSizeText(
                      teamName,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      maxFontSize: 500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 2등 정보 박스 - 항상 Row는 생성하되, 내용이 없으면 빈 공간으로
                      if (secondTeamName.isNotEmpty)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "2등",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  secondTeamName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  secondTimeDiff,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(child: SizedBox()), // 2등이 없으면 빈 공간

                      // 3등 정보 박스
                      if (thirdTeamName.isNotEmpty)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "3등",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  thirdTeamName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  thirdTimeDiff,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(child: SizedBox()), // 3등이 없으면 빈 공간
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _closePopupAndDeleteAll(context),
                  icon: const Icon(Icons.close),
                  label: const Text('닫기'),
                )
              ],
            ),
          ),
        );
      },
    ).then((_) => setState(() => _isDialogShowing = false));

    Timer(const Duration(seconds: 3), () => _closePopupAndDeleteAll(context));
  }

  void _closePopupAndDeleteAll(BuildContext context) {
    if (_isDialogShowing && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    if (_popupTimer != null) {
      _popupTimer!.cancel();
      _popupTimer = null;
    }
    _deleteAllTeams();
    setState(() {
      _isDialogShowing = false;
    });
  }

  // _deleteAllTeams 메서드가 로그인 화면으로 돌아가지 않도록 수정
  Future<void> _deleteAllTeams() async {
    try {
      final QuerySnapshot snapshot = await _teamsCollection.get();
      final List<Future<void>> deleteFutures = snapshot.docs
          .map((doc) => _teamsCollection.doc(doc.id).delete())
          .toList();
      await Future.wait(deleteFutures);
      setState(() {
        _hasShownFirstTeam = false;
      });
    } catch (e) {
      print("팀 데이터 삭제 중 오류 발생: $e");
    }
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        _resultFile = result.files.first;
        setState(() {

          _showPdf = true;
        });
      }
    } catch (e) {
      print("PDF 파일 선택 중 오류 발생: $e");
    }
  }

  // 설정 다이얼로그를 표시하는 메서드 추가
  void _showSettingsDialog() {
    // 현재 설정값을 임시 변수에 저장
    int tempDisplayTime = _dialogDisplayTime;
    int tempBuzzerSound = _selectedBuzzerSound;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('설정'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 다이얼로그 표시 시간 설정
                    Text('다이얼로그 표시 시간:'),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButton<int>(
                        isExpanded: true,
                        underline: SizedBox(), // 기본 밑줄 제거
                        value: tempDisplayTime,
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              tempDisplayTime = newValue;
                            });
                          }
                        },
                        items: _displayTimeOptions.map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value == 0 ? '닫기버튼' : '$value초'),
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: 20),

                    // 효과음 설정
                    Text('효과음 선택:'),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButton<int>(
                        isExpanded: true,
                        underline: SizedBox(), // 기본 밑줄 제거
                        value: tempBuzzerSound,
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              tempBuzzerSound = newValue;
                            });
                          }
                        },
                        items: [1, 2, 3].map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(_buzzerSoundOptions[value - 1]),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      // 설정값 적용
                      this.setState(() {
                        _dialogDisplayTime = tempDisplayTime;
                      });
                      // 효과음 변경
                      if (_selectedBuzzerSound != tempBuzzerSound) {
                        _changeBuzzerSound(tempBuzzerSound);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text('확인'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
        focusNode: FocusNode(),
    autofocus: true,
    onKey: (RawKeyEvent event) {
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.pageDown ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          _pdfViewerController.nextPage();
        } else if (event.logicalKey == LogicalKeyboardKey.pageUp ||
            event.logicalKey == LogicalKeyboardKey.backspace) {
          _pdfViewerController.previousPage();
        }
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('QUIZ? 퀴즈!'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '설정',
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF 선택',
            onPressed: _pickPdfFile,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _teamsCollection.orderBy('time', descending: false).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = List<QueryDocumentSnapshot>.from(snapshot.data!.docs);

          // 확인용 로그 추가
          print("문서 개수: ${docs.length}");
          if (docs.isNotEmpty) {
            for (int i = 0; i < docs.length; i++) {
              print("팀 ${i+1}: ${docs[i]['teamname']}");
            }
          }

          // 첫 번째 팀이 등록되었을 때만 다이얼로그 표시
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (docs.isNotEmpty) {
              if (!_isDialogShowing && !_hasShownFirstTeam) {
                // 처음으로 팀이 등록되었을 때 다이얼로그 표시
                _showResultDialog(context, docs);
              } else if (_isDialogShowing && _dialogKey.currentState != null) {
                // 다이얼로그가 이미 표시 중이면 데이터만 업데이트
                _dialogKey.currentState!.updateTeams(docs);
              }
            }
          });

          if(widget.pdfExists == 'false' && _showPdf == false){
            return _buildTeamList(docs);
          } else if(_showPdf) {
            return SfPdfViewer.memory(_resultFile!.bytes!, pageLayoutMode: PdfPageLayoutMode.single,
                controller: _pdfViewerController);
          } else if (widget.pdfExists == 'true') {
            return SfPdfViewer.network(widget.url, pageLayoutMode: PdfPageLayoutMode.single,
                controller: _pdfViewerController);
          }
          else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }
          else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (!snapshot.hasData || docs.isEmpty) {
            return const SizedBox.shrink();
          }else {
            return _buildTeamList(docs);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _deleteAllTeams,
        child: const Icon(Icons.close),
      ),
    ),
    );

  }

  // StatefulWidget 다이얼로그 정의
  void _showResultDialog(BuildContext context, List<QueryDocumentSnapshot> documents) {
    _playEffectAudio();
    setState(() {
      _isDialogShowing = true;
      _hasShownFirstTeam = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ResultDialog(
          key: _dialogKey,
          teams: documents,
          onClose: () {
            Navigator.of(dialogContext).pop();
            _deleteAllTeams(); // 닫기 버튼을 누르면 항상 팀 데이터 삭제
            setState(() {
              _isDialogShowing = false;
            });
          },
        );
      },
    ).then((_) {
      setState(() {
        _isDialogShowing = false;
      });
    });

    // 선택된 표시 시간이 0이 아닌 경우에만 타이머 설정
    if (_dialogDisplayTime > 0) {
      _popupTimer = Timer(Duration(seconds: _dialogDisplayTime), () {
        if (_isDialogShowing && Navigator.canPop(context)) {
          Navigator.of(context).pop();
          _deleteAllTeams(); // 타이머로 닫힐 때도 팀 데이터 삭제
          setState(() {
            _isDialogShowing = false;
          });
        }
        if (_popupTimer != null) {
          _popupTimer!.cancel();
          _popupTimer = null;
        }
      });
    }
  }

  Widget _buildPdfViewer() {
    return SfPdfViewer.memory(_resultFile!.bytes!, pageLayoutMode: PdfPageLayoutMode.single);
  }

  Widget _buildTeamList(List<QueryDocumentSnapshot> documents) {
    if (documents.isEmpty) {
      return const Center(child: Text('팀 목록이 없습니다.'));
    }
    // 시간 순으로 오름차순 정렬 (가장 빠른 것이 먼저)
    documents.sort((a, b) => (a['time'] as Timestamp).compareTo(b['time'] as Timestamp));

    // 첫 번째 문서의 시간을 기준 시간으로 설정
    final Timestamp baseTime = documents.first['time'] as Timestamp;

    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final DocumentSnapshot document = documents[index];
        final Timestamp currentTime = document['time'] as Timestamp;

        // 기준 시간과의 차이 계산 (밀리초 단위)
        final int timeDifference = currentTime.millisecondsSinceEpoch - baseTime.millisecondsSinceEpoch;

        // 시간 차이를 초 단위로 변환하고 소수점 둘째 자리까지 표시
        final String timeDifferenceString = (timeDifference / 1000.0).toStringAsFixed(2);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(document['teamname'] as String),
            // subtitle: Text(index == 0 ? '첫 번째 응답' : '+$timeDifferenceString초'),
            trailing: const SizedBox(width: 100),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (_popupTimer != null) {
      _popupTimer!.cancel();
    }
    _player.dispose();
    super.dispose();
  }
}

// StatefulWidget 다이얼로그 클래스 추가 (TeacherPage 클래스 외부에 추가)
class ResultDialog extends StatefulWidget {
  final List<QueryDocumentSnapshot> teams;
  final VoidCallback onClose;

  const ResultDialog({Key? key, required this.teams, required this.onClose}) : super(key: key);

  @override
  _ResultDialogState createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog> {
  late List<QueryDocumentSnapshot> _teams;

  @override
  void initState() {
    super.initState();
    _teams = widget.teams;
  }

  // 팀 데이터 업데이트 메서드
  void updateTeams(List<QueryDocumentSnapshot> teams) {
    setState(() {
      _teams = teams;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1등 팀 정보
    String firstTeamName = _teams[0]['teamname'] as String;

    // 2등과 3등 정보
    String secondTeamName = "";
    String secondTimeDiff = "";
    String thirdTeamName = "";
    String thirdTimeDiff = "";

    // 첫 번째 문서의 시간을 기준 시간으로 설정
    final Timestamp firstTime = _teams[0]['time'] as Timestamp;

    // 2등 정보 설정 (문서가 2개 이상일 때)
    if (_teams.length > 1) {
      final Timestamp secondTime = _teams[1]['time'] as Timestamp;
      final int timeDifference = secondTime.millisecondsSinceEpoch - firstTime.millisecondsSinceEpoch;
      secondTeamName = _teams[1]['teamname'] as String;
      secondTimeDiff = "+${(timeDifference / 1000.0).toStringAsFixed(2)}초";
    }

    // 3등 정보 설정 (문서가 3개 이상일 때)
    if (_teams.length > 2) {
      final Timestamp thirdTime = _teams[2]['time'] as Timestamp;
      final int timeDifference = thirdTime.millisecondsSinceEpoch - firstTime.millisecondsSinceEpoch;
      thirdTeamName = _teams[2]['teamname'] as String;
      thirdTimeDiff = "+${(timeDifference / 1000.0).toStringAsFixed(2)}초";
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              flex: 5,
              child: Center(
                child: AutoSizeText(
                  firstTeamName,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  maxFontSize: 500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 2등 정보 박스
                  if (secondTeamName.isNotEmpty)
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.08, // 높이 고정
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 왼쪽: "2등" 텍스트
                            Container(
                              width: 40, // 고정 너비
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "2등",
                                style: TextStyle(
                                  fontSize: 16, // 더 큰 고정 크기
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),

                            // 중앙: 팀 이름
                            Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    secondTeamName,
                                    style: TextStyle(
                                      fontSize: 100, // 매우 큰 기본 크기 설정
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            // 오른쪽: 시간차
                            Container(
                              width: 70, // 고정 너비
                              margin: EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                secondTimeDiff,
                                style: TextStyle(
                                  fontSize: 16, // 더 큰 고정 크기
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(child: SizedBox()),

                  // 3등 정보 박스
                  if (thirdTeamName.isNotEmpty)
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.08, // 높이 고정
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 왼쪽: "3등" 텍스트
                            Container(
                              width: 40, // 고정 너비
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "3등",
                                style: TextStyle(
                                  fontSize: 16, // 더 큰 고정 크기
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),

                            // 중앙: 팀 이름
                            Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    thirdTeamName,
                                    style: TextStyle(
                                      fontSize: 100, // 매우 큰 기본 크기 설정
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            // 오른쪽: 시간차
                            Container(
                              width: 70, // 고정 너비
                              margin: EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                thirdTimeDiff,
                                style: TextStyle(
                                  fontSize: 16, // 더 큰 고정 크기
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(child: SizedBox()),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close),
              label: const Text('닫기'),
            )
          ],
        ),
      ),
    );
  }
}