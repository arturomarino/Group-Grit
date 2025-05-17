import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:group_grit/i18n/t_data.dart';
import 'package:group_grit/l10n/app_localizations.dart';
import 'package:group_grit/main.dart';
import 'package:group_grit/utils/components/authButtons.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:group_grit/utils/functions/auth_service.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Mixpanel? mixpanel;
  bool _isLoading = false;

  Future<bool> accountExist(String email) async {
    print("Verifying if the email: $email exists in the database...");
    final result = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
    return !result.docs.isEmpty;
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          //physics: NeverScrollableScrollPhysics(),
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
                                        "Login to " + "Group Grit",
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Row(
                            children: [
                              Text("Email Address", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        SizedBox(height: 7),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
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
                          controller: passwordController,
                          obscureText: _obscureText,
                          style: TextStyle(color: GGColors.primarytextColor),
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
                            hintText: "Enter your password",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/ForgotPasswordPage');
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                    color: GGColors.primaryColor, decoration: TextDecoration.underline, decorationColor: GGColors.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              //mixpanel!.track('_signIn');
                              setState(() {
                                _isLoading = true;
                              });
                              final packageInfo = await PackageInfo.fromPlatform();
                              mixpanel?.track("Prova", properties: {"version": packageInfo.version});
                              await AuthService().signin(email: emailController.text, password: passwordController.text, context: context).then((value){
                                setState(() {
                                  _isLoading = false;
                                });
                              });
                            },
                            child: Container(
                              width: screenWidth,
                              height: screenHeight * 0.065,
                              decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(21)),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Sign In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                                  print(value);
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

                                      final baseUsername =
                                          FirebaseAuth.instance.currentUser?.displayName?.replaceAll(' ', '').toLowerCase() ?? 'user';
                                      final uniqueUsername = generateUniqueUsername(baseUsername, existingUsernames);

                                      final user = {
                                        'display_name': FirebaseAuth.instance.currentUser!.displayName,
                                        'email': FirebaseAuth.instance.currentUser!.email,
                                        'created_time': DateTime.now(),
                                        'uid': FirebaseAuth.instance.currentUser!.uid,
                                        'photo_url': FirebaseAuth.instance.currentUser!.photoURL,
                                        'username': uniqueUsername,
                                      };
                                      await db
                                          .collection('users')
                                          .doc(FirebaseAuth.instance.currentUser!.uid)
                                          .set(user)
                                          .onError((e, _) => print("Error writing document: $e"));

                                      navigatorKey.currentState!.pushNamedAndRemoveUntil('/UsernamePage', (_) => false);
                                    } else {
                                      navigatorKey.currentState!.pushNamedAndRemoveUntil('/HomePage', (_) => false);
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
                                                  'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/standartProfilePage.avif?alt=media&token=$API',
                                              'username': uniqueUsername,
                                            };
                                            await FirebaseAuth.instance.currentUser?.updatePhotoURL(
                                                'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/standartProfilePage.avif?alt=media&token=$API');
                                            await db
                                                .collection('users')
                                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                                .set(user)
                                                .onError((e, _) => print("Error writing document: $e"));

                                            navigatorKey.currentState!.pushNamedAndRemoveUntil('/UsernamePage', (_) => false);
                                          } else {
                                            navigatorKey.currentState!.pushNamedAndRemoveUntil('/HomePage', (_) => false);
                                            
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account?", style: TextStyle(color: GGColors.secondarytextColor)),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/SignUpPage');
                                },
                                child: Text("Sign Up",
                                    style: TextStyle(
                                        color: GGColors.primaryColor, decoration: TextDecoration.underline, decorationColor: GGColors.primaryColor)),
                              ),
                            ],
                          ),
                        ),
                        /*
                        InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/UsernamePage');
                                },
                                child: Text("UserName Page",
                                    style: TextStyle(
                                        color: GGColors.primaryColor, decoration: TextDecoration.underline, decorationColor: GGColors.primaryColor)),
                              ),*/
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
