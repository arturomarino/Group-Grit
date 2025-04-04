import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/pages/Authentication/LoginPage.dart';
import 'package:group_grit/pages/User/EdiProfilePage.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:group_grit/utils/functions/auth_service.dart';
import 'package:group_grit/widget/profile_widget.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:group_grit/l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userFromPrevius;

  ProfilePage({required this.userFromPrevius});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final docRef = FirebaseFirestore.instance.collection("users").doc("${FirebaseAuth.instance.currentUser!.uid}");
  final Map<String, dynamic> user = {};
  void getDocument() {
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          user.addAll(data);
        });
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  @override
  void initState() {
    getDocument();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print(widget.userFromPrevius);
    //print(user);

    return Scaffold(
        backgroundColor: GGColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: GGColors.backgroundColor,
        ),
        body: ListView(physics: BouncingScrollPhysics(), children: [
          ProfileWidget(
            imagePath: user['photo_url'] ??'https://firebasestorage.googleapis.com/v0/b/group-grit-app.firebasestorage.app/o/standartProfilePage.avif?alt=media&token=c3b38564-1579-4440-8da4-410950dfeede',
            onClicked: () async {
              final result = await Navigator.of(context)
                  .push(
                MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                          user: user.isEmpty ? widget.userFromPrevius : user,
                        )),
              )
                  .then((value) {
                getDocument();
              });

              //setState(() {});
            },
          ),
          const SizedBox(height: 24),
          buildName(user.isEmpty ? widget.userFromPrevius : user),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                showModalBottomSheet(isScrollControlled: true, context: context, builder: (context) => DeleteUserModal());
              },
              child: Container(
                  width: GGSize.screenWidth(context) * 0.8,
                  height: GGSize.screenHeight(context) * 0.055,
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(21)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.person_crop_circle_badge_xmark, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Delete Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  )),
            ),
          ),
        ]));
  }

  Widget buildName(Map<String, dynamic> user) => Column(
        children: [
          Text(
            user['display_name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          SizedBox(height: 4),
          Text(
            '@' + user['username'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 7),
          Text(
            user['email'],
            style: TextStyle(color: Colors.grey),
          )
        ],
      );
}

class DeleteUserModal extends StatefulWidget {
  DeleteUserModal({
    Key? key,
  }) : super(key: key);

  @override
  State<DeleteUserModal> createState() => _DeleteUserModalState();
}

class _DeleteUserModalState extends State<DeleteUserModal> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _remoteConfig = FirebaseRemoteConfig.instance;

  bool _isLoading = false;
  
  @override
  void initState() {
    _initRemoteConfig();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> deleteUserData(BuildContext context, String userId) async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

    // 2️⃣ Elimina la sottocollezione "tokens" in "users"
    final tokenDocs = await userDocRef.collection('tokens').get();
    for (var doc in tokenDocs.docs) {
      await doc.reference.delete();
    }
    print("Token eliminati.");

    // 3️⃣ Elimina il documento utente
    await userDocRef.delete();
    print("Documento utente eliminato.");

    // 4️⃣ Elimina tutti i messaggi dell'utente nei gruppi
    final memberships = await FirebaseFirestore.instance.collection('memberships').where('userId', isEqualTo: userId).get();
    for (var doc in memberships.docs) {
      String groupId = doc['groupId'];

      final messagesQuery =
          await FirebaseFirestore.instance.collection('groups').doc(groupId).collection('messages').where('senderId', isEqualTo: userId).get();

      for (var messageDoc in messagesQuery.docs) {
        await messageDoc.reference.delete();
      }
    }
    print("Messaggi eliminati.");

    // 5️⃣ Elimina le membership e gestisce i gruppi
    for (var doc in memberships.docs) {
      String groupId = doc['groupId'];

      if (doc['role'] == 'admin') {
        final QuerySnapshot remainingMembers = await FirebaseFirestore.instance
            .collection('memberships')
            .where('groupId', isEqualTo: groupId)
            .where('userId', isNotEqualTo: userId)
            .get();

        if (remainingMembers.docs.isNotEmpty) {
          final newAdmin = remainingMembers.docs[0];
          await FirebaseFirestore.instance.collection('memberships').doc(newAdmin.id).update({'role': 'admin'});
        } else {
          // Nessun membro rimasto, elimina il gruppo
          await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
        }
      }

      await doc.reference.delete();
    }
    print("Membership eliminata.");

    // 6️⃣ Elimina le classifiche (`users_rankings`)
    final rankings = await FirebaseFirestore.instance.collection('users_rankings').where('userId', isEqualTo: userId).get();
    for (var doc in rankings.docs) {
      await doc.reference.delete();
    }
    print("Classifiche eliminate.");

    // 7️⃣ Elimina le sfide (`users_challenges`)
    final challenges = await FirebaseFirestore.instance.collection('users_challenges').where('userId', isEqualTo: userId).get();
    for (var doc in challenges.docs) {
      await doc.reference.delete();
    }
    print("Sfide eliminate.");

    // 8️⃣ Elimina la foto dell'utente da Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('user_photos/$userId');
    try {
      final fileExists = await storageRef.getDownloadURL().then((_) => true).catchError((_) => false);
      if (fileExists) {
        await storageRef.delete();
        print("Foto profilo eliminata.");
      }
    } catch (e) {
      print("Errore durante l'eliminazione della foto utente: $e");
    }

    // 9️⃣ Attendi e elimina l'utente da Firebase Auth
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/LoginPage',
      (_) => false,
    );
    await Future.delayed(Duration(seconds: 2));
    await FirebaseAuth.instance.currentUser!.delete();
    print("Account eliminato con successo.");
  }

  Future<void> deleteCurrentUser(BuildContext context, String email, String password) async {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("Nessun utente autenticato.");
        return;
      }

      String userId = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

      // 1️⃣ **Reautenticazione dell'utente**
      try {
        if (user.providerData[0].providerId == 'password') {
          print("Reauthentication with Password is required. Please sign in again.");
          try {
            AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
            await user.reauthenticateWithCredential(credential).then((value) async {
              if(value!=null){
                print("Reauthentication successful with Password.");
                await deleteUserData(context, userId);
              }
            });
          } on FirebaseAuthException catch (e) {
            setState(() {
              _isLoading = false;
            });
            print(e.code);
            String message = '';
            if (e.code == 'invalid-email') {
              message = loc.utilsFunctionsAuthServiceText7;
            } else if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
              message = loc.utilsFunctionsAuthServiceText14;
            } else if (e.code == 'user-disabled') {
              message = loc.utilsFunctionsAuthServiceText8;
            } else if (e.code == 'user-not-found') {
              message = loc.utilsFunctionsAuthServiceText9;
            } else if (e.code == 'network-request-failed') {
              message = loc.utilsFunctionsAuthServiceText10;
            }

            Fluttertoast.showToast(
              msg: message,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else if (user.providerData[0].providerId == 'google.com') {
          // Reauthenticate with Google
          print("Reauthentication with Google is required. Please sign in again.");
          AuthService().reauthenticateWithGoogle().then((value) async {
            if (value != null) {
              print("Reauthentication successful with Google.");
              await deleteUserData(context, userId);
            }
            setState(() {
              _isLoading = false;
            });
          });
          Fluttertoast.showToast(
            msg: "Reauthentication with Google...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else if (user.providerData[0].providerId == 'apple.com') {
          print("Reauthentication with Apple is required. Please sign in again.");
          AuthService().reauthenticateWithApple().then((value) async {
            if (value != null) {
              print("Reauthentication successful with Apple.");
              await deleteUserData(context, userId);
            }
            setState(() {
              _isLoading = false;
            });
          });
          Fluttertoast.showToast(
            msg: "Reauthentication with Apple...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          print("Unsupported authentication provider: ${user.providerData[0].providerId}");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Unsupported authentication provider: ${user.providerData[0].providerId}"),
            duration: Duration(seconds: 3),
          ));
        }
      } catch (e) {
        print("Error during reauthentication: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Reauthentication failed: $e"),
          duration: Duration(seconds: 3),
        ));
        return;
      }
    } catch (e) {
      print("Error while deleting the user: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error while deleting the user: $e"),
        duration: Duration(seconds: 5),
      ));
    }
  }

    _initRemoteConfig() async {
    await _remoteConfig.setDefaults({
      'showUserReAuth': true,
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        width: GGSize.screenWidth(context),
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text("Are you sure you want to delete User Data?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (FirebaseAuth.instance.currentUser!.providerData[0].providerId == 'password')
                Text("Enter your email and password to confirm",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: const Color.fromARGB(255, 117, 115, 115))),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (FirebaseAuth.instance.currentUser!.providerData[0].providerId == 'password' && _remoteConfig.getBool('showUserReAuth')==true)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
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
                          SizedBox(height: 7),
                          TextField(
                            controller: passwordController,
                            style: TextStyle(color: GGColors.primarytextColor),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                FontAwesomeIcons.lock,
                                color: GGColors.secondarytextColor,
                                size: 20,
                              ),
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
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                        width: GGSize.screenWidth(context) * 0.9,
                        height: 50,
                        decoration: BoxDecoration(color: const Color.fromARGB(68, 182, 180, 180), borderRadius: BorderRadius.circular(17)),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Dismiss", style: TextStyle(color: GGColors.primarytextColor)),
                        ))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(height: 10),
                  CupertinoButton(
                    padding: EdgeInsets.only(bottom: 35),
                    child: Container(
                        width: GGSize.screenWidth(context) * 0.9,
                        height: 50,
                        decoration: BoxDecoration(color: const Color.fromARGB(86, 243, 99, 89), borderRadius: BorderRadius.circular(17)),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                              SizedBox(width: 10),
                              if (_isLoading)
                                SizedBox(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.red,
                                  ),
                                  width: 15,
                                  height: 15,
                                ),
                            ],
                          ),
                        ))),
                    onPressed: () async {
                      await deleteCurrentUser(context, emailController.text.trim(), passwordController.text.trim());
                    },
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
