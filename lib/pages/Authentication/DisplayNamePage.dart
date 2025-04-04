import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/main.dart';
import 'package:group_grit/utils/components/authButtons.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:group_grit/utils/functions/auth_service.dart';

class DisplayNamePage extends StatefulWidget {
  const DisplayNamePage({super.key});

  @override
  State<DisplayNamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<DisplayNamePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: GGSize.screenHeight(context) * 0.3,
                    width: GGSize.screenWidth(context),
                    child: Stack(
                      children: [
                        Container(
                          height: GGSize.screenHeight(context) * 0.3,
                          width: GGSize.screenWidth(context),
                          child: Image.asset(
                            "assets/images/backLoginImage.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 60),
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: GGColors.TextFieldColor,
                                        child: Icon(
                                          Icons.fitness_center,
                                          size: 30,
                                          color: GGColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        "Sign Up Complete!",
                                        style: TextStyle(color: GGColors.primarytextColor, fontSize: 30, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: Text(
                            "Before you get started, let's set up your display name.",
                            style: TextStyle(color: GGColors.secondarytextColor, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            children: [
                              Text("Name and Surname", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        SizedBox(height: 7),
                        TextField(
                          controller: nameController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: GGColors.primarytextColor),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              FontAwesomeIcons.user,
                              color: GGColors.primarytextColor,
                              size: 20,
                            ),
                            hintText: "Write your name and surname",
                            hintStyle: TextStyle(color: GGColors.secondarytextColor),
                            filled: true,
                            fillColor: GGColors.TextFieldColor,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(19),
                              borderSide: BorderSide(color: GGColors.TextFieldColor, width: 0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(19),
                              borderSide: BorderSide(color: GGColors.primaryColor, width: 2.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              if (nameController.text.isEmpty) {
                                Fluttertoast.showToast(
                                  msg: "Please fill the field",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.TOP,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.black,
                                  fontSize: 14.0,
                                );
                              } else {
                                setState(() {
                                  _isLoading = true;
                                });
                                final connectivityResult = await InternetAddress.lookup('google.com');
                                if (connectivityResult.isNotEmpty && connectivityResult[0].rawAddress.isNotEmpty) {
                                  print('Connection state: ✅ Connected to the internet');
                                } else {
                                  print('Connection state: ❌ No internet connection');
                                }
                                final existingUsernames = await db.collection('users').get().then((snapshot) {
                                  return snapshot.docs.map((doc) => doc['username'] as String).toList();
                                });

                                String generateUniqueUsername(String baseName, List<String> existingUsernames) {
                                  String username = baseName;
                                  int counter = 1;
                                  while (existingUsernames.contains(username)) {
                                    username = '$baseName$counter';
                                    counter++;
                                  }
                                  return username;
                                }

                                final baseUsername = FirebaseAuth.instance.currentUser?.displayName?.replaceAll(' ', '').toLowerCase() ?? 'user';
                                final uniqueUsername = generateUniqueUsername(baseUsername, existingUsernames);
                                //final valid = await accountExist("${FirebaseAuth.instance.currentUser?.email}");

                                final user = {
                                  'display_name': '${nameController.text.trim()}',
                                  'email': FirebaseAuth.instance.currentUser!.email,
                                  'created_time': DateTime.now(),
                                  'uid': FirebaseAuth.instance.currentUser!.uid,
                                  'photo_url':
                                      'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/standartProfilePage.avif?alt=media&token=c3b38564-1579-4440-8da4-410950dfeede',
                                  'username': uniqueUsername,
                                };
                                await FirebaseAuth.instance.currentUser?.updatePhotoURL(
                                    'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/standartProfilePage.avif?alt=media&token=c3b38564-1579-4440-8da4-410950dfeede');
                                await db
                                    .collection('users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .set(user)
                                    .onError((e, _) => print("Error writing document: $e"));
                                setState(() {
                                  _isLoading = false;
                                });

                                navigatorKey.currentState!.pushNamedAndRemoveUntil('/UsernamePage', (_) => false);
                              }
                            },
                            child: Container(
                              width: screenWidth,
                              height: screenHeight * 0.06,
                              decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(21)),
                              child: Center(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  SizedBox(width: 10),
                                  Visibility(
                                      visible: _isLoading == true ? true : false,
                                      child: SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          )))
                                ],
                              )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        /*Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: double.infinity),
            Container(
              width: screenWidth * 0.8,
              //height: screenHeight * 0.44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 5, blurRadius: 7, offset: const Offset(0, 3))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Text("SignUp Complete!", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Before you get started, let's create your username",
                        style: TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text("Choose Your Username",
                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Container(
                        height: screenWidth * 0.1,
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 13),
                            hintText: "Type your username here",
                            hintStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 229, 231, 235), width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 229, 231, 235), width: 2.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () async {
                        final valid = await usernameCheck(usernameController.text);
                        print(valid);
                        if (usernameController.text.isEmpty || usernameController.text.length < 6) {
                          Fluttertoast.showToast(
                            msg: "Invalid username, at least 6 characters",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.red,
                            textColor: Colors.black,
                            fontSize: 14.0,
                          );
                        } else if (!valid) {
                          Fluttertoast.showToast(
                            msg: "Username is unavailable",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.red,
                            textColor: Colors.black,
                            fontSize: 14.0,
                          );
                        } else {
                          
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({'username': usernameController.text}).then((value) {
                            Fluttertoast.showToast(
                              msg: "Username updated",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.green,
                              textColor: Colors.black,
                              fontSize: 14.0,
                            );
                            Duration(seconds: 2);
                            Navigator.pushNamed(context, '/HomePage');
                          });
                        }
                      },
                      child: Container(
                        width: screenWidth * 0.8,
                        height: 40,
                        decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),*/
      ),
    );
  }
}
