import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_grit/pages/VideoUploadSystem/VideoPlayerWidget.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_uploader/video_uploader.dart';
import 'package:http/http.dart' as http;

class UploadPhotoPage extends StatefulWidget {
  final String idChallenge;
  final String idGruppo;
  final String nameChallenge;

  UploadPhotoPage({required this.idChallenge, required this.idGruppo, required this.nameChallenge});

  @override
  State<UploadPhotoPage> createState() => _UploadPhotoPageState();
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  VideoPlayerController? controller;

  var photoUrl = '';

  File? _selectedPhoto;
  bool _isUploading = false;
  String? _uploadStatus;

  Future<void> _pickPhoto() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedPhoto = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking photo: $e");
    }
  }

  Future<String?> _uploadPhotoToFirebase(File photo) async {
    try {
      setState(() {
        _isUploading = true;
      });
      final fileName = '${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child('users_challenges_photo//$fileName');
      final uploadTask = storageRef.putFile(photo);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        photoUrl = downloadUrl;
      });

      return downloadUrl;
      
    } catch (e) {
      print("Error uploading photo: $e");
      setState(() {
        _isUploading = false;
      });
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  bool _showCircle = false;

  @override
  void dispose() {
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
                    child: Text("Upload Photo", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      _pickPhoto();
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
                          height: _selectedPhoto != null ? GGSize.screenHeight(context) * 0.1 : GGSize.screenHeight(context) * 0.3,
                          decoration: BoxDecoration(color: const Color.fromARGB(54, 0, 103, 238), borderRadius: BorderRadius.circular(19)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Icon(_selectedPhoto != null ? CupertinoIcons.refresh_bold : CupertinoIcons.share, color: GGColors.primaryColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Text(_selectedPhoto != null ? "Change Photo" : "Tap to Select Photo",
                                    style: TextStyle(color: GGColors.primaryColor, fontWeight: FontWeight.w600, fontSize: 16)),
                              ),
                            ],
                          )),
                    ),
                  ),
                  SizedBox(height: 20),
                  _selectedPhoto != null
                      ? Column(
                          children: [
                            if (_selectedPhoto != null)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(19),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                height: GGSize.screenHeight(context) * 0.45,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    _selectedPhoto!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              Text("No Photo selected"),
                            SizedBox(height: 30),
                          ],
                        )
                      : Text(""),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        if (_selectedPhoto != null) {
                          if (_isUploading) return;


                          setState(() {
                            _showCircle = true;
                          });


                          _uploadPhotoToFirebase(_selectedPhoto!).then((value)async {
                            

                            await FirebaseFirestore.instance.collection('users_challenges').add({
                            'userId': FirebaseAuth.instance.currentUser!.uid,
                            'groupId': widget.idGruppo,
                            'challengeId': widget.idChallenge,
                            'status': 'photo_success',
                            'excuse': null,
                            'videoUrl': null,
                            'photoUrl': value,
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
                              color: _selectedPhoto != null ? GGColors.primaryColor : GGColors.unselectedColor,
                              borderRadius: BorderRadius.circular(21)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Submit Photo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
