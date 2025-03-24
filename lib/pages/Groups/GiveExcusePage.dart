import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';

class GiveExcusePage extends StatefulWidget {
  @override
  State<GiveExcusePage> createState() => _GiveExcusePageState();
}

class _GiveExcusePageState extends State<GiveExcusePage> {
  int _excuseSelected = 5;

  List<String> _excuses = [
    'Tired.',
    'Busy with work.',
    'Feeling unwell.',
    'Personal reason.',
  ];
  bool _showCircle = false;

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

    return Scaffold(
      backgroundColor: GGColors.backgroundColor,
      body: SafeArea(
          child: Center(
        child: Container(
          height: GGSize.screenHeight(context) * 0.57,
          width: GGSize.screenWidth(context) * 0.8,
          decoration: BoxDecoration(
            color: GGColors.buttonColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("What's your excuse?", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
                    SizedBox(
                      width: GGSize.screenWidth(context) * 0.045,
                    ),
                    CupertinoButton(
                      child: Icon(Icons.cancel, color: Colors.black.withOpacity(0.2), size: 28),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                Column(
                  children: List.generate(4, (index) {
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _excuseSelected = index;
                        });

                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Container(
                          height: GGSize.screenHeight(context) * 0.054,
                          width: GGSize.screenWidth(context),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.lightGreen, width: _excuseSelected == index ? 2:0),
                            color: GGColors.backgroundColor,
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 17),
                            child: Row(
                              children: [
                                Center(
                                  child: Text(
                                    _excuses[index],
                                    style: TextStyle(
                                      color: _excuseSelected==index?Colors.lightGreen: GGColors.secondarytextColor.withOpacity(0.5),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Visibility(visible: _excuseSelected == index ? true : false,child: Icon( Icons.check, color: Colors.lightGreen, size: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      if (_excuseSelected != 5) {
                        setState(() {
                          _showCircle = true;
                        });
                        await Future.delayed(Duration(seconds: 2));

                        await FirebaseFirestore.instance.collection('users_challenges').add({
                          'userId': FirebaseAuth.instance.currentUser!.uid,
                          'groupId': arguments['groupId'],
                          'challengeId': arguments['challengeId'],
                          'status': 'excused',
                          'videoUrl': null,
                          'excuse': _excuses[_excuseSelected].substring(0, _excuses[_excuseSelected].length - 1),
                          'time': DateTime.now(),
                        });
                         final docRef = FirebaseFirestore.instance.collection('users_rankings').doc('${FirebaseAuth.instance.currentUser!.uid}_${arguments['groupId']}');
                            final docSnapshot = await docRef.get();

                            if (docSnapshot.exists) {
                            docRef.update({
                              "streak": 0, 
                              "excusesSent": FieldValue.increment(1),
                            });
                            } else {
                            docRef.set({
                              "userId": FirebaseAuth.instance.currentUser!.uid,
                              "groupId": arguments['groupId'],
                              "completedChallenges": 0, // Prima challenge completata 
                              "streak": 0, 
                              "excusesSent": FieldValue.increment(1),// Prima challenge completata di fila senza scuse
                            });
                            }
                        setState(() {
                          _showCircle = false;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                          content: Text('Excuse submitted successfully!'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    child: Container(
                        width: GGSize.screenWidth(context),
                        height: GGSize.screenHeight(context) * 0.06,
                        decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(21)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Give Excuse", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/UploadVideoPage', arguments: {
                      'groupId': arguments['groupId'],
                      'challengeId': arguments['challengeId'],
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Container(
                      height: GGSize.screenHeight(context) * 0.08,
                      width: GGSize.screenWidth(context),
                      decoration: BoxDecoration(
                        border: Border.all(color: GGColors.secondarytextColor.withOpacity(0.3)),
                        color: GGColors.backgroundColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Changed your mind? Submit Challenge Video here.',
                                style: TextStyle(
                                  color: GGColors.secondarytextColor.withOpacity(0.5),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}
