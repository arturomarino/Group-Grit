import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/components/authButtons.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:group_grit/utils/functions/auth_service.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final _remoteConfig = FirebaseRemoteConfig.instance;

  bool diplay_name_exist = false;

  Future<bool> usernameCheck(String username) async {
    final result = await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: username).get();
    return result.docs.isEmpty;
  }

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> checkDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc['display_name'] == '') {
        setState(() {
          diplay_name_exist = false;
        });
      } else {
        setState(() {
          diplay_name_exist = true;
        });
      }
    }
  }

  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () {
      checkDisplayName();
    });
    _initRemoteConfig();
    super.initState();
  }

  _initRemoteConfig() async {
    await _remoteConfig.setDefaults({
      'showUsernameBackButton': true,
    });

    await _remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeout: Duration(seconds: 10), minimumFetchInterval: Duration(seconds: 10)));
    await _remoteConfig.fetchAndActivate();

    _remoteConfig.onConfigUpdated.listen((event) async {
      await _remoteConfig.activate();
      setState(() {});
    });
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
                                        backgroundImage: AssetImage(
                                          'assets/images/logoIcon.jpg',
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
                            "Before you get started, let's create your username",
                            style: TextStyle(color: GGColors.secondarytextColor, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            children: [
                              Text("Choose your Username",
                                  style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        SizedBox(height: 7),
                        TextField(
                          controller: usernameController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: GGColors.primarytextColor),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              FontAwesomeIcons.user,
                              color: GGColors.primarytextColor,
                              size: 20,
                            ),
                            hintText: "Create your username",
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
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9._]')), // Permette solo caratteri validi
                          ],
                        ),
                        Visibility(
                          visible: !diplay_name_exist,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Row(
                              children: [
                                Text("Name and Surname",
                                    style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        Visibility(visible: !diplay_name_exist, child: SizedBox(height: 7)),
                        Visibility(
                          visible: !diplay_name_exist,
                          child: TextField(
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
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
                              } else if (usernameController.text.isEmpty || (nameController.text.isEmpty && !diplay_name_exist)) {
                                Fluttertoast.showToast(
                                  msg: "Please fill all the fields",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.TOP,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.black,
                                  fontSize: 14.0,
                                );
                              } else {
                                if (diplay_name_exist) {
                                  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                                    'username': usernameController.text.trim(),
                                  }).then((value) {
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
                                } else {
                                  await FirebaseAuth.instance.currentUser?.updatePhotoURL(
                                      'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/standartProfilePage.avif?alt=media&token=c3b38564-1579-4440-8da4-410950dfeede');
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth.instance.currentUser!.uid)
                                      .update({'username': usernameController.text.trim(), 'display_name': nameController.text.trim()}).then((value) {
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
                              }
                            },
                            child: Container(
                              width: screenWidth,
                              height: screenHeight * 0.06,
                              decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(21)),
                              child:
                                  Center(child: Text("Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _remoteConfig.getBool('showUsernameBackButton'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CupertinoButton(
                                  child: Text('Back to Login', style: TextStyle(color: GGColors.primaryColor)),
                                  onPressed: () async {
                                    Navigator.pushNamedAndRemoveUntil(context, '/LoginPage', (Route<dynamic> route) => false);
                                  },
                                ),
                              ],
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
