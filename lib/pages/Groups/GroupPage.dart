import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/pages/Chat/ChatPage.dart';
import 'package:group_grit/pages/Groups/EditGroupPage.dart';
import 'package:group_grit/pages/Groups/LeaderboardPage.dart';
import 'package:group_grit/pages/Groups/MembersListPage.dart';
import 'package:group_grit/pages/Groups/ShowVideoPage.dart';
import 'package:group_grit/utils/components/myAppBar.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';
import 'package:http/http.dart' as http;
import 'package:group_grit/pages/Groups/UploadVideoPage.dart'; // Ensure this file exists at the specified path
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

class GroupPage extends StatefulWidget {
  GroupPage({Key? key}) : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  String _uploadStatus = '';
  // API Key di api.video
  final String apiKey = "x7tsgVXJHnUdxFFMSfN0MYkJU6NFtOLhUmDEJFbrXsM";

  final docRef = FirebaseFirestore.instance.collection("users");

  final Map<String, dynamic> user = {};
  final List<Map<String, dynamic>> userList = [];

  void getDocument(String? path) {
    docRef.doc(path).get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          userList.add(data);
        });
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  Future<List<DocumentSnapshot>> getUserChallenges(String groupId, String userId) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users_challenges').where('groupId', isEqualTo: groupId).where('userId', isEqualTo: userId).get();
    return querySnapshot.docs;
  }

  List<DocumentSnapshot> userChallenges = [];

  void fetchUserChallenges(String groupId, String userId) async {
    List<DocumentSnapshot> challenges = await getUserChallenges(groupId, userId);
    setState(() {
      userChallenges = challenges;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      fetchUserChallenges(arguments['groupId'], FirebaseAuth.instance.currentUser!.uid);
      _fetchGroupData(arguments['groupId']);
    });
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  DocumentSnapshot? groupData;
  bool expiredChallengesExist = false;

  Future<void> _fetchGroupData(String groupId) async {
    QuerySnapshot expiredChallenges = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('challenges')
        .where('endDateTime', isLessThan: DateTime.now())
        .get();

    if (groupId.isNotEmpty) {
      DocumentSnapshot group = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();

      setState(() {
        if (expiredChallenges.docs.isNotEmpty) {
          expiredChallengesExist = true;
        }
        groupData = group;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Invalid group document ID",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }
  Future<void> _getGroupDetails(String groupId) async {
    try {
      DocumentSnapshot groupSnapshot =
          await FirebaseFirestore.instance.collection('groups').doc(groupId).get();

      if (groupSnapshot.exists) {
        setState(() {
          groupData = groupSnapshot;
          final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
          arguments['name'] = groupSnapshot['name'];
        });
      } else {
        Fluttertoast.showToast(
          msg: "Group not found",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching group details",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      print("Error fetching group details: $e");
    }
  }

  Future<void> _deleteChallenge(BuildContext context, String apiKey, List<DocumentSnapshot> userChallenges, String challengeId) async {
    final videoUrl = userChallenges.firstWhere((uc) => uc['challengeId'] == challengeId)['videoUrl'];
    final videoId = videoUrl.split('/')[4]; // Extract the video ID from the URL
    final deleteUrl = "https://sandbox.api.video/videos/$videoId";
    print("Deleting video at $deleteUrl");

    try {
      final deleteResponse = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (deleteResponse.statusCode == 204) {
        await FirebaseFirestore.instance
            .collection('users_challenges')
            .doc(userChallenges.firstWhere((uc) => uc['challengeId'] == challengeId).id)
            .delete();

        userChallenges.removeWhere((uc) => uc['challengeId'] == challengeId);

        Navigator.pop(context);
      } else if (deleteResponse.statusCode == 404) {
        Fluttertoast.showToast(
          msg: "Video not found",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        print("Video not found: ${deleteResponse.body}");
      } else {
        Fluttertoast.showToast(
          msg: "Error deleting video, try again",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        print("Error deleting video: ${deleteResponse.body}");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error deleting video, try again",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Tab> _tabs = [
    Tab(
      text: "Challenges",
    ),
    Tab(
      text: "Group Activity",
    ),
  ];

  bool _showExpired = false;

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;

    return Scaffold(
        backgroundColor: GGColors.backgroundColor,
        /*AppBar(
        backgroundColor: GGColors.backgroundColor,
        actions: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Share.share("Join the group ${arguments['name']} on Group Grit! The group code is ${arguments['groupId']}");
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: GGColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Icon(Icons.person_add, color: Colors.white, size: 18),
                      SizedBox(width: 5),
                      Text("Invite", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),*/

        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: NestedScrollView(
                physics: NeverScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).padding.top + 60,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: GGColors.buttonColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: GGSize.screenWidth(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => EditGroupPage(
                                          groupId: arguments['groupId'],
                                          groupData: groupData!,
                                        ),
                                      )).then((value) {
                                        _getGroupDetails(arguments['groupId']);
                                      });
                                    },
                                    child: Icon(CupertinoIcons.info, color: Colors.blue, size: 24),
                                  ),
                                    Container(
                                    width: GGSize.screenWidth(context) * 0.4,
                                    child: Text(
                                      arguments['name'],
                                      style: TextStyle(fontSize: 16, color: GGColors.primarytextColor, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    ),
                                  Spacer(),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => MembersListPage(groupId: arguments['groupId']),
                                      ));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                      child: Icon(CupertinoIcons.person_2_fill, color: Colors.black, size: 22),
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => ChatPage(groupId: arguments['groupId']),
                                      ));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                      child: Icon(Icons.message, color: Colors.black, size: 20),
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => LeaderboardPage(groupId: arguments['groupId']),
                                      ));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                      child: Icon(FontAwesomeIcons.trophy, color: Colors.black, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: double.infinity,
                            height: GGSize.screenHeight(context) * 0.25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(19),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  groupData?['photo_url'] ?? arguments['photo_url'] ?? "", // Evita null e usa il fallback
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            height: GGSize.screenHeight(context) * 0.043,
                            decoration: BoxDecoration(
                              color: GGColors.buttonColor,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: TabBar(
                              dividerHeight: 0,
                              tabs: _tabs,
                              splashBorderRadius: BorderRadius.circular(40),
                              controller: _tabController,
                              indicator: BoxDecoration(borderRadius: BorderRadius.circular(40), color: GGColors.primaryColor),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          CupertinoButton(
                            child: Container(
                              decoration: BoxDecoration(
                                color: GGColors.primaryColor.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(19),
                              ),
                              width: GGSize.screenWidth(context),
                              height: 43,
                              child: Center(
                                  child: Text("Create Challenge",
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: GGColors.primaryColor))),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/CreateChallengePage', arguments: {'groupId': arguments['groupId']});
                            },
                            padding: EdgeInsets.zero,
                          )
                        ],
                      ),
                    ),
                  )
                ],
                body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('groups')
                            .doc(arguments['groupId'])
                            .collection('challenges')
                            .where('endDateTime', isGreaterThan: _showExpired ? DateTime(1900) : DateTime.now())
                            .where('endDateTime', isLessThan: _showExpired ? DateTime.now() : DateTime(2100))
                            .orderBy('endDateTime', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center();
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Column(
                              children: [
                                Container(
                                  child: Lottie.asset('assets/lotties/Training.json', fit: BoxFit.contain),
                                  height: GGSize.screenHeight(context) * 0.3,
                                  //width: GGSize.screenWidth(context) * 0.1,
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              Visibility(
                                visible: expiredChallengesExist,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: CupertinoButton(
                                    onPressed: () {
                                      setState(() {
                                        _showExpired = !_showExpired;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    child: Row(
                                      mainAxisAlignment: _showExpired ? MainAxisAlignment.start : MainAxisAlignment.end,
                                      children: [
                                        Visibility(
                                            visible: _showExpired,
                                            child: Icon(
                                              CupertinoIcons.back,
                                              color: Colors.black,
                                              size: 19,
                                            )),
                                        Text(
                                          _showExpired ? "Back" : "Show Expired Challenges",
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                        SizedBox(width: 5),
                                        Visibility(
                                            visible: !_showExpired,
                                            child: RotatedBox(
                                                child: Icon(
                                                  CupertinoIcons.back,
                                                  color: Colors.black,
                                                  size: 19,
                                                ),
                                                quarterTurns: 2)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    var challenge = snapshot.data!.docs[index];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 7),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: GGColors.buttonColor,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 18),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 15),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 5),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      //Color.fromRGBO(255, 30, 0, 0.1) RED
                                                      decoration: BoxDecoration(
                                                        color: challenge['endDateTime'].toDate().isBefore(DateTime.now())
                                                            ? Color.fromRGBO(255, 30, 0, 0.1)
                                                            : GGColors.primaryColor.withOpacity(0.25),
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                                      child: Text(
                                                        challenge['endDateTime'].toDate().isBefore(DateTime.now())
                                                            ? 'Expired'
                                                            : challenge['startDateTime'].toDate().isAfter(DateTime.now())
                                                                ? 'Starts in: ${_formatDuration(challenge['startDateTime'].toDate().difference(DateTime.now()))}'
                                                                : 'Ends in: ${_formatDuration(challenge['endDateTime'].toDate().difference(DateTime.now()))}',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          color: challenge['endDateTime'].toDate().isBefore(DateTime.now())
                                                              ? Colors.red
                                                              : GGColors.primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                challenge['activityName'],
                                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: GGColors.primarytextColor),
                                                textAlign: TextAlign.start,
                                              ),
                                              Visibility(
                                                visible: challenge['activityDescription'] == '' ? false : true,
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Visibility(
                                                        visible: challenge['activityDescription'] == '' ? false : true,
                                                        child: Icon(CupertinoIcons.info, color: GGColors.primaryColor, size: 18)),
                                                    SizedBox(width: 5),
                                                    Expanded(
                                                      child: Text(
                                                        challenge['activityDescription'],
                                                        style:
                                                            TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GGColors.secondarytextColor),
                                                        textAlign: TextAlign.start,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Visibility(
                                                      visible: !challenge['endDateTime'].toDate().isBefore(DateTime.now()) &&
                                                          userChallenges.any((uc) =>
                                                              uc['challengeId'] == challenge.id && (uc['videoUrl'] != null || uc['excuse'] != null)),
                                                      child: CupertinoButton(
                                                        padding: EdgeInsets.zero,
                                                        onPressed: () {
                                                          showModalBottomSheet(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return DeleteVideoBottomSheet(
                                                                isExcuse: userChallenges
                                                                    .any((uc) => uc['challengeId'] == challenge.id && uc['excuse'] != null),
                                                                onTap: () {
                                                                  if (userChallenges
                                                                      .any((uc) => uc['challengeId'] == challenge.id && uc['excuse'] != null)) {
                                                                    FirebaseFirestore.instance
                                                                        .collection('users_challenges')
                                                                        .doc(userChallenges.firstWhere((uc) => uc['challengeId'] == challenge.id).id)
                                                                        .delete();
                                                                    userChallenges.removeWhere((uc) => uc['challengeId'] == challenge.id);
                                                                    Fluttertoast.showToast(
                                                                      msg: "Excuse deleted!",
                                                                      toastLength: Toast.LENGTH_LONG,
                                                                      gravity: ToastGravity.TOP,
                                                                      backgroundColor: Colors.red,
                                                                      textColor: Colors.white,
                                                                      fontSize: 14.0,
                                                                    );
                                                                    Navigator.pop(context);
                                                                  } else {
                                                                    _deleteChallenge(context, apiKey, userChallenges, challenge.id).then((value) {
                                                                      Future.delayed(Duration(seconds: 1), () {
                                                                        fetchUserChallenges(
                                                                            arguments['groupId'], FirebaseAuth.instance.currentUser!.uid);
                                                                        Fluttertoast.showToast(
                                                                          msg: "Video deleted!",
                                                                          toastLength: Toast.LENGTH_LONG,
                                                                          gravity: ToastGravity.TOP,
                                                                          backgroundColor: Colors.red,
                                                                          textColor: Colors.white,
                                                                          fontSize: 14.0,
                                                                        );
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 15),
                                                          child: Container(
                                                            height: 40,
                                                            width: 40,
                                                            decoration: BoxDecoration(
                                                              color: Color.fromRGBO(80, 83, 91, 0.1),
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: Center(
                                                                child: Icon(
                                                                  CupertinoIcons.delete,
                                                                  color: Color.fromRGBO(80, 83, 91, 1),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                  Visibility(
                                                    visible:
                                                        (!userChallenges.any((uc) => uc['challengeId'] == challenge.id && uc['excuse'] == null) &&
                                                                !challenge['endDateTime'].toDate().isBefore(DateTime.now()) &&
                                                                !challenge['startDateTime'].toDate().isAfter(DateTime.now())) ||
                                                            (userChallenges.any((uc) => uc['challengeId'] == challenge.id && uc['excuse'] != null) &&
                                                                challenge['endDateTime'].toDate().isBefore(DateTime.now())),
                                                    child: Expanded(
                                                      child: CupertinoButton(
                                                        pressedOpacity:
                                                            (userChallenges.any((uc) => uc['challengeId'] == challenge.id && uc['excuse'] != null))
                                                                ? 1
                                                                : 0.4,
                                                        padding: EdgeInsets.only(
                                                            left:
                                                                userChallenges.any((uc) => uc['challengeId'] == challenge.id && uc['excuse'] != null)
                                                                    ? 10
                                                                    : 0),
                                                        borderRadius: BorderRadius.circular(10),
                                                        onPressed: () async {
                                                          if (!userChallenges
                                                              .any((uc) => uc['challengeId'] == challenge.id && uc['excuse'] != null)) {
                                                            Navigator.pushNamed(context, '/GiveExcusePage', arguments: {
                                                              'groupId': arguments['groupId'],
                                                              'challengeId': challenge.id,
                                                            }).then((value) {
                                                              Future.delayed(Duration(seconds: 1), () {
                                                                fetchUserChallenges(arguments['groupId'], FirebaseAuth.instance.currentUser!.uid);
                                                              });
                                                            });
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 15),
                                                          child: Container(
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                              color: const Color.fromRGBO(255, 30, 0, 0.1),
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                                              child: Center(
                                                                child: Text(
                                                                  (userChallenges
                                                                          .any((uc) => uc['challengeId'] == challenge.id && uc['excuse'] != null))
                                                                      ? 'Excuse sent: ' +
                                                                          '${userChallenges.firstWhere((uc) => uc['challengeId'] == challenge.id)['excuse']}'
                                                                      : 'Give Excuse',
                                                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: (userChallenges.any((uc) => uc['challengeId'] == challenge.id && uc['excuse'] != null))
                                                        ? false
                                                        : true,
                                                    child: Expanded(
                                                      child: CupertinoButton(
                                                        pressedOpacity: userChallenges.any((uc) =>
                                                                    uc['challengeId'] == challenge.id && uc['status'] == 'marked_completed') ||
                                                                (challenge['endDateTime'].toDate().isBefore(DateTime.now()) &&
                                                                    !userChallenges.any((uc) => uc['challengeId'] == challenge.id)) ||
                                                                challenge['startDateTime'].toDate().isAfter(DateTime.now())
                                                            ? 1
                                                            : 0.4,
                                                        padding: EdgeInsets.only(
                                                            left: userChallenges.any((uc) =>
                                                                        uc['challengeId'] == challenge.id && uc['status'] == 'marked_completed') ||
                                                                    (challenge['endDateTime'].toDate().isBefore(DateTime.now()) &&
                                                                        !userChallenges.any((uc) => uc['challengeId'] == challenge.id)) ||
                                                                    challenge['startDateTime'].toDate().isAfter(DateTime.now())
                                                                ? 0
                                                                : 10),
                                                        onPressed: () async {
                                                          if (challenge['startDateTime'].toDate().isAfter(DateTime.now())) {
                                                            Fluttertoast.showToast(
                                                              msg: "Challenge not started yet",
                                                              toastLength: Toast.LENGTH_LONG,
                                                              gravity: ToastGravity.TOP,
                                                              backgroundColor: Colors.purple,
                                                              textColor: Colors.white,
                                                              fontSize: 14.0,
                                                            );
                                                          } else if (challenge['endDateTime'].toDate().isBefore(DateTime.now()) &&
                                                              !userChallenges.any((uc) => uc['challengeId'] == challenge.id)) {
                                                            Fluttertoast.showToast(
                                                              msg: "You can no longer send a challenge",
                                                              toastLength: Toast.LENGTH_LONG,
                                                              gravity: ToastGravity.TOP,
                                                              backgroundColor: Colors.grey,
                                                              textColor: Colors.white,
                                                              fontSize: 14.0,
                                                            );
                                                          } else if (userChallenges
                                                              .any((uc) => uc['challengeId'] == challenge.id && uc['status'] == 'marked_completed')) {
                                                            return;
                                                          } else if (challenge['videoUploadNeeded'] == 'No') {
                                                            await FirebaseFirestore.instance.collection('users_challenges').add({
                                                              'userId': FirebaseAuth.instance.currentUser!.uid,
                                                              'groupId': arguments['groupId'],
                                                              'challengeId': challenge.id,
                                                              'status': 'marked_completed',
                                                              'excuse': null,
                                                              'videoUrl': null,
                                                              'time': DateTime.now(),
                                                            });

                                                            final docRef = FirebaseFirestore.instance
                                                                .collection('users_rankings')
                                                                .doc('${FirebaseAuth.instance.currentUser!.uid}_${arguments['groupId']}');
                                                            final docSnapshot = await docRef.get();

                                                            if (docSnapshot.exists) {
                                                              docRef.update({
                                                                "completedChallenges": FieldValue.increment(1), // Challenge totali completate
                                                                "streak":
                                                                    FieldValue.increment(1), // Numero di challenge completate di fila senza scuse
                                                              }).then((value) {
                                                                Future.delayed(Duration(seconds: 1), () {
                                                                  fetchUserChallenges(arguments['groupId'], FirebaseAuth.instance.currentUser!.uid);
                                                                });
                                                              });
                                                              ;
                                                            } else {
                                                              docRef.set({
                                                                "userId": FirebaseAuth.instance.currentUser!.uid,
                                                                "groupId": arguments['groupId'],
                                                                "completedChallenges": 1, // Prima challenge completata
                                                                "streak": 1, // Prima challenge completata di fila senza scuse
                                                              }).then((value) {
                                                                Future.delayed(Duration(seconds: 1), () {
                                                                  fetchUserChallenges(arguments['groupId'], FirebaseAuth.instance.currentUser!.uid);
                                                                });
                                                              });
                                                              ;
                                                            }
                                                          } else if (userChallenges.any((uc) => uc['challengeId'] == challenge.id)) {
                                                            print(userChallenges.where((uc) => uc['challengeId'] == challenge.id).first['videoUrl']);

                                                            Navigator.of(context).push(MaterialPageRoute(
                                                              builder: (context) => ShowVideoPage(
                                                                  videoUrl: Uri.parse(userChallenges
                                                                      .where((uc) => uc['challengeId'] == challenge.id)
                                                                      .first['videoUrl'])),
                                                            ));
                                                          } else {
                                                            Navigator.of(context)
                                                                .push(MaterialPageRoute(
                                                              builder: (context) => UploadVideoPage(
                                                                idChallenge: challenge.id,
                                                                idGruppo: arguments['groupId'],
                                                              ),
                                                            ))
                                                                .then((value) {
                                                              Future.delayed(Duration(seconds: 1), () {
                                                                fetchUserChallenges(arguments['groupId'], FirebaseAuth.instance.currentUser!.uid);
                                                              });
                                                            });
                                                          }
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 15),
                                                          child: Container(
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                              color: userChallenges.any(
                                                                      (uc) => uc['challengeId'] == challenge.id && uc['status'] == 'marked_completed')
                                                                  ? Color.fromRGBO(6, 203, 154, 0.231)
                                                                  : challenge['endDateTime'].toDate().isBefore(DateTime.now()) &&
                                                                          !userChallenges.any((uc) => uc['challengeId'] == challenge.id)
                                                                      ? const Color.fromARGB(45, 147, 147, 147)
                                                                      : challenge['startDateTime'].toDate().isAfter(DateTime.now())
                                                                          ? const Color.fromARGB(50, 163, 110, 243)
                                                                          : challenge['videoUploadNeeded'] != 'No'
                                                                              ? GGColors.primaryColor
                                                                              : Color.fromRGBO(6, 203, 154, 1),
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                                              child: Center(
                                                                child: Text(
                                                                  userChallenges.any((uc) =>
                                                                          uc['challengeId'] == challenge.id && uc['status'] == 'marked_completed')
                                                                      ? 'Completed'
                                                                      : challenge['startDateTime'].toDate().isAfter(DateTime.now())
                                                                          ? 'Get ready to compete'
                                                                          : challenge['endDateTime'].toDate().isBefore(DateTime.now()) &&
                                                                                  !userChallenges.any((uc) => uc['challengeId'] == challenge.id)
                                                                              ? 'Challenge not sent'
                                                                              : challenge['videoUploadNeeded'] == 'No'
                                                                                  ? 'Mark as Completed'
                                                                                  : userChallenges.any((uc) => uc['challengeId'] == challenge.id)
                                                                                      ? 'View Video'
                                                                                      : 'Upload Video',
                                                                  style: TextStyle(
                                                                      color: userChallenges.any((uc) =>
                                                                              uc['challengeId'] == challenge.id && uc['status'] == 'marked_completed')
                                                                          ? Color.fromRGBO(6, 203, 154, 1)
                                                                          : challenge['endDateTime'].toDate().isBefore(DateTime.now()) &&
                                                                                  !userChallenges.any((uc) => uc['challengeId'] == challenge.id)
                                                                              ? Colors.black
                                                                              : challenge['startDateTime'].toDate().isAfter(DateTime.now())
                                                                                  ? Colors.purple
                                                                                  : Colors.white,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 15),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 15,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    ListView(
                        //physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.all(16),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text("Recent Group Activity",
                                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: GGColors.primarytextColor)),
                          ),
                          Text(
                            "Group uploads or excuses given for most recent group activity:",
                            style: TextStyle(fontWeight: FontWeight.w600, color: GGColors.secondarytextColor),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users_challenges')
                                .where('groupId', isEqualTo: arguments['groupId'])
                                .orderBy('time', descending: true)
                                .snapshots(), // Usa snapshots() invece di get()
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return SizedBox(
                                  child: Lottie.asset('assets/lotties/NoData.json'),
                                  height: GGSize.screenHeight(context) * 0.2,
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var userChallenge = snapshot.data!.docs[index];
                                  return FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('users').doc(userChallenge['userId']).get(),
                                    builder: (context, userSnapshot) {
                                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                                        return Center();
                                      }
                                      if (!userSnapshot.hasData || userSnapshot.data == null) {
                                        return Container();
                                      }
                                      var userData = userSnapshot.data!;

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 7),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: GGColors.buttonColor,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 30.0,
                                                  backgroundColor: Colors.transparent,
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl: userData['photo_url'],
                                                      fit: BoxFit.cover,
                                                      width: 60,
                                                      height: 60,
                                                      placeholder: (context, url) => CircularProgressIndicator(), // Mostra un caricamento
                                                      errorWidget: (context, url, error) =>
                                                          Icon(Icons.person, size: 60, color: Colors.grey), // Icona di fallback
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: GGSize.screenWidth(context) * 0.7,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 15),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "@${userData['username']}",
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                                color: GGColors.primarytextColor,
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            Text(
                                                              "${_formatDuration(DateTime.now().difference(userChallenge['time'].toDate()))} ago",
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w600,
                                                                color: GGColors.secondarytextColor.withOpacity(0.6),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  userChallenge['excuse'] != null
                                                                      ? "Excuse: ${userChallenge['excuse']}"
                                                                      : "Uploaded a video",
                                                                  style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: GGColors.secondarytextColor,
                                                                  ),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 2,
                                                                ),
                                                              ),
                                                              Visibility(
                                                                visible: userChallenge['excuse'] == null,
                                                                child: GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(context).push(MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          ShowVideoPage(videoUrl: Uri.parse(userChallenge['videoUrl'])),
                                                                    ));
                                                                  },
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(top: 0),
                                                                    child: CircleAvatar(
                                                                      radius: 12,
                                                                      backgroundColor: GGColors.primaryColor,
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(left: 2),
                                                                        child: Icon(
                                                                          CupertinoIcons.play_fill,
                                                                          size: 14,
                                                                          color: Colors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
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
                          )
                        ]),
                  ],
                ),
              ),
            ),
            FrostedAppBar(
              actions: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Share.share("Join the group ${arguments['name']} on Group Grit! The group code is ${arguments['groupId']}");
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        color: GGColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Icon(Icons.person_add, color: Colors.white, size: 18),
                            SizedBox(width: 5),
                            Text("Invite", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              blurStrengthX: 10,
              blurStrengthY: 10,
              leading: Icon(CupertinoIcons.back),
              title: Container(
                alignment: Alignment.centerLeft,
                height: GGSize.screenHeight(context) * 0.03,
                //width: GGSize.screenWidth(context) * 0.1,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  
                ),
              ),
            ),
          ],
        ));
  }
}

Widget _buildDropdownMenu(BuildContext context, Map<dynamic, dynamic> arguments) {
  return DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      borderRadius: BorderRadius.circular(15),
      dropdownColor: GGColors.buttonColor,
      icon: Icon(Icons.more_vert, color: GGColors.primaryColor),
      items: [
        DropdownMenuItem<String>(
          value: 'copy_code',
          child: Row(
            children: [
              Icon(Icons.copy, color: GGColors.primaryColor),
              SizedBox(width: 8),
              Text('Copy Group Code'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'exit_group',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Exit Group', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onChanged: (value) async {
        if (value == 'exit_group') {
          await FirebaseFirestore.instance
              .collection('memberships')
              .where('groupId', isEqualTo: arguments['groupId'])
              .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .get()
              .then((snapshot) {
            for (DocumentSnapshot ds in snapshot.docs) {
              ds.reference.delete();
            }
          });
          Navigator.pop(context);
        } else if (value == 'copy_code') {
          await Clipboard.setData(ClipboardData(text: arguments['groupId']));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Group code copied to clipboard'),
            duration: Duration(seconds: 2),
          ));
        }
      },
    ),
  );
}

class DeleteVideoBottomSheet extends StatefulWidget {
  final VoidCallback onTap;
  final bool isExcuse;

  const DeleteVideoBottomSheet({required this.onTap, required this.isExcuse});

  @override
  State<DeleteVideoBottomSheet> createState() => _DeleteVideoBottomSheetState();
}

class _DeleteVideoBottomSheetState extends State<DeleteVideoBottomSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GGColors.buttonColor,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.isExcuse ? 'Delete Excuse Sended' : 'Delete Challenge Sended',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            widget.isExcuse ? 'Are you sure you want to delete this sended excuse?' : 'Are you sure you want to delete this sended challenge?',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 179, 208, 245),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: GGColors.primaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  widget.onTap();
                },
                child: Row(
                  children: [
                    Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    Visibility(visible: _isLoading, child: SizedBox(width: 5)),
                    Visibility(
                        visible: _isLoading,
                        child: SizedBox(
                            height: 10,
                            width: 10,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 1,
                            )))
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: GGSize.screenHeight(context) * 0.04),
        ],
      ),
    );
  }
}
