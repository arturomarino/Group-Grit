import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/i18n/t_data.dart';
import 'package:group_grit/l10n/app_localizations.dart';
import 'package:group_grit/main.dart';
import 'package:group_grit/pages/User/ProfilePage.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:group_grit/utils/functions/AnalyticsEngine.dart';
import 'package:group_grit/utils/functions/Strava.dart' as Strava;
import 'package:group_grit/utils/functions/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatefulWidget {
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final docRef = FirebaseFirestore.instance.collection("users").doc("${FirebaseAuth.instance.currentUser!.uid}");
  final _remoteConfig = FirebaseRemoteConfig.instance;
  bool stravaConnected = false;

  final Map<String, dynamic> user = {};
  void getDocument() {
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          user.addAll(data);
          //print(user);
        });
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  initState() {
    super.initState();
    FirebaseAuth.instance.currentUser!.updatePhotoURL(
        'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/user_photos%2FcNhA32GBUteczS4u9yThwf4KAaC3%2FprofilePage?alt=media&token=2788526e-2e95-45a0-86ab-ec9743546c47');
    getDocument();
    _initRemoteConfig();
    Strava.isUserAuthenticated().then((isAuthenticated) {
      if (isAuthenticated) {
        setState(() {
          stravaConnected = true;
        });
      } else {
        setState(() {
          stravaConnected = false;
        });
      }
    });
  }

  _initRemoteConfig() async {
    await _remoteConfig.setDefaults({
      'showLanguageTile': false,
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
    final loc = AppLocalizations.of(context)!;
    return Drawer(
      backgroundColor: GGColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Container(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(CupertinoIcons.xmark),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Image.asset(
                      'assets/images/logo.png',
                      width: GGSize.screenWidth(context) * 0.33 > 270 ? GGSize.screenWidth(context) * 0.2 : GGSize.screenWidth(context) * 0.35,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Divider(),
              ),
              Column(
                children: [
                  SizedBox(height: GGSize.screenHeight(context) * 0.04),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.black,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user['photo_url'] ??
                              'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/standartProfilePage.avif?alt=media&token=c3b38564-1579-4440-8da4-410950dfeede', // Evita null e rende l'URL univoco
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          placeholder: (context, url) => CircularProgressIndicator(), // Placeholder mentre carica
                          errorWidget: (context, url, error) => Icon(Icons.person, size: 44, color: Colors.white), // Se l'immagine non si carica
                        ),
                      ),
                    ),
                    title: Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfilePage(
                                userFromPrevius: user,
                              )));
                      // Handle the my profile tap
                    },
                  ),
                  Visibility(
                    visible: _remoteConfig.getBool('showLanguageTile'),
                    child: ListTile(
                      leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Center(
                            child: Icon(
                              CupertinoIcons.globe,
                              size: 22,
                            ),
                          )),
                      title: Text(loc.utilsComponentsDrawerText3, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.of(context).pushNamed('/LanguagePage');
                      },
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: Icon(
                          CupertinoIcons.person_2_fill,
                          size: 22,
                        )),
                    title: Text(loc.utilsComponentsDrawerText4, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Share.share("Start using Group Grit!\nhttps://groupgrit.io").then((value) {
                        AnalyticsEngine().logEvent("app_shared");
                      });
                    },
                  ),
                  /*
                  ListTile(
                    leading: CircleAvatar(
                        radius: 25,
                        backgroundColor:stravaConnected==true ? const Color.fromARGB(255, 149, 249, 152): const Color.fromARGB(109, 246, 148, 91),
                        child: Icon(
                          FontAwesomeIcons.strava,
                          size: 27,
                          color:stravaConnected==true ? Colors.green: Colors.orange,
                        )),
                    title: Text(
                      stravaConnected==true ? 'Connected' : 'Connect Strava',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: stravaConnected==true ?  Colors.green : Colors.orange,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      if (stravaConnected==true) {
                        await Strava.disconnectFromStrava();
                      } else {
                        await Strava.authenticateWithStrava();
                      }
                    },
                  ),*/
                  ListTile(
                    leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: Icon(
                          CupertinoIcons.question_circle,
                          size: 27,
                        )),
                    title: Text('Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(context: context, builder: (context) => SupportModal());
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        final userId = FirebaseAuth.instance.currentUser!.uid;
                        final tokenRef = FirebaseFirestore.instance.collection("users").doc(userId).collection("tokens");
                        final tokenDocs = await tokenRef.get();
                        final deviceToken = await FirebaseMessaging.instance.getToken();
                        if (deviceToken != null) {
                          if (tokenDocs.docs.isNotEmpty) {
                            final tokenDoc = tokenDocs.docs.firstWhere(
                              (doc) => doc.id == deviceToken,
                            );
                            await tokenRef.doc(tokenDoc.id).delete();
                          }
                        }
                        await AuthService().signout();
                      },
                      child: Container(
                          width: GGSize.screenWidth(context) * 0.8,
                          height: GGSize.screenHeight(context) * 0.057,
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(21)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.rightToBracket,
                                size: 20,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text("Log Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: GGSize.screenWidth(context),
      height: GGSize.screenHeight(context) * 0.4,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GGColors.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: GGSize.screenWidth(context) * 0.2,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 198, 196, 196),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(),
              )
            ],
          ),
          SizedBox(height: GGSize.screenHeight(context) * 0.025),
          Text('Live Chat Support coming soon...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'In the meantime, if you have any questions or need help, please email us at ',
                    style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: 'support@groupgrit.io',
                        style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse('mailto:support@groupgrit.io'));
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: GGSize.screenHeight(context) * 0.05),
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    'assets/images/logoIcon.jpg',
                    width: GGSize.screenWidth(context) * 0.24,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Version 1.0.1',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
