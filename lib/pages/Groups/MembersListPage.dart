import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_grit/utils/components/Shimmers.dart';
import 'package:group_grit/utils/constants/colors.dart' show GGColors;
import 'package:group_grit/utils/constants/size.dart';
import 'package:shimmer/shimmer.dart';

class MembersListPage extends StatefulWidget {
  final String groupId;

  MembersListPage({required this.groupId});

  @override
  State<MembersListPage> createState() => _MembersListPageState();
}

class _MembersListPageState extends State<MembersListPage> {
  bool _isLoading = true;
  Future<int> getGroupMembersCount() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('memberships').where('groupId', isEqualTo: widget.groupId).get();
    return querySnapshot.docs.length;
  }

  List<DocumentSnapshot> _memberships = [];

  bool _isUserOwner() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return _memberships.any((membership) => membership['userId'] == userId && membership['role'] == 'admin');
  }

  void _getGroupMemberships() async {
    QuerySnapshot memberships = await FirebaseFirestore.instance.collection('memberships').where('groupId', isEqualTo: widget.groupId).get();
    setState(() {
      _memberships = memberships.docs;
    });
  }

  @override
  void initState() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
    _getGroupMemberships();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GGColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: GGColors.backgroundColor,
        title: Text(
          'Group Members',
          style: TextStyle(color: GGColors.primarytextColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  FutureBuilder<int>(
                    future: getGroupMembersCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
                        return Shimmer.fromColors(
                          period: Duration(milliseconds: 1200),
                          baseColor: Colors.grey[200]!, // Colore di base (grigio chiaro)
                          highlightColor: Colors.white,
                          child: Container(
                              width: GGSize.screenWidth(context) * 0.2,
                              height: 18,
                              decoration: BoxDecoration(color: GGColors.buttonColor, borderRadius: BorderRadius.circular(15)),
                              child: Center()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData) {
                        return Text('0 Members', style: TextStyle(color: GGColors.primarytextColor, fontWeight: FontWeight.bold, fontSize: 18));
                      }
                      return Text('${snapshot.data} Members',
                          style: TextStyle(color: GGColors.primarytextColor, fontWeight: FontWeight.bold, fontSize: 16));
                    },
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(color: GGColors.buttonColor, borderRadius: BorderRadius.circular(14)),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('memberships').where('groupId', isEqualTo: widget.groupId).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
                    return MembersShimmer();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No members found.'));
                  }
                  final members = snapshot.data!.docs;
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    shrinkWrap: true,
                    itemCount: members.length,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) {
                      return Divider(
                        indent: GGSize.screenWidth(context) * 0.15,
                        color: GGColors.secondarytextColor.withOpacity(0.2),
                        height: 1,
                      );
                    },
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(member['userId']).get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return MembersShimmer();
                          }
                          if (!userSnapshot.hasData || userSnapshot.data == null) {
                            return Container();
                          }
                          var userData = userSnapshot.data!;

                          return CupertinoButton(
                            pressedOpacity: _isUserOwner() ? 0.5 : 1,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              if (!_isUserOwner()) {
                                if (userData['uid'] == FirebaseAuth.instance.currentUser!.uid) {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        color: GGColors.buttonColor,
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'Leave Group',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Are you sure you want to leave from group?',
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final QuerySnapshot remainingMembers = await FirebaseFirestore.instance
                                                        .collection('memberships')
                                                        .where('groupId', isEqualTo: widget.groupId)
                                                        .where('userId', isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
                                                        .get();

                                                    if (remainingMembers.docs.isNotEmpty) {
                                                      final newAdmin = remainingMembers.docs[0];
                                                      await FirebaseFirestore.instance
                                                          .collection('memberships')
                                                          .doc(newAdmin.id)
                                                          .update({'role': 'admin'}).then((value) async {
                                                        await FirebaseFirestore.instance.collection('memberships').doc(member.id).delete();
                                                        Navigator.pop(context);
                                                      });
                                                    }
                                                  },
                                                  child: Text(
                                                    'Leave',
                                                    style: TextStyle(color: Colors.white),
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
                                    },
                                  );
                                }
                              } else {
                                if (userData['uid'] == FirebaseAuth.instance.currentUser!.uid) {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        color: GGColors.buttonColor,
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'Leave Group',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Are you sure you want to leave from group?',
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    final QuerySnapshot remainingMembers = await FirebaseFirestore.instance
                                                        .collection('memberships')
                                                        .where('groupId', isEqualTo: widget.groupId)
                                                        .where('userId', isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
                                                        .get();

                                                    if (remainingMembers.docs.isNotEmpty) {
                                                      final newAdmin = remainingMembers.docs[0];
                                                      await FirebaseFirestore.instance
                                                          .collection('memberships')
                                                          .doc(newAdmin.id)
                                                          .update({'role': 'admin'}).then((value) async {
                                                        await FirebaseFirestore.instance.collection('memberships').doc(member.id).delete();
                                                        Navigator.pop(context);
                                                      });
                                                    }
                                                  },
                                                  child: Text(
                                                    'Leave',
                                                    style: TextStyle(color: Colors.white),
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
                                    },
                                  );
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        color: GGColors.buttonColor,
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'Remove Member',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Are you sure you want to remove ${userData['display_name']} from the group?',
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await FirebaseFirestore.instance.collection('memberships').doc(member.id).delete();
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    'Remove',
                                                    style: TextStyle(color: Colors.white),
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
                                    },
                                  );
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22.0,
                                        backgroundImage: CachedNetworkImageProvider( userData['photo_url'] ?? "", // Fallback a stringa vuota
                                        ),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                          //width: GGSize.screenWidth(context) * 0.55,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 15),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${userData['display_name']}",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: GGColors.primarytextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  "@${userData['username']}",
                                                  style: TextStyle(
                                                    letterSpacing: 0.2,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: GGColors.secondarytextColor,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                if (member['role'] == 'admin')
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 10),
                                                    child: Text('Administrator',
                                                        style:
                                                            TextStyle(color: GGColors.secondarytextColor, fontWeight: FontWeight.w500, fontSize: 14)),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_isUserOwner())
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: GGColors.secondarytextColor,
                                          size: 18,
                                        ),
                                    ],
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
