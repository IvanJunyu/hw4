import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'navigation_menu.dart';

class SettingsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void logoutUser(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void changeEmail(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Email"),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: "New Email",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  User? user = _auth.currentUser;
                  if (user != null) {
                    await user.updateEmail(emailController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Email updated successfully!")),
                    );
                  }
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error updating email: $e")),
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void changePassword(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "New Password",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  User? user = _auth.currentUser;
                  if (user != null) {
                    await user.updatePassword(passwordController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Password updated successfully!")),
                    );
                  }
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error updating password: $e")),
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      drawer: NavigationMenu(),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Change Email"),
            onTap: () => changeEmail(context),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change Password"),
            onTap: () => changePassword(context),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Log Out"),
            onTap: () => logoutUser(context),
          ),
        ],
      ),
    );
  }
}
