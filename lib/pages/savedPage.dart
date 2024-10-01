import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roofmate/pages/detailsPage.dart';
import 'detailsPage.dart';
class SavedPage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteDocs = snapshot.data!.docs;

          if (favoriteDocs.isEmpty) {
            return const Center(child: Text('No favorites added.'));
          }

          return ListView(
            children: favoriteDocs.map((doc) {
              final locationId = doc['locationId'];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('Locations').doc(locationId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const ListTile(title: Text('Loading...'));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final String name = data['item'] ?? 'No Name';
                  final String imageUrl = data['imageurl'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => detailsPage(documentId: locationId),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            imageUrl.isNotEmpty
                                ? Image.network(imageUrl, width: double.infinity, height: 150, fit: BoxFit.cover)
                                : Container(
                              width: double.infinity,
                              height: 150,
                              color: Colors.grey[300],
                              child:  Icon(Icons.image, color: Colors.grey[700]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
