import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/components/Shimmers.dart' show MyGroupShimmer;
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';

class JoinGroupPage extends StatefulWidget {
  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  TextEditingController _groupCodeController = TextEditingController();
  bool isLoading = true;
  bool _showCircle = false;
  bool _showClearButton = false;

  @override
  void dispose() {
    _groupCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    fetchUserGroupIds();
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      setState(() {
        isLoading = false;
      });
    });

    super.initState();
  }

  // Get the group document
  final Map<String, dynamic> group = {};
  void getDocument(String groupID) {
    final docRef = FirebaseFirestore.instance.collection("groups").doc("${groupID}");
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          group.addAll(data);
        });
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  // Fetch all group IDs the user belongs to
  List<String> userGroupIds = [];

  Future<List<String>> fetchUserGroupIds() async {
    try {
      var querySnapshot =
          await FirebaseFirestore.instance.collection('memberships').where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();

      for (var doc in querySnapshot.docs) {
        userGroupIds.add(doc['groupId']);
      }
    } catch (e) {
      print("Error fetching user group IDs: $e");
    }
    return userGroupIds;
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom; // Altezza tastiera

    return Scaffold(
        backgroundColor: GGColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: GGColors.backgroundColor,
          title: Text(
            'Join Group',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Join a Private Group',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 23),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        Text("Enter Group Code", style: TextStyle(color: GGColors.primarytextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 7),
                  TextField(
                    controller: _groupCodeController,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: GGColors.primarytextColor),
                    inputFormatters: [UpperCaseTextFormatter()],
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                          child: Icon(
                            Icons.cancel,
                            size: 20,
                          ),
                          onTap: () {
                            _groupCodeController.clear();
                          }),
                      hintText: "BE22AA5F",
                      hintStyle: TextStyle(color: const Color.fromARGB(170, 82, 82, 82), fontWeight: FontWeight.w500),
                      filled: true,
                      fillColor: GGColors.buttonColor,
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
                        setState(() {
                          _showCircle = true;
                        });
                        getDocument(_groupCodeController.text.trim());

                        // Handle group joining logic here
                        Future.delayed(Duration(seconds: 2), () async {
                          var query = await FirebaseFirestore.instance
                              .collection('memberships')
                              .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                              .where('groupId', isEqualTo: group['id'])
                              .get();

                          if (query.docs.isEmpty) {
                            await FirebaseFirestore.instance.collection('memberships').add({
                              'userId': FirebaseAuth.instance.currentUser!.uid,
                              'groupId': group['id'],
                              'role': 'member', // Es: "member", "admin"
                              'joinedAt': FieldValue.serverTimestamp()
                            });
                            //Navigator.of(context).pus
                            Navigator.of(context, rootNavigator: true)
                                .popAndPushNamed('/GroupPage', arguments: {'groupId': group['id'], 'name': group['name']});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Joined group ${group['name']}'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            setState(() {
                              _showCircle = false;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Already members of the group ${group['name']}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            setState(() {
                              _showCircle = false;
                            });
                          }
                        });
                      },
                      child: Container(
                          width: GGSize.screenWidth(context),
                          height: GGSize.screenHeight(context) * 0.065,
                          decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(21)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Join Group", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                  Text("Join a Public group", style: TextStyle(color: GGColors.primarytextColor, fontSize: 23, fontWeight: FontWeight.bold)),
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('groups')
                        .where('private', isEqualTo: false) // Recupera solo i gruppi pubblici
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
                        return MyGroupShimmer();
                      }
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      
                      var allGroups = snapshot.data?.docs ?? [];

                      // Filtra i gruppi pubblici, rimuovendo quelli che l'utente ha già unito
                      var filteredGroups = allGroups.where((group) {
                        return !(userGroupIds.contains(group['id'])); // Escludi quelli che l'utente ha già unito
                      }).toList();

                      if (filteredGroups.isEmpty) {
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text('There are no public groups to join currently',
                              style: TextStyle(color: GGColors.primarytextColor, fontWeight: FontWeight.w500)),
                        ));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: filteredGroups.length,
                        itemBuilder: (context, index) {
                           var groupData = filteredGroups[index];
                          return Card(
                            elevation: 0,
                            color: GGColors.secondarytextColor,
                            child: Container(
                              decoration: BoxDecoration(
                                color: GGColors.buttonColor,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: GGSize.screenWidth(context) * 0.153,
                                      height: GGSize.screenHeight(context) * 0.07,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(12), // Se vuoi angoli arrotondati
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            groupData['photo_url'] ?? "", // Controlla che il valore non sia null
                                          ),
                                          fit: BoxFit.cover, // Ritaglia l'immagine per riempire il quadrato
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: GGSize.screenWidth(context) * 0.42,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                      //width: GGSize.screenWidth(context) * 0.4,
                                                      child: Text(
                                                        groupData['name'],
                                                        style: TextStyle(fontWeight: FontWeight.bold, color: GGColors.primarytextColor, fontSize: 17),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                              Container(
                                                      //width: GGSize.screenWidth(context) * 0.4,
                                                      child: Text(
                                                        groupData['description'],
                                                        style: TextStyle(fontWeight: FontWeight.w600, color: GGColors.secondarytextColor, fontSize: 13),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 3,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      CupertinoButton(
                                          child: Container(
                                            width: GGSize.screenWidth(context) * 0.15,
                                            height: GGSize.screenHeight(context) * 0.04,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(55, 0, 103, 238),
                                              borderRadius: BorderRadius.all(Radius.circular(9)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                              child: Center(
                                                child: Text(
                                                  "Join",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: GGColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 17),
                                                ),
                                              ),
                                            ),
                                          ),
                                          onPressed: () {
                                            // Handle group joining logic here
                                            Future.delayed(Duration(seconds: 2), () async {
                                              var query = await FirebaseFirestore.instance
                                                  .collection('memberships')
                                                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                                                  .where('groupId', isEqualTo: groupData['id'])
                                                  .get();

                                              if (query.docs.isEmpty) {
                                                await FirebaseFirestore.instance.collection('memberships').add({
                                                  'userId': FirebaseAuth.instance.currentUser!.uid,
                                                  'groupId': groupData['id'],
                                                  'role': 'member', // Es: "member", "admin"
                                                  'joinedAt': FieldValue.serverTimestamp()
                                                });
                                                //Navigator.of(context).pus
                                                Navigator.of(context, rootNavigator: true).popAndPushNamed('/GroupPage',
                                                    arguments: {'groupId': groupData['id'], 'name': groupData['name']});
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Joined group ${group['name']}'),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Already members of the group ${group['name']}'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            });
                                          })
                                    ],
                                  )),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
