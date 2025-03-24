import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/components/Shimmers.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:group_grit/utils/constants/size.dart';

class LeaderboardPage extends StatefulWidget {
  final String groupId;

  LeaderboardPage({required this.groupId});
  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool _isLoading = true;
  double iconSize = 20;

  String ordering = 'challenges';

  @override
  void initState() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: GGColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Leaderboard',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: GGColors.backgroundColor,
          actionsPadding: EdgeInsets.only(right: 10),
          actions: [
            PopupMenuButton<String>(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              onSelected: (String result) {
                // Handle the selected sorting option
                setState(() {
                  ordering = result;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'challenges',
                  child: Text('Order by Challenges completed 🏆'),
                ),
                const PopupMenuItem<String>(
                  value: 'streak',
                  child: Text('Order by Streak 🔥'),
                ),
                const PopupMenuItem<String>(
                  value: 'excuses',
                  child: Text('Order by Excuses 😔'),
                ),
              ],
              icon: Icon(
                FontAwesomeIcons.arrowDownWideShort,
                color: Colors.black,
                size: 20,
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Divider(),
                //LeaderboardShimmer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: GGSize.screenWidth(context) * 0.1, vertical: 10),
                  child: Text(
                    'Metrics for Current Streak, Challenge Completed and Excuses Given.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: GGColors.secondarytextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users_rankings')
                      .where('groupId', isEqualTo: widget.groupId)
                      .orderBy(
                          ordering == 'challenges'
                              ? 'completedChallenges'
                              : ordering == 'streak'
                                  ? 'streak'
                                  : 'excusesSent',
                          descending: ordering != 'excuses')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LeaderboardShimmer();
                    }
                    if (!snapshot.hasData) {
                      return Text('No data available');
                    }
                    final leaderboardData = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: leaderboardData.length,
                      itemBuilder: (context, index) {
                        var data = leaderboardData[index].data() as Map<String, dynamic>;
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(data['userId']).get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting || _isLoading) {
                              return LeaderboardShimmer();
                            }
                            if (!userSnapshot.hasData || userSnapshot.data == null) {
                              return Container();
                            }
                            var userData = userSnapshot.data!;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: GGColors.buttonColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30.0,
                                        backgroundColor: Colors.transparent,
                                        child: ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: userData['photo_url'] ?? "",
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
                                        width: GGSize.screenWidth(context) * 0.54,
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
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 5),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(FontAwesomeIcons.fire, color: Colors.red, size: iconSize),
                                                        SizedBox(width: 5),
                                                        Text('${data['streak']}',
                                                            style: TextStyle(color: GGColors.secondarytextColor, fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(FontAwesomeIcons.trophy, color: Colors.orange, size: iconSize),
                                                        SizedBox(width: 7),
                                                        Text('${data['completedChallenges']} Completed',
                                                            style: TextStyle(color: GGColors.secondarytextColor, fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(FontAwesomeIcons.faceMeh, color: GGColors.primaryColor, size: iconSize),
                                                        SizedBox(width: 5),
                                                        Text(data['excusesSent'] == null ? '0' : '${data['excusesSent']}',
                                                            style: TextStyle(color: GGColors.secondarytextColor, fontWeight: FontWeight.bold)),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: GGSize.screenHeight(context) * 0.05,
                                        width: GGSize.screenHeight(context) * 0.05,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(59, 0, 103, 238),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                            child: Text('#${index + 1}',
                                                style: TextStyle(color: GGColors.primaryColor, fontSize: 20, fontWeight: FontWeight.bold))),
                                      )
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
                /*Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: GGColors.buttonColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30.0,
                            backgroundImage: NetworkImage(
                                'https://media.istockphoto.com/id/1437816897/photo/business-woman-manager-or-human-resources-portrait-for-career-success-company-we-are-hiring.jpg?s=612x612&w=0&k=20&c=tyLvtzutRh22j9GqSGI33Z4HpIwv9vL_MZw_xOE19NQ='),
                            backgroundColor: Colors.transparent,
                          ),
                          Container(
                            width: GGSize.screenWidth(context) * 0.5,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "@arturo_marino///",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: GGColors.primarytextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(FontAwesomeIcons.fire, color: Colors.red, size: iconSize),
                                        SizedBox(width: 5),
                                        Text('10', style: TextStyle(color: GGColors.secondarytextColor, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 12),
                                        Icon(FontAwesomeIcons.trophy, color: Colors.orange, size: iconSize),
                                        SizedBox(width: 7),
                                        Text('30 days', style: TextStyle(color: GGColors.secondarytextColor, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 12),
                                        Icon(FontAwesomeIcons.faceMeh, color: GGColors.primaryColor, size: iconSize),
                                        SizedBox(width: 5),
                                        Text('2', style: TextStyle(color: GGColors.secondarytextColor, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            height: GGSize.screenHeight(context) * 0.05,
                            width: GGSize.screenHeight(context) * 0.05,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(59, 0, 103, 238),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text('#1', style: TextStyle(color: GGColors.primaryColor, fontSize: 20, fontWeight: FontWeight.bold))),
                          )
                        ],
                      ),
                    ),
                  ),
                )*/
              ],
            ),
          ),
        ));
  }
}
