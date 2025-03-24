import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:group_grit/widget/button_widget.dart';
import 'package:group_grit/widget/profile_widget.dart';
import 'package:group_grit/widget/textfield_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  EditProfilePage({required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String newName = '';
  String newEmail = '';
  String newPhotoUrl = '';
  bool _showCircle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GGColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: GGColors.backgroundColor,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 32),
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            imagePath: newPhotoUrl == '' ? widget.user['photo_url'] ?? '' : newPhotoUrl,
            isEdit: true,
            onClicked: () async {
              final image = await ImagePicker().pickImage(source: ImageSource.gallery);

              if (image == null) return;

              final directory = await getApplicationDocumentsDirectory();
              final name = basename(image.path);
              final imageFile = File('${directory.path}/$name');
              final newImage = await File(image.path).copy(imageFile.path);

              setState(() => widget.user['photo_url'] = newImage.path);
              // Upload the image to Firebase Storage

              await FirebaseStorage.instance.ref().child('user_photos/${FirebaseAuth.instance.currentUser!.uid}/profilePage').putFile(newImage);
              // Get the download URL of the uploaded image
              final photoUrl = await FirebaseStorage.instance
                  .ref()
                  .child('user_photos/${FirebaseAuth.instance.currentUser!.uid}/profilePage')
                  .getDownloadURL()
                  .then((value) async {
                setState(() => {
                      newPhotoUrl = value,
                      widget.user['photo_url'] = value,
                    });
              });

              await FirebaseAuth.instance.currentUser?.updatePhotoURL(newPhotoUrl);

              FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                'photo_url': newPhotoUrl == '' ? widget.user['photo_url'] : newPhotoUrl,
              });

              // Update the user's photo URL in Firestore
              //await FirebaseFirestore.instance.collection('users').doc(widget.user['id']).update({'photo_url': photoUrl});

              // Update the local user object
            },
          ),
          const SizedBox(height: 24),
          TextFieldWidget(
            label: 'Full Name',
            text: widget.user['display_name'],
            onChanged: (name) {
              setState(() {
                newName = name;
              });
            },
          ),
          const SizedBox(height: 24),
          TextFieldWidget(
            label: 'Email',
            text: widget.user['email'],
            onChanged: (email) {
              setState(() {
                newEmail = email;
              });
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                setState(() {
                  _showCircle = true;
                });
                FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                  'display_name': newName == '' ? widget.user['display_name'] : newName,
                  'email': newEmail == '' ? widget.user['email'] : newEmail,
                  'photo_url': newPhotoUrl == '' ? widget.user['photo_url'] : newPhotoUrl,
                });
                await FirebaseAuth.instance.currentUser?.updatePhotoURL(newPhotoUrl);
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    _showCircle = false;
                  });
                  Navigator.of(context).pop('true');
                });
              },
              child: Container(
                  width: GGSize.screenWidth(context),
                  height: GGSize.screenHeight(context) * 0.05,
                  decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(19)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(width: 10),
                      Visibility(
                          visible: _showCircle,
                          child: SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ))),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
