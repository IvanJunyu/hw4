import 'package:flutter/material.dart';
import 'message_board_page.dart';
import 'navigation_menu.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, String>> messageBoards = [
    {'name': 'General Chat', 'iconPath': 'assets/general.png'},
    {'name': 'Tech Talk', 'iconPath': 'assets/tech.png'},
    {'name': 'Announcement', 'iconPath': 'assets/announcement.png'},
    {'name': 'Help', 'iconPath': 'assets/help.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Message Boards")),
      drawer: NavigationMenu(),
      body: ListView.builder(
        itemCount: messageBoards.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(messageBoards[index]['iconPath']!),
            title: Text(messageBoards[index]['name']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageBoardPage(
                    boardName: messageBoards[index]['name']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
