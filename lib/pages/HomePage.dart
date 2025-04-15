import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/i18n/t_data.dart';
import 'package:group_grit/l10n/app_localizations.dart';
import 'package:group_grit/main.dart';
import 'package:group_grit/pages/VideoPreview/VideoPlayerPage.dart';
import 'package:group_grit/utils/components/drawer.dart';
import 'package:group_grit/utils/components/groupsButtons.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:group_grit/utils/functions/Strava.dart' as Strava;
import 'package:group_grit/utils/functions/auth_service.dart';
import 'package:video_uploader/video_uploader.dart';

import 'package:rxdart/rxdart.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  // Get the current user's document
  final docRef = FirebaseFirestore.instance.collection("users").doc("${FirebaseAuth.instance.currentUser!.uid}");
  final Map<String, dynamic> user = {};
  void getDocument() {
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            user.addAll(data as Map<String, dynamic>);
          });
        } else {
          print("Document has no data.");
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  Stream<bool> userHasGroupWithChallenge() {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Stream delle memberships dell'utente
    final membershipStream = FirebaseFirestore.instance.collection('memberships').where('userId', isEqualTo: userId).snapshots();

    return membershipStream.switchMap((memberships) {
      if (memberships.docs.isEmpty) {
        return Stream.value(false);
      }

      // Lista di stream che monitorano le challenge per ogni gruppo
      List<Stream<bool>> challengeStreams = memberships.docs.map((membership) {
        final groupId = membership['groupId'];
        return FirebaseFirestore.instance
            .collection('groups')
            .doc(groupId)
            .collection('challenges')
            .snapshots()
            .map((snapshot) => snapshot.docs.isNotEmpty);
      }).toList();

      // Combiniamo gli stream per aggiornare in tempo reale
      return Rx.combineLatest<bool, bool>(
        challengeStreams,
        (values) => values.contains(true),
      );
    });
  }

  Future<bool> hasUsername(String uid) async {
    final userDoc = await db.collection('users').doc(uid).get();
    return userDoc.exists && userDoc.data()?['username'] != null;
  }

  Future<bool> checkUserState() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await currentUser?.reload();
      return FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      print("❌ Errore durante la verifica dell'utente: $e");
      return false;
    }
  }

  Future<String> getDeviceModel() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model; // Es. "Pixel 4a"
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine; // Es. "iPhone13,4"
    }
    return 'Sconosciuto';
  }

  void saveDeviceToken() async {
    if (FirebaseAuth.instance.currentUser?.uid == null || await checkUserState() == false) {
      return;
    } else {
      final fcm = FirebaseMessaging.instance;
      final token = await fcm.getToken();
      if (token == null) return;

      final docRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('tokens').doc(token);

      await docRef.set({
        'token': token,
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'device': await getDeviceModel(), // puoi usare device_info_plus se ti serve il nome specifico
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      // 4. Ascolta cambi di token
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final newTokenRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('tokens').doc(newToken);

        await newTokenRef.set({
          'token': newToken,
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
          'device': await getDeviceModel(), // puoi usare device_info_plus se ti serve il nome specifico
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    }
  }

  /// ✅ **Funzione per verificare se un token è valido**
  Future<bool> isTokenValid(String token) async {
    try {
      await FirebaseMessaging.instance.sendMessage(to: token);
      return true; // Il token è valido
    } catch (error) {
      if (error.toString().contains("registration-token-not-registered")) {
        return false; // Il token non è più valido
      }
      print("⚠️ Errore nel controllo del token: $error");
      return false; // Per sicurezza, consideriamo il token non valido
    }
  }

  @override
  void initState() {
    getDocument();
    hasUsername(FirebaseAuth.instance.currentUser!.uid);
    // checkUsernameAndNavigate();
    saveDeviceToken();
    checkUserState();

    //checkDisplayName();
    super.initState();
  }

  Future<void> sendWelcomeEmail() async {
    await FirebaseFirestore.instance.collection('emails').add({
      'from': {
        'email': 'noreply@groupgrit.io', // mittente verificato su MailerSend
      },
      'to.*.email':'noreply@groupgrit.io',
      'to': [
        {
          'email': 'arturo.marino04@gmail.com',
        }
      ],
      'variables': [
      {
        'email': 'arturo.marino04@gmail.com',
        'substitutions': [
          {
            'var': 'variable',
            'value': 'variable value'
          }
        ]
      }
    ],
      'template_id': '0p7kx4x9d5e49yjr',
      'subject': 'Welcome to GroupGrit!',
      'html': '''
      <div style="font-family: Arial, sans-serif; padding: 20px;">
        <h2 style="color: #333;">🎉 Welcome to <span style="color: #000;">GroupGrit</span>!</h2>
        <p>Hello,</p>
        <p>Thank you for signing up for <strong>GroupGrit</strong>.</p>
        <p>You are now ready to start your first challenge and give your best with your group.</p>
        <p style="margin-top: 20px;">
          🔥 Stay consistent.<br>
          💬 Motivate others.<br>
          🏆 Grow together.
        </p>
        <p style="margin-top: 30px;">See you soon,<br><strong>The GroupGrit Team</strong></p>
      </div>
    ''',
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      backgroundColor: GGColors.backgroundColor,
      drawer: MyDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: [
                    Builder(
                      builder: (context) => CupertinoButton(
                        child: Icon(FontAwesomeIcons.bars, color: GGColors.primarytextColor),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo.png',
                      width: GGSize.screenWidth(context) * 0.35 > 280 ? GGSize.screenWidth(context) * 0.22 : GGSize.screenWidth(context) * 0.35,
                    ),
                    //Text("GroupGrit", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: GGColors.primaryColor)),
                    SizedBox(width: GGSize.screenWidth(context) * 0.025),
                    /*
                    GestureDetector(
                      onTap: () {
                        sendWelcomeEmail();
                      },
                      child: Icon(Icons.notifications, color: GGColors.primarytextColor)),*/
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'The Ultimate Accountability App',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: GGColors.primarytextColor),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Transform your fitness journey with group accountability',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 150, 148, 148)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerPage(
                          imageUrl:
                              "https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/GroupGritContent%2FVideo-Preview.png?alt=media&token=e15b611c-6838-4cc2-96c2-a50b93eca0ba",
                          videoUrl:
                              "https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/GroupGritContent%2FSequence%2002.mp4?alt=media&token=1f8668c9-814f-4255-88d1-71dbd6b17719", // <-- URL del video
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        Hero(
                          tag: "videoHero",
                          child: Container(
                            width: GGSize.screenWidth(context),
                            height: GGSize.screenHeight(context) * 0.22,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(234, 234, 234, 1),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    "https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/GroupGritContent%2FVideo-Preview.png?alt=media&token=e15b611c-6838-4cc2-96c2-a50b93eca0ba"),
                                fit: BoxFit.fitHeight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 15),
                              ],
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.black87,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                  child: Container(
                      width: GGSize.screenWidth(context),
                      height: GGSize.screenHeight(context) * 0.18,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 13),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '"The only way to achieve the \nimpossible is to believe it is possible."',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 6),
                            child: Text(
                              '- Charles Kingsleigh',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GroupButton(
                        text: "Join Group",
                        onPressed: () {
                          Navigator.pushNamed(context, '/JoinGroupPage').then((value) {
                            userHasGroupWithChallenge();
                          });
                        },
                        icon: FontAwesomeIcons.userPlus,
                      ),
                      GroupButton(
                        text: "Create Group",
                        onPressed: () {
                          Navigator.pushNamed(context, '/CreateGroupPage').then((value) {
                            userHasGroupWithChallenge();
                          });
                          ;
                        },
                        icon: FontAwesomeIcons.plus,
                      ),
                      GroupButton(
                        text: "My Groups",
                        onPressed: () {
                          Navigator.pushNamed(context, '/MyGroupsPage').then((value) {
                            userHasGroupWithChallenge();
                          });
                          ;
                        },
                        icon: FontAwesomeIcons.users,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
