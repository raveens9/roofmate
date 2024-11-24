import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roofmate/components/textBox.dart';
import 'package:roofmate/pages/yourListingsPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection('Users');
  final ImagePicker _picker = ImagePicker();

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: 'Edit $field'),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    if (newValue.trim().length > 0) {
      await usersCollection.doc(user.uid).update({field: newValue});
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final storageRef =
          FirebaseStorage.instance.ref().child('users/pfps/${user.uid}.jpg');

      // Delete old profile picture if it exists
      try {
        await storageRef.delete();
      } catch (e) {
        print("No existing profile picture to delete or error deleting: $e");
      }

      // Upload the new profile picture
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update the pfpURL in Firestore
      await usersCollection.doc(user.uid).update({
        'profilePicture': downloadUrl,
      });

      // Update in the 'users' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'pfpURL': downloadUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully!')),
      );
    }
  }

  void _navigateToYourListings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => YourListings()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: Colors.blue[100],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollection.doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final String profilePictureUrl = userData['profilePicture'] ?? '';

            return ListView(
              children: [
                SizedBox(height: 30),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120, // Width of the profile picture
                    height: 120, // Height of the profile picture
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: profilePictureUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(profilePictureUrl),
                              fit: BoxFit.contain, // Ensures the image is fully visible
                            )
                          : null,
                      color: Colors.grey[300], // Placeholder background color
                    ),
                    child: profilePictureUrl.isEmpty
                        ? Icon(Icons.person, size: 50, color: Colors.grey[700])
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  user.email!,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.fromLTRB(17, 0, 10, 0),
                  child: Text(
                    "My Details",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                MyTextBox(
                  text: userData['username'],
                  sectionName: 'Name',
                  onPressed: () => editField('username'),
                ),
                MyTextBox(
                  text: userData['bio'],
                  sectionName: 'Bio',
                  onPressed: () => editField('bio'),
                ),
                MyTextBox(
                  text: userData['phoneNo'],
                  sectionName: 'Mobile Number',
                  onPressed: () => editField('phoneNo'),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 120,
          height: 60,
          child: FloatingActionButton(
            onPressed: _navigateToYourListings,
            child: Text("Your listings"),
            backgroundColor: Colors.blue[200],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
