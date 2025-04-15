import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/main.dart';
import 'package:group_grit/pages/Authentication/UsernamePage.dart';
import 'package:group_grit/utils/components/authButtons.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:group_grit/utils/functions/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  Future<bool> accountCheck(String email) async {
    final result = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
    return result.docs.isEmpty;
  }

  bool _obscureText = true;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController password1Controller = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    @override
    void dispose() {
      fullNameController.dispose();
      emailController.dispose();
      password1Controller.dispose();
      password2Controller.dispose();
      super.dispose();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
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
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: GGColors.TextFieldColor,
                                          backgroundImage: AssetImage(
                                            'assets/images/logoIcon.jpg',
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        "Sign Up to " + "Group Grit",
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
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            children: [
                              Text("Full Name", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        SizedBox(height: 7),
                        TextField(
                          controller: fullNameController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: GGColors.primarytextColor),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              FontAwesomeIcons.user,
                              color: GGColors.secondarytextColor,
                              size: 20,
                            ),
                            hintText: "Enter your full name",
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
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text("Email Address", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 7),
                        TextField(
                          controller: emailController,
                          style: TextStyle(color: GGColors.primarytextColor),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              FontAwesomeIcons.envelope,
                              color: GGColors.secondarytextColor,
                              size: 20,
                            ),
                            hintText: "Enter your email",
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
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text("Password", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 7),
                        TextField(
                          controller: password1Controller,
                          style: TextStyle(color: GGColors.primarytextColor),
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              FontAwesomeIcons.lock,
                              color: GGColors.secondarytextColor,
                              size: 20,
                            ),
                            suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                                  color: GGColors.secondarytextColor,
                                  size: 20,
                                )),
                            hintText: "Create a password",
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
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text("Confirm Password", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 7),
                        TextField(
                          controller: password2Controller,
                          style: TextStyle(color: GGColors.primarytextColor),
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              FontAwesomeIcons.lock,
                              color: GGColors.secondarytextColor,
                              size: 20,
                            ),
                            hintText: "Confirm your password",
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
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              //    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const UsernamePage()));
                              if (fullNameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  password1Controller.text.isEmpty ||
                                  password2Controller.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: const Text('Please fill all fields'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: Colors.red,
                                ));
                                
                              } else if (fullNameController.text.isNotEmpty &&
                                  emailController.text.isNotEmpty &&
                                  password1Controller.text != password2Controller.text) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: const Text('Passwords do not match'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                if (_isLoading == false) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  final connectivityResult = await InternetAddress.lookup('google.com');
                                  if (connectivityResult.isNotEmpty && connectivityResult[0].rawAddress.isNotEmpty) {
                                    print('Connection state: ✅ Connected to the internet');
                                  } else {
                                    print('Connection state: ❌ No internet connection');
                                  }
                                  await AuthService()
                                      .signup(email: emailController.text, password: password2Controller.text, context: context)
                                      .then((value) async {
                                    final user = {
                                      'display_name': fullNameController.text.trim(),
                                      'email': emailController.text.trim(),
                                      'created_time': DateTime.now(),
                                      'uid': FirebaseAuth.instance.currentUser!.uid,
                                      'photo_url':
                                          'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/standartProfilePage.avif?alt=media&token=c3b38564-1579-4440-8da4-410950dfeede',
                                    };
                                    await db
                                        .collection('users')
                                        .doc(FirebaseAuth.instance.currentUser!.uid)
                                        .set(user)
                                        .onError((e, _) => print("Error writing document: $e"));
                                    await FirebaseAuth.instance.currentUser?.updatePhotoURL(
                                        'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/standartProfilePage.avif?alt=media&token=c3b38564-1579-4440-8da4-410950dfeede');

                                    final storageRef = FirebaseStorage.instance.ref();
                                    final profilePicRef = storageRef.child("user_photos/${FirebaseAuth.instance.currentUser!.uid}/profilePage");

                                    try {
                                      await profilePicRef.putFile(File(
                                          'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/standartProfilePage.avif?alt=media&token=c3b38564-1579-4440-8da4-410950dfeede'));
                                      final photoUrl = await profilePicRef.getDownloadURL();
                                      await FirebaseAuth.instance.currentUser?.updatePhotoURL(photoUrl);
                                      user['photo_url'] = photoUrl;
                                    } catch (e) {
                                      print("Error uploading profile picture: $e");
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });

                                    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                                      '/UsernamePage',
                                      (_) => false,
                                    );
                                  }).onError((handleError, stackTrace) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    
                                    
                                  });
                                }
                              }
                            },
                            child: Container(
                              width: screenWidth,
                              height: screenHeight * 0.065,
                              decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(21)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Or continue with", style: TextStyle(color: GGColors.primarytextColor)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AuthButton(
                                icon: FontAwesomeIcons.google,
                                onPressed: () => AuthService().signInWithGoogle().then((value) async {
                                  if (value != null) {
                                    final connectivityResult = await InternetAddress.lookup('google.com');
                                    if (connectivityResult.isNotEmpty && connectivityResult[0].rawAddress.isNotEmpty) {
                                      print('Connection state: ✅ Connected to the internet');
                                    } else {
                                      print('Connection state: ❌ No internet connection');
                                    }
                                    if (value.additionalUserInfo?.isNewUser == true) {
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


                                      final user = {
                                        'display_name': FirebaseAuth.instance.currentUser?.displayName,
                                        'email': FirebaseAuth.instance.currentUser?.email,
                                        'created_time': DateTime.now(),
                                        'uid': FirebaseAuth.instance.currentUser?.uid,
                                        'photo_url': FirebaseAuth.instance.currentUser?.photoURL,
                                        'username': uniqueUsername,
                                      };
                                      await db
                                          .collection('users')
                                          .doc(FirebaseAuth.instance.currentUser?.uid)
                                          .set(user)
                                          .onError((e, _) => print("Error writing document: $e"));

                                      navigatorKey.currentState!.pushNamedAndRemoveUntil('/UsernamePage', (_) => false);
                                    } else {
                                      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                                        '/HomePage',
                                        (_) => false,
                                      );
                                    }
                                  }
                                }),
                              ),
                              SizedBox(width: 10),
                              if (Theme.of(context).platform == TargetPlatform.iOS)
                                AuthButton(
                                    icon: FontAwesomeIcons.apple,
                                    onPressed: () {
                                      //CODICE CORRETTO PER SIGN IN WITH APPLE
                                      AuthService().signInWithApple().then((value) async {
                                        if (value != null) {
                                          if (value.additionalUserInfo?.isNewUser == true && (value.additionalUserInfo?.profile?['firstName'] == null ||
                                              value.additionalUserInfo?.profile?['lastName'] == null)) {
                                            navigatorKey.currentState!.pushNamedAndRemoveUntil('/DisplayNamePage', (_) => false);
                                            print(value.additionalUserInfo?.profile?['firstName']);
                                            print(value.additionalUserInfo?.profile?['lastName']);
                                            return;
                                          }

                                          print(value.additionalUserInfo?.profile?['firstName']);
                                          print(value.additionalUserInfo?.profile?['lastName']);
                                          /*print('value user: ${value.additionalUserInfo?.profile?['lastName']}');
                                          print('value user: ${value.additionalUserInfo?.profile?['firstName']}');
                                          print('Firebase User: '+'${FirebaseAuth.instance.currentUser?.displayName}');*/
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

                                          final baseUsername =
                                              FirebaseAuth.instance.currentUser?.displayName?.replaceAll(' ', '').toLowerCase() ?? 'user';
                                          final uniqueUsername = generateUniqueUsername(baseUsername, existingUsernames);
                                          //final valid = await accountExist("${FirebaseAuth.instance.currentUser?.email}");
                                          if (value.additionalUserInfo?.isNewUser == true &&
                                              value.additionalUserInfo?.profile?['firstName'] != null &&
                                              value.additionalUserInfo?.profile?['lastName'] != null) {
                                            final user = {
                                              'display_name':
                                                  '${value.additionalUserInfo?.profile?['firstName']} ${value.additionalUserInfo?.profile?['lastName']}',
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

                                            navigatorKey.currentState!.pushNamedAndRemoveUntil('/UsernamePage', (_) => false);
                                          } else {
                                            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                                              '/HomePage',
                                              (_) => false,
                                            );
                                          }
                                        }
                                      });
                                    })
                              /*SizedBox(width: 5),
                        AuthButton(icon: FontAwesomeIcons.facebook, onPressed: () {}),
                        SizedBox(width: 5),
                        AuthButton(icon: FontAwesomeIcons.apple, onPressed: () {}),*/
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?", style: TextStyle(color: GGColors.primarytextColor)),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text("Sign In",
                                    style: TextStyle(
                                        color: GGColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: GGColors.primaryColor)))
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
