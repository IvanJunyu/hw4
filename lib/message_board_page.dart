import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageBoardPage extends StatelessWidget {
  final String boardName;

  MessageBoardPage({required this.boardName});

  final TextEditingController messageController = TextEditingController();

  void postMessage(String boardId, String message) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('messageBoards').doc(boardId).collection('messages').add({
        'message': message,
        'userId': user.uid,
        'datetime': DateTime.now(),
      });
      messageController.clear();
    }
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    String boardId = boardName.toLowerCase().replaceAll(' ', '_');

    return Scaffold(
      appBar: AppBar(title: Text(boardName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messageBoards')
                  .doc(boardId)
                  .collection('messages')
                  .orderBy('datetime', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final messageData = doc.data() as Map<String, dynamic>;
                      final userId = messageData['userId'];

                      return FutureBuilder(
                        future: fetchUserData(userId),
                        builder: (context, AsyncSnapshot<Map<String, dynamic>> userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              title: Text("Loading user data..."),
                            );
                          }

                          if (userSnapshot.hasData) {
                            final userData = userSnapshot.data!;
                            return ListTile(
                              title: Text(messageData['message']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("By: ${userData['firstName']} ${userData['lastName']} (${userData['role']})"),
                                  Text("Posted at: ${messageData['datetime'].toDate().toString()}"),
                                ],
                              ),
                            );
                          }

                          return ListTile(
                            title: Text("Error loading user data"),
                          );
                        },
                      );
                    }).toList(),
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => postMessage(boardId, messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
