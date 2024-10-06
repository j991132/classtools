import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  bool _isDialogShowing = false;
  late PlatformFile _resultFile;
  bool _showPdf = false;
  bool _hasShownFirstTeam = false;

  @override
  void initState() {
    super.initState();
    _teamsCollection = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc('connect')
        .collection('teams');
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _player.setAsset("assets/buzzer.wav");
    } catch (e) {
      print("오디오 파일 로드 실패: $e");
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

  void _showPopup(BuildContext context, String teamName) {
    if (_isDialogShowing || _hasShownFirstTeam) return;

    setState(() {
      _isDialogShowing = true;
      _hasShownFirstTeam = true;
    });
    _playEffectAudio();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.6,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AutoSizeText(
                  teamName,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    if (_isDialogShowing) {
      Navigator.of(context).pop();
      _deleteAllTeams();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QUIZ? 퀴즈!'),
        actions: <Widget>[
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDialogShowing && !_hasShownFirstTeam && snapshot.data!.docs.isNotEmpty) {
              _showPopup(context, snapshot.data!.docs[0]['teamname'] as String);
            }
          });
          if(widget.pdfExists == 'false' && _showPdf == false){
            return _buildTeamList(snapshot.data!.docs);

          }else if(_showPdf) {
            return SfPdfViewer.memory(_resultFile!.bytes!, pageLayoutMode: PdfPageLayoutMode.single);
          } else if (widget.pdfExists == 'true') {
            return SfPdfViewer.network(widget.url, pageLayoutMode: PdfPageLayoutMode.single);
          }
          else if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }

          else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const SizedBox.shrink();
          }else {return _buildTeamList(snapshot.data!.docs);}




        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _deleteAllTeams,
        child: const Icon(Icons.close),
      ),
    );
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
    _player.dispose();
    super.dispose();
  }
}