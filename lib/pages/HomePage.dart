import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/i18n/t_data.dart';
import 'package:group_grit/l10n/app_localizations.dart';
import 'package:group_grit/main.dart';
import 'package:group_grit/pages/VideoPlayerPage.dart';
import 'package:group_grit/utils/components/drawer.dart';
import 'package:group_grit/utils/components/groupsButtons.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
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

  /*void checkUsernameAndNavigate() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final hasUsername = await this.hasUsername(uid);
      if (!hasUsername && FirebaseAuth.instance.currentUser != null) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          '/UsernamePage',
          (_) => false,
        );
      }
    }
  }*/
  /*Future<void> checkDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc['display_name'] == '') {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          '/DisplayNamePage',
          (_) => false,
        );
      }
    }
  }*/
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

  void saveDeviceToken() async {
    if (FirebaseAuth.instance.currentUser?.uid == null || await checkUserState() == false) {
      return;
    } else {
      final userTokensRef = db.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('tokens');

      // 1️⃣ Recupera tutti i token attuali dell'utente dal database
      final tokensSnapshot = await userTokensRef.get();
      List<String> storedTokens = tokensSnapshot.docs.map((doc) => doc.id).toList();

      // 2️⃣ Ottieni il token attuale del dispositivo
      final currentToken = await FirebaseMessaging.instance.getToken();
      if (currentToken == null) return;

      // 3️⃣ Controlla quali token sono ancora validi
      List<String> validTokens = [];

      for (String token in storedTokens) {
        if (token == currentToken) {
          validTokens.add(token);
        } else {
          bool isValid = await isTokenValid(token);
          if (isValid) {
            validTokens.add(token);
          } else {
            print("❌ Token non valido, rimosso: $token");
            await userTokensRef.doc(token).delete(); // Rimuove il token non valido
          }
        }
      }

      // 4️⃣ Registra il token attuale se non è già presente
      if (!validTokens.contains(currentToken)) {
        print("✅ Nuovo token registrato: $currentToken");
        await userTokensRef.doc(currentToken).set({'token': currentToken});
      }

      // 5️⃣ Ascolta il cambio di token e aggiorna
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print("🔄 Token aggiornato: $newToken");
        await userTokensRef.doc(newToken).set({'token': newToken});
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
                      width: GGSize.screenWidth(context) * 0.35,
                    ),
                    //Text("GroupGrit", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: GGColors.primaryColor)),
                    SizedBox(width: GGSize.screenWidth(context) * 0.025),
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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerPage(
                          imageUrl:
                              "https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/mockup.png?alt=media&token=d7bf44bf-0e71-40a5-9d4c-a019bcd7b043",
                          videoUrl: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4", // <-- URL del video
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
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    "https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/mockup.png?alt=media&token=d7bf44bf-0e71-40a5-9d4c-a019bcd7b043"),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 15),
                              ],
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Icon(CupertinoIcons.play_fill, color: Colors.white, size: 40),
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
