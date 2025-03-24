import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EditGroupPage extends StatefulWidget {
  final String groupId;
  final DocumentSnapshot groupData;

  const EditGroupPage({super.key, required this.groupId, required this.groupData});
  @override
  _EditGroupPageState createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupDescriptionController = TextEditingController();
  bool private = false;
  String _groupName = '';
  String _groupDescription = '';

  String groupImage = '';

  bool _showCircle = false;
  bool _showCircleLeave = false;

  final List<Tab> _tabs = [
    Tab(
      text: "Public",
    ),
    Tab(
      text: "Private",
    ),
  ];

  @override
  void initState() {
    groupImage = widget.groupData['photo_url'];
    private = widget.groupData['private'];
    super.initState();
    private = widget.groupData['private'];
    _groupNameController = TextEditingController(text: widget.groupData['name']);
    _groupDescriptionController = TextEditingController(text: widget.groupData['description']);
    _getGroupMemberships();
  }

  List<DocumentSnapshot> _memberships = [];

  void _getGroupMemberships() async {
    QuerySnapshot memberships = await FirebaseFirestore.instance.collection('memberships').where('groupId', isEqualTo: widget.groupId).get();
    setState(() {
      _memberships = memberships.docs;
    });
  }

  bool _isUserOwner() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return _memberships.any((membership) => membership['userId'] == userId && membership['role'] == 'admin');
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
          'Edit Group',
          style: TextStyle(color: GGColors.primarytextColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actionsPadding: EdgeInsets.only(right: 10),
        actions: [
          IconButton(
            icon: Icon(private ? CupertinoIcons.lock_fill : CupertinoIcons.lock_open_fill, color: GGColors.primarytextColor),
            onPressed: () {
              if (_isUserOwner()) {
                setState(() {
                  private = !private;
                });
                FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
                  'private': private,
                });
                Fluttertoast.showToast(
                  msg: private ? "Group is now private" : "Group is now public",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.green,
                  textColor: Colors.black,
                  fontSize: 14.0,
                );
              } else {
                Fluttertoast.showToast(
                  msg: "Only the group owner can change this setting",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.red,
                  textColor: Colors.black,
                  fontSize: 14.0,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          reverse: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: double.infinity,
                        height: GGSize.screenHeight(context) * 0.25,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(19),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(groupImage), // Usa CachedNetworkImageProvider per caching
                              fit: BoxFit.cover,
                            )),
                      ),
                      Visibility(
                        visible: _isUserOwner(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              // Implement your photo change logic here
                              // Implement your photo change logic here
                              // For example, you can use an image picker to select a new photo
                              final ImagePicker _picker = ImagePicker();
                              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

                              if (image != null) {
                                // Upload the image to Firebase Storage and get the download URL
                                final storageRef = FirebaseStorage.instance.ref().child('group_photos/${widget.groupId}');
                                final uploadTask = storageRef.putFile(File(image.path));
                                final snapshot = await uploadTask.whenComplete(() => {});
                                final downloadUrl = await snapshot.ref.getDownloadURL();

                                // Update the group document with the new photo URL
                                await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
                                  'photo_url': downloadUrl,
                                });

                                setState(() {
                                  groupImage = downloadUrl;
                                });

                                Fluttertoast.showToast(
                                  msg: "Photo updated successfully",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.TOP,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.black,
                                  fontSize: 14.0,
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(19),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    readOnly: !_isUserOwner(),
                    controller: _groupNameController,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: GGColors.primarytextColor),
                    decoration: InputDecoration(
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
                    readOnly: !_isUserOwner(),
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
                  Visibility(
                    visible: _isUserOwner(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() {
                              _showCircle = true;
                            });
                            FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
                              'name': _groupNameController.text.trim(),
                              'description': _groupDescriptionController.text.trim(),
                              'private': private,
                            }).then((_) async {
                              Fluttertoast.showToast(
                                msg: "Group updated successfully",
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
                            decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(19)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Save Group Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: const Color.fromARGB(255, 188, 217, 255),
                              title: Text("Confirm"),
                              content: Text("Are you sure you want to leave?"),
                              actions: [
                                TextButton(
                                  child: Text("Dismiss", style: TextStyle(color: GGColors.primarytextColor)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Container(
                                    child: _showCircleLeave == true
                                        ? SizedBox(
                                            height: 10,
                                            width: 10,
                                            child: CircularProgressIndicator(
                                              color: Colors.red,
                                            ))
                                        : Text(_showCircleLeave == false ? "Leave" : 'Load', style: TextStyle(color: Colors.red)),
                                  ),
                                  onPressed: () async {
                                    if (_isUserOwner()) {
                                      final QuerySnapshot remainingMembers = await FirebaseFirestore.instance
                                          .collection('memberships')
                                          .where('groupId', isEqualTo: widget.groupId)
                                          .where('userId', isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
                                          .get();

                                      if (remainingMembers.docs.isNotEmpty) {
                                        final newAdmin = remainingMembers.docs[0];
                                        await FirebaseFirestore.instance.collection('memberships').doc(newAdmin.id).update({'role': 'admin'});
                                      }
                                    }
                                    final QuerySnapshot memberSnapshot =
                                        await FirebaseFirestore.instance.collection('memberships').where('groupId', isEqualTo: widget.groupId).get();

                                    if (memberSnapshot.docs.length == 1) {
                                      await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).delete();
                                    }
                                    await FirebaseFirestore.instance
                                        .collection('memberships')
                                        .where('groupId', isEqualTo: widget.groupId)
                                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                                        .get()
                                        .then((snapshot) {
                                      for (DocumentSnapshot ds in snapshot.docs) {
                                        ds.reference.delete();
                                      }
                                    });
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                          width: GGSize.screenWidth(context),
                          height: GGSize.screenHeight(context) * 0.065,
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(19)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Leave group", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              SizedBox(width: 10),
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
