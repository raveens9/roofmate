import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roofmate/pages/mapDirection.dart';
import 'map.dart'; // Import the new map.dart file

class detailsPage extends StatelessWidget {
  final String documentId;

  detailsPage({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Locations').doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Document does not exist'));
          }

          final Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          final String name = data['item'];
          final String description = data['description'];
          final String imageUrl = data['imageurl'];
          final String userId = data['userId']; // Get the userId from the listing

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text('No image available'),
                    ),
                  ),
                SizedBox(height: 20),
                Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text(description),
                SizedBox(height: 20),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(userId).get(), // Fetch user details
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading user information...');
                    }
                    if (userSnapshot.hasError) {
                      return Text('Error loading user information: ${userSnapshot.error}');
                    }
                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return Text('User does not exist');
                    }

                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    final String userName = userData['name']; // Assuming the user's name field is 'name'

                    return Text('Added by: $userName', style: TextStyle(fontStyle: FontStyle.italic));
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapPage(documentId: documentId), // Pass the document ID here
                      ),
                    );
                  },
                  child: Text('Maps'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapDirection(documentId: documentId), // Pass the document ID here
                      ),
                    );
                  },
                  child: Text('Get Directions'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
