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

class ViewPhotoPage extends StatefulWidget {
  final String photoUrl;

  ViewPhotoPage({required this.photoUrl});

  @override
  State<ViewPhotoPage> createState() => _ViewPhotoPageState();
}

class _ViewPhotoPageState extends State<ViewPhotoPage> {
  VideoPlayerController? controller;

  var photoUrl = '';

  File? _selectedPhoto;


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
                  'Photo',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                
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
                  
              
                  SizedBox(height: 20),
                  Column(
                          children: [
                           
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
                                  child: Image.network(
                                    widget.photoUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            
                            SizedBox(height: 30),
                          ],
                        )
                  
                ],
              ),
            ),
          )),
    );
  }
}
