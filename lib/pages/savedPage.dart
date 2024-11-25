import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roofmate/pages/detailsPage.dart';
import 'package:roofmate/pages/HomePage.dart';
import 'package:roofmate/services/confirm_favorite.dart';
class SavedPage extends StatefulWidget {
  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  final user = FirebaseAuth.instance.currentUser!;

  void toggleFavorite(String listingId) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('favorites')
        .doc(listingId);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'locationId': listingId,
      });
    }

    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Favorites"),
        backgroundColor: Colors.blue[200],
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(image: AssetImage('assets/save.jpg'), width: 300),
                  const SizedBox(height: 20), // Space between the image and the text
                  const Text(
                    'No favorites added. Yet :)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
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
                  final String docId = doc.id;

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
                              padding: const EdgeInsets.all(8),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.blue[300]),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => ConfirmFavoriteDialog(
                                          onConfirm: () async {
                                            await FirebaseFirestore.instance
                                                .collection('favorites')
                                                .doc(docId)
                                                .delete();

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Listing deleted successfully')),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),

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
