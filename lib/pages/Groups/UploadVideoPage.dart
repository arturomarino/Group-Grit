import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_grit/pages/VideoUploadSystem/VideoPlayerWidget.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:video_player/video_player.dart';
import 'package:video_uploader/video_uploader.dart';
import 'package:http/http.dart' as http;

class UploadVideoPage extends StatefulWidget {
  final String idChallenge;
  final String idGruppo;
  final String nameChallenge;

  UploadVideoPage({required this.idChallenge, required this.idGruppo, required this.nameChallenge});

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  VideoPlayerController? controller;

  var newVideoUrl = '';

  File? _selectedVideo;
  bool _isUploading = false;
  String? _uploadStatus;

  // API Key di api.video
  final String apiKey = "$API";

  @override
  void initState() {
    super.initState();
  }

  // Seleziona un video dalla galleria
  Future<File?> pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video, // Limita ai soli video
    );
    if (result == null) return null;

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
        _uploadStatus = null;
      });
      return File(result.files.single.path!);
    }
  }

  // Carica il video su api.video
  Future<void> uploadVideo() async {
    if (_selectedVideo == null) {
      setState(() {
        _uploadStatus = "No video selected";
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = null;
    });

    // Endpoint corretto
    final String uploadUrl = "https://ws..video/videos";

    try {
      // 1. Crea un nuovo video su api.video
      final response = await http.post(
        Uri.parse("https://ws.api.video/videos"),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "title":
              "videoFrom_${FirebaseAuth.instance.currentUser!.uid}_inGroup_${widget.idGruppo}_forChallenge_${widget.idChallenge}_${DateTime.now()}",
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String sourceUrl = "https://ws.api.video" + data['source']['uri'];

        // 2. Carica il file video al link fornito
        final uploadRequest = http.MultipartRequest("POST", Uri.parse(sourceUrl));
        uploadRequest.headers['Authorization'] = 'Bearer $apiKey';
        uploadRequest.files.add(
          await http.MultipartFile.fromPath('file', _selectedVideo!.path),
        );

        final uploadResponse = await uploadRequest.send();
        if (uploadResponse.statusCode == 201) {
          final responseBody = await uploadResponse.stream.bytesToString();
          final uploadData = jsonDecode(responseBody);
          final videoUrl = uploadData['assets']['mp4'];

          setState(() {
            _uploadStatus = "Video uploaded successfully! URL: $videoUrl";
            newVideoUrl = videoUrl;
          });
          print(_uploadStatus);
        } else {
          setState(() {
            _uploadStatus = "Error loading video. Status: ${uploadResponse.statusCode}";
          });
        }
      } else {
        setState(() {
          _uploadStatus = "Error creating video: ${response.body}";
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _uploadStatus = "Error: $e";
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  bool _showCircle = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showCircle,
      child: Scaffold(
          backgroundColor: GGColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: GGColors.backgroundColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.nameChallenge}',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Visibility(
                    visible: (controller != null && controller!.value.isInitialized) ? true : false,
                    child: CupertinoButton(
                      onPressed: () {
                        // Add functionality to speed up video playback
                        if (controller != null && controller!.value.isInitialized) {
                          final currentSpeed = controller!.value.playbackSpeed;
                          final newSpeed = currentSpeed == 1.0
                              ? 1.5
                              : currentSpeed == 1.5
                                  ? 2.0
                                  : currentSpeed == 2.0
                                      ? 5.0
                                      : 1.0;
                          controller!.setPlaybackSpeed(newSpeed);
                        }
                      },
                      padding: EdgeInsets.zero,
                      child: Text(
                        (controller != null && controller!.value.isInitialized) ? "${controller!.value.playbackSpeed}x" : "",
                        style: TextStyle(color: GGColors.primarytextColor, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child:
                        Text("Upload video", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      if (controller != null) {
                        controller!.dispose(); // 🔥 Free controller
                        setState(() {
                          controller = null; // 🔥 Remove video from UI
                        });
                      }
                      final file = await pickVideoFile();
                      if (file == null) return null;

                      controller = VideoPlayerController.file(file)
                        ..addListener(() {
                          if (mounted) {
                            setState(() {}); // ✅ Verify that widget is until in the UI
                          }
                        })
                        ..setLooping(true)
                        ..initialize().then((_) {
                          if (mounted) {
                            controller!.play();
                          }
                        });
                    },
                    child: DottedBorder(
                      padding: EdgeInsets.zero,
                      dashPattern: [7, 7],
                      borderType: BorderType.RRect,
                      radius: Radius.circular(19),
                      color: GGColors.primaryColor,
                      strokeWidth: 1,
                      child: Container(
                          width: GGSize.screenWidth(context),
                          height: _selectedVideo != null ? GGSize.screenHeight(context) * 0.08 : GGSize.screenHeight(context) * 0.5,
                          decoration: BoxDecoration(color: const Color.fromARGB(54, 0, 103, 238), borderRadius: BorderRadius.circular(19)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Icon(_selectedVideo != null ? CupertinoIcons.refresh_bold : CupertinoIcons.share, color: GGColors.primaryColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Text(_selectedVideo != null && controller != null ? "Change Video" : "Tap to Select Video",
                                    style: TextStyle(color: GGColors.primaryColor, fontWeight: FontWeight.w600, fontSize: 16)),
                              ),
                            ],
                          )),
                    ),
                  ),
                  SizedBox(height: 20),
                  _selectedVideo != null
                      ? Column(
                          children: [
                            if (_selectedVideo != null && controller != null)
                              Container(
                                height: GGSize.screenHeight(context) * 0.45,
                                child:
                                    controller != null && controller!.value.isInitialized ? BasicOverlayWidget(controller: controller!) : Container(),
                              )
                            else
                              Text("No video selected"),
                            SizedBox(height: 30),
                          ],
                        )
                      : Text(""),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        if (_selectedVideo != null) {
                          if (_isUploading) return;

                          setState(() {
                            _showCircle = true;
                          });
                          uploadVideo().then((_) async {
                            await FirebaseFirestore.instance.collection('users_challenges').add({
                              'userId': FirebaseAuth.instance.currentUser!.uid,
                              'groupId': widget.idGruppo,
                              'challengeId': widget.idChallenge,
                              'status': 'video_success',
                              'excuse': null,
                              'videoUrl': newVideoUrl,
                              'time': DateTime.now(),
                            });

                            final docRef = FirebaseFirestore.instance
                                .collection('users_rankings')
                                .doc('${FirebaseAuth.instance.currentUser!.uid}_${widget.idGruppo}');
                            final docSnapshot = await docRef.get();

                            if (docSnapshot.exists) {
                              docRef.update({
                                "completedChallenges": FieldValue.increment(1), // Challenge totali completate
                                "streak": FieldValue.increment(1), // Numero di challenge completate di fila senza scuse
                              });
                            } else {
                              docRef.set({
                                "userId": FirebaseAuth.instance.currentUser!.uid,
                                "groupId": widget.idGruppo,
                                "completedChallenges": 1, // Prima challenge completata
                                "streak": 1, // Prima challenge completata di fila senza scuse
                              });
                            }

                            setState(() {
                              _showCircle = false;
                            });
                            Navigator.pop(context, true);
                          });
                        }
                      },
                      child: Container(
                          width: GGSize.screenWidth(context),
                          height: GGSize.screenHeight(context) * 0.065,
                          decoration: BoxDecoration(
                              color: _selectedVideo != null ? GGColors.primaryColor : GGColors.unselectedColor,
                              borderRadius: BorderRadius.circular(21)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Submit Video", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              SizedBox(width: 10),
                              Visibility(
                                  visible: _showCircle,
                                  child: SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )))
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
