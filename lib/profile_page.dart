import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'navigation_menu.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String firstName = "";
  String lastName = "";
  String role = "";
  String registrationDatetime = "";
  bool isLoading = true;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          firstName = userDoc['firstName'];
          lastName = userDoc['lastName'];
          role = userDoc['role'];
          registrationDatetime =
              (userDoc['registrationDatetime'] as Timestamp).toDate().toString();
          firstNameController.text = firstName;
          lastNameController.text = lastName;
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e")),
      );
    }
  }

  Future<void> updateUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
        });
        setState(() {
          firstName = firstNameController.text.trim();
          lastName = lastNameController.text.trim();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      drawer: NavigationMenu(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("First Name: $firstName", style: TextStyle(fontSize: 18)),
                    Text("Last Name: $lastName", style: TextStyle(fontSize: 18)),
                    Text("Role: $role", style: TextStyle(fontSize: 18)),
                    Text("Registered On: $registrationDatetime",
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20),
                    Text("Edit Profile", style: TextStyle(fontSize: 22)),
                    SizedBox(height: 10),
                    TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: "First Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: updateUserProfile,
                      child: Text("Save Changes"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
