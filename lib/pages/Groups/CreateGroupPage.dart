import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:group_grit/utils/functions/AnalyticsEngine.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupDescriptionController = TextEditingController();
  bool private = true;
  String _groupName = '';
  String _groupDescription = '';
  String privacyDropdownValue = 'Private';
  String rulesDropDownValue = 'Missing 2 Challenges in a row';

  XFile? _image;

  bool _showCircle = false;

  Future<String> generateUniqueGroupId() async {
    final uuid = Uuid();
    String groupId = '';

    final firestore = FirebaseFirestore.instance;

    bool isUnique = false;

    while (!isUnique) {
      // Genera un nuovo codice
      groupId = uuid.v4().substring(0, 8).toUpperCase();

      // Controlla se esiste già un documento con questo codice
      final querySnapshot = await firestore
          .collection('groups') // Sostituisci 'groups' con il nome della tua collezione
          .where('id', isEqualTo: groupId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        isUnique = true; // Il codice è unico
      }
    }

    return groupId;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GGColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: GGColors.backgroundColor,
          title: Text(
            'Create Group',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Text("Group Name", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                    TextFormField(
                      controller: _groupNameController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: GGColors.primarytextColor),
                      decoration: InputDecoration(
                        hintText: "Group Grit",
                        hintStyle: TextStyle(color: Color.fromARGB(170, 82, 82, 82), fontWeight: FontWeight.w500),
                        filled: true,
                        fillColor: GGColors.buttonColor,
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.primaryColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.TextFieldColor, width: 0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.primaryColor, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a group name';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Text("Group Description", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                    TextFormField(
                      controller: _groupDescriptionController,
                      keyboardType: TextInputType.text,
                      minLines: 4,
                      maxLines: 6,
                      style: TextStyle(color: GGColors.primarytextColor),
                      decoration: InputDecoration(
                        hintText: "Group Grit is a group for...",
                        hintStyle: TextStyle(color: Color.fromARGB(170, 82, 82, 82), fontWeight: FontWeight.w500),
                        filled: true,
                        fillColor: GGColors.buttonColor,
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.primaryColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.TextFieldColor, width: 0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.primaryColor, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a description';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 7),
                      child: Row(
                        children: [
                          Text("Group Type", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      child: Container(
                        height: GGSize.screenHeight(context) * 0.058,
                        width: GGSize.screenWidth(context),
                        decoration: BoxDecoration(
                          color: GGColors.buttonColor,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: Center(
                            child: Row(
                              children: [
                                Container(
                                  width: GGSize.screenWidth(context) * 0.8,
                                  child: DropdownButton<String>(
                                    borderRadius: BorderRadius.circular(19),
                                    dropdownColor: const Color.fromRGBO(181, 213, 255, 1),
                                    isExpanded: true,
                                    value: privacyDropdownValue,
                                    elevation: 16,
                                    iconEnabledColor: Colors.transparent,
                                    style: TextStyle(color: GGColors.primarytextColor, fontWeight: FontWeight.w700, fontSize: 15),
                                    underline: Container(
                                      height: 0,
                                      color: const Color.fromARGB(255, 155, 198, 255),
                                    ),
                                    onChanged: (String? newValue) {
                                      if (newValue == 'Private') {
                                        private = true;
                                      } else {
                                        private = false;
                                      }
                                      setState(() {
                                        privacyDropdownValue = newValue!;
                                      });
                                    },
                                    items: <String>['Private', 'Public'].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 7),
                      child: Row(
                        children: [
                          Text("Upload Validation Rules",
                              style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      height: GGSize.screenHeight(context) * 0.058,
                      width: GGSize.screenWidth(context),
                      decoration: BoxDecoration(
                        color: GGColors.buttonColor,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Center(
                          child: Row(
                            children: [
                              Container(
                                  width: GGSize.screenWidth(context) * 0.8,
                                  child: Text(
                                    'Auto-accept',
                                    style: TextStyle(color: GGColors.primarytextColor, fontWeight: FontWeight.w700, fontSize: 15),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 7),
                      child: Row(
                        children: [
                          Text("Auto-kick Rules", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      child: Container(
                        height: GGSize.screenHeight(context) * 0.058,
                        width: GGSize.screenWidth(context),
                        decoration: BoxDecoration(
                          color: GGColors.buttonColor,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: Center(
                            child: Row(
                              children: [
                                Container(
                                  width: GGSize.screenWidth(context) * 0.8,
                                  child: DropdownButton<String>(
                                    borderRadius: BorderRadius.circular(19),
                                    dropdownColor: const Color.fromRGBO(181, 213, 255, 1),
                                    isExpanded: true,
                                    value: rulesDropDownValue,
                                    elevation: 16,
                                    iconEnabledColor: Colors.transparent,
                                    style: TextStyle(color: GGColors.primarytextColor, fontWeight: FontWeight.w700, fontSize: 15),
                                    underline: Container(
                                      height: 0,
                                      color: const Color.fromARGB(255, 155, 198, 255),
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        rulesDropDownValue = newValue!;
                                      });
                                    },
                                    items: <String>['Missing 2 Challenges in a row', 'Another Rules'].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Text("Add group image (optional)",
                              style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        final image = await ImagePicker().pickImage(source: ImageSource.gallery);

                        if (image == null) return;

                        final directory = await getApplicationDocumentsDirectory();
                        final name = basename(image.path);
                        final imageFile = File('${directory.path}/$name');
                        final newImage = await File(image.path).copy(imageFile.path);

                        setState(() {
                          _image = image;
                        });
                      },
                      child: DottedBorder(
                        padding: EdgeInsets.zero,
                        dashPattern: [5, 5],
                        borderType: BorderType.RRect,
                        radius: Radius.circular(19),
                        color: GGColors.primaryColor,
                        strokeWidth: 1,
                        child: Container(
                            width: GGSize.screenWidth(context),
                            height: _image != null ? GGSize.screenHeight(context) * 0.4 : GGSize.screenHeight(context) * 0.065,
                            decoration: BoxDecoration(color: Color.fromARGB(54, 0, 103, 238), borderRadius: BorderRadius.circular(19)),
                            child: _image != null
                                ? Image.file(File(_image!.path))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.share,
                                        color: GGColors.primaryColor,
                                        size: 22,
                                      ),
                                      SizedBox(width: 5),
                                      Text("Upload", style: TextStyle(color: GGColors.primaryColor, fontWeight: FontWeight.w600, fontSize: 16)),
                                    ],
                                  )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final ID_generated = await generateUniqueGroupId();
                            print(ID_generated);
                            setState(() {
                              _showCircle = true;
                            });
                            var photoUrl = '';
                            if (_image!=null){
                              final storageRef = FirebaseStorage.instance.ref().child('group_photos/$ID_generated/groupImage');

                              await FirebaseStorage.instance.ref().child('group_photos/$ID_generated/groupImage').putFile(File(_image!.path));

                              // Get the download URL of the uploaded image
                               photoUrl = await storageRef.getDownloadURL();
                            }
                            FirebaseFirestore.instance.collection('groups').doc(ID_generated).set({
                              'name': _groupNameController.text.trim(),
                              'description': _groupDescriptionController.text.trim(),
                              'createdBy': FirebaseAuth.instance.currentUser!.uid,
                              'createdAt': DateTime.now(),
                              'private': private,
                              'id': '${ID_generated}',
                              'validation_rules': 'Auto-accept',
                              'auto_kick_rules': rulesDropDownValue,
                              'photo_url': _image != null ? photoUrl : 'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/standartGroupPhoto.jpg?alt=media&token=003a20be-4556-4533-8e2b-805f44691121',
                            }).then((_) async {
                              await FirebaseFirestore.instance.collection('memberships').add({
                                'userId': FirebaseAuth.instance.currentUser!.uid,
                                'groupId': '${ID_generated}',
                                'role': 'admin', 
                                'joinedAt': FieldValue.serverTimestamp()
                              });
                              //🔥 Log Group Created
                              AnalyticsEngine().logEvent('group_created');
                              Fluttertoast.showToast(
                                msg: "Group created successfully",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.green,
                                textColor: Colors.black,
                                fontSize: 14.0,
                              );
                              Duration(seconds: 2);
                              Navigator.pop(context);
                            });
                          }
                        },
                        child: Container(
                            width: GGSize.screenWidth(context),
                            height: GGSize.screenHeight(context) * 0.065,
                            decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(21)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Create Group", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
              ),
            ),
          ),
        ));
  }
}

/* ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final ID_generated = await generateUniqueGroupId();
                      print(ID_generated);
                      setState(() {
                        _showCircle = true;
                      });
                      FirebaseFirestore.instance.collection('groups').doc(ID_generated).set({
                        'name': _groupNameController.text.trim(),
                        'description': _groupDescriptionController.text.trim(),
                        'createdBy': FirebaseAuth.instance.currentUser!.uid,
                        'createdAt': DateTime.now(),
                        'id': ID_generated,
                      }).then((_) {
                        Fluttertoast.showToast(
                          msg: "Group created successfully",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          backgroundColor: Colors.green,
                          textColor: Colors.black,
                          fontSize: 14.0,
                        );
                        Duration(seconds: 2);
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Create Group'),
                      SizedBox(width: 10),
                      Visibility(
                          visible: _showCircle,
                          child: SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ))),
                    ],
                  )),*/
