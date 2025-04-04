import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart' show CupertinoButton, CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/components/Shimmers.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:shimmer/shimmer.dart';

class MyGroupsPage extends StatefulWidget {
  @override
  State<MyGroupsPage> createState() => _MyGroupsPageState();
}

class _MyGroupsPageState extends State<MyGroupsPage> {
  bool isLoading = true;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GGColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: GGColors.backgroundColor,
        title: Text(
          'My Groups',
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
                children: [
                  Divider(),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('memberships')
                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
                        return MyGroupShimmer();
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(30),
                                  child: CircleAvatar(
                                    radius: GGSize.screenWidth(context) * 0.2,
                                    backgroundColor: GGColors.buttonColor,
                                    child: Icon(
                                      CupertinoIcons.person_3,
                                      size: GGSize.screenWidth(context) * 0.24,
                                      color: GGColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                'You aren\'t a member of any groups yet!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: GGColors.primarytextColor, fontWeight: FontWeight.bold, fontSize: 25),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40),
                              child: Text(
                                'Join a group to start sharing your progress and get motivated by others!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: GGColors.secondarytextColor, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  Navigator.pushNamed(context, '/JoinGroupPage');
                                },
                                child: Container(
                                    width: GGSize.screenWidth(context),
                                    height: GGSize.screenHeight(context) * 0.065,
                                    decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(21)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Join Group", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                      ],
                                    )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  Navigator.pushNamed(context, '/CreateGroupPage');
                                },
                                child: Container(
                                    width: GGSize.screenWidth(context),
                                    height: GGSize.screenHeight(context) * 0.065,
                                    decoration: BoxDecoration(color: GGColors.primaryColor, borderRadius: BorderRadius.circular(21)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Create Group", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                      ],
                                    )),
                              ),
                            ),
                          ],
                        );
                      }

                      // Lista di gruppi a cui l'utente appartiene
                      var memberships = snapshot.data!.docs;

                      return FutureBuilder<List<DocumentSnapshot>>(
                        future: Future.wait(memberships.map((membership) {
                          String groupId = membership['groupId'];
                          return FirebaseFirestore.instance.collection('groups').doc(groupId).get();
                        }).toList()),
                        builder: (context, groupSnapshots) {
                          if (groupSnapshots.connectionState == ConnectionState.waiting || isLoading) {
                            return MyGroupShimmer();
                          }
                          if (!groupSnapshots.hasData || groupSnapshots.data!.isEmpty) {
                            return ListTile(title: Text("Gruppo non trovato"));
                          }

                          var groupDataList = groupSnapshots.data!;

                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: groupDataList.length,
                            itemBuilder: (context, index) {
                              var groupData = groupDataList[index];
                              String groupId = memberships[index]['groupId'];

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                child: Card(
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
                                                        "View",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(color: GGColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 17),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pushNamed(context, '/GroupPage', arguments: {
                                                    'groupId': groupId,
                                                    'name': groupData['name'],
                                                    'photo_url': groupData['photo_url']
                                                  }).then((value) {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    Future.delayed(Duration(milliseconds: 200)).then((value) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    });
                                                  });
                                                })
                                          ],
                                        )),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
