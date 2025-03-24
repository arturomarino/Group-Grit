import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:group_grit/utils/appState.dart';
import 'package:group_grit/utils/constants/colors.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String groupId;

  ChatPage({required this.groupId});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Funzione per inviare un messaggio
  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('groups/${widget.groupId}/messages').add({
      'senderId': userId,
      'text': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      //'photo_url': FirebaseAuth.instance.currentUser!.photoURL,
    });

    _messageController.clear();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    // appState.currentScreen = "ChatPage_${widget.groupId}";
    super.initState();
  }

  dispose() {
    _messageController.dispose();
    //appState.currentScreen = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GGColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 74, 152, 255),
        title: Text(
          'Group Chat',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Lista messaggi in tempo reale
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('groups/${widget.groupId}/messages').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());
                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    physics: ClampingScrollPhysics(),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var msg = messages[index];
                      bool isMe = msg['senderId'] == FirebaseAuth.instance.currentUser!.uid;

                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('users').doc(msg['senderId']).snapshots(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) return SizedBox.shrink();

                          var user = userSnapshot.data!;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Padding(
                                      padding: const EdgeInsets.only(left: 12, bottom: 5),
                                      child: ClipOval(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Ink.image(
                                            image: CachedNetworkImageProvider(user['photo_url']), // Usa CachedNetworkImageProvider per caching
                                            fit: BoxFit.cover,
                                            width: 30,
                                            height: 30,
                                            child: InkWell(onTap: () {}),
                                          ),
                                        ),
                                      )),
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                  padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.blue : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (index < messages.length - 1)
                                        if (!isMe && messages[index + 1]['senderId'] != msg['senderId'])
                                          Text(user['display_name'],
                                              style: TextStyle(color: isMe ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                                      if (!isMe && messages[index] == messages.last)
                                        Text(user['display_name'],
                                            style: TextStyle(color: isMe ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                        child: Text(
                                          msg['text'],
                                          style: TextStyle(color: isMe ? Colors.white : Colors.black, fontWeight: FontWeight.w400),
                                          overflow: TextOverflow.visible,
                                          maxLines: null,
                                        ),
                                      ),
                                      Text(
                                        msg['timestamp'] != null
                                            ? (msg['timestamp'] as Timestamp).toDate().day == DateTime.now().day
                                                ? DateFormat('\'Today at\' HH:mm').format((msg['timestamp'] as Timestamp).toDate())
                                                : DateFormat('d MMMM \'at\' HH:mm').format((msg['timestamp'] as Timestamp).toDate())
                                            : '',
                                        style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isMe)
                                  Padding(
                                      padding: const EdgeInsets.only(right: 12, bottom: 5),
                                      child: ClipOval(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Ink.image(
                                            image: CachedNetworkImageProvider(user['photo_url']), // Usa CachedNetworkImageProvider per caching
                                            fit: BoxFit.cover,
                                            width: 30,
                                            height: 30,
                                            child: InkWell(onTap: () {}),
                                          ),
                                        ),
                                      )),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // Input per scrivere messaggi
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: GGColors.primarytextColor),
                      decoration: InputDecoration(
                        hintText: "Write a message...",
                        hintStyle: TextStyle(color: GGColors.secondarytextColor),
                        filled: true,
                        fillColor: GGColors.TextFieldColor,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 196, 196, 196), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(19),
                          borderSide: BorderSide(color: GGColors.primaryColor, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _messageController,
                    builder: (context, value, child) {
                      return IconButton(
                        icon: Icon(Icons.send, color: value.text.isEmpty ? Colors.grey : Colors.blue),
                        onPressed: value.text.isEmpty ? null : sendMessage,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
