import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';

class ChallengeDetailsPage extends StatefulWidget {
  const ChallengeDetailsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ChallengeDetailsPage> createState() => _ChallengeDetailsPageState();
}

class _ChallengeDetailsPageState extends State<ChallengeDetailsPage> {

   Map<String, dynamic> args = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  

  List<DocumentSnapshot> _memberships = [];

  void _getGroupMemberships() async {
    QuerySnapshot memberships = await FirebaseFirestore.instance.collection('memberships').where('groupId', isEqualTo: args['groupId'] ).get();
    setState(() {
      _memberships = memberships.docs;
    });
  }

  bool _isUserOwner() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return _memberships.any((membership) => membership['userId'] == userId && membership['role'] == 'admin');
  }

  @override
  void initState() {
    _getGroupMemberships();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: GGColors.backgroundColor,
      appBar: AppBar(
        foregroundColor: GGColors.primarytextColor,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            args['activityName'],
            style: TextStyle(fontWeight: FontWeight.w600, color: GGColors.primarytextColor, fontSize: 20),
          ),
        ),
        actions: [
          Visibility(
            visible: _isUserOwner(),
            child: IconButton(
              padding: EdgeInsets.only(right: 10),
              icon: Icon(CupertinoIcons.trash, color: GGColors.primarytextColor),
              onPressed: () {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Delete Challenge"),
                      content: Text("Are you sure you want to delete this challenge?"),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text("Delete"),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('groups')
                                .doc(args['groupId'])
                                .collection('challenges')
                                .doc(args['challengeId'])
                                .delete()
                                .then((_) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              print("Challenge deleted successfully");
                            }).catchError((error) {
                              Navigator.of(context).pop();
                              print("Failed to delete challenge: $error");
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
        backgroundColor: GGColors.backgroundColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            width: GGSize.screenWidth(context),
            height: GGSize.screenHeight(context) * 0.25,
            child: Center(
                child: Text(
              '🏋',
              style: TextStyle(fontSize: 70),
            )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: GGSize.screenWidth(context) * 0.9,
                  child: EditableTextWidget(
                    initialText: args['activityName'],
                    textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Pass the document ID here
                    updateDocs: (String newText) {
                      // Update the document in Firestore
                      FirebaseFirestore.instance.collection('groups').doc(args['groupId']).collection('challenges').doc(args['challengeId']).update({
                        'activityName': newText,
                      }).then((_) {
                        print("Document updated successfully");
                      }).catchError((error) {
                        print("Failed to update document: $error");
                      });
                    }, // Add this line to handle text changes
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: GGSize.screenWidth(context) * 0.9,
                  child: EditableTextWidget(
                    initialText: args['activityDescription'],
                    textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: GGColors.secondarytextColor), // Pass the document ID here
                    updateDocs: (String newText) {
                      // Update the document in Firestore
                      print(newText);
                      FirebaseFirestore.instance.collection('groups').doc(args['groupId']).collection('challenges').doc(args['challengeId'])
                        ..update({
                          'activityDescription': newText,
                        }).then((_) {
                          print("Document updated successfully");
                        }).catchError((error) {
                          print("Failed to update document: $error");
                        });
                    }, // Add this line to handle text changes
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EditableTextWidget extends StatefulWidget {
  final String initialText;
  final TextStyle? textStyle;
  final Function updateDocs; // Add this line to accept document ID

  const EditableTextWidget({super.key, required this.initialText, this.textStyle, required this.updateDocs});

  @override
  _EditableTextWidgetState createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  late bool _isEditing;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _isEditing = false;
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isEditing = true),
      child: _isEditing
          ? Focus(
              autofocus: false,
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  widget.updateDocs(_controller.text);
                  setState(() => _isEditing = false);
                }
              },
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: widget.textStyle ?? TextStyle(fontSize: 16, color: GGColors.secondarytextColor),
                //decoration: InputDecoration.collapsed(hintText: ""),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(Icons.check, color: GGColors.primarytextColor),
                    onPressed: () {
                      widget.updateDocs(_controller.text);
                      setState(() => _isEditing = false);
                    },
                  ),
                ),
              ),
            )
          : Text(
              _controller.text,
              style: widget.textStyle ?? TextStyle(fontSize: 16, color: GGColors.secondarytextColor),
            ),
    );
  }
}
