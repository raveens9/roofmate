// lib/pages/HomePage.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roofmate/pages/chatPage.dart';
import 'package:roofmate/pages/savedPage.dart';
import 'package:roofmate/pages/ProfilePage.dart';
import 'package:roofmate/pages/detailsPage.dart';
import 'package:roofmate/pages/AddListingPage.dart';
import 'package:roofmate/services/confirm_deletion_dialog.dart';

class UserListings extends StatefulWidget {
  const UserListings({super.key});

  @override
  State<UserListings> createState() => _UserListingsState();
}

class _UserListingsState extends State<UserListings> {
  final user = FirebaseAuth.instance.currentUser!;
  final searchController = TextEditingController();
  int _selectedIndex = 0;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _widgetOptions = <Widget>[
    const ExplorePage(),
    const Chatpage(),
    SavedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RoofMate',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: Colors.blue[100],
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Locations')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                final List<DocumentSnapshot> boardingDocs = streamSnapshot.data!.docs;

                // Apply any additional filtering based on search query
                final List<DocumentSnapshot> filteredDocs = boardingDocs.where((doc) {
                  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  final String name = data['item'].toString().toLowerCase();
                  final String description = data['description'].toString().toLowerCase();
                  return name.contains(searchQuery) || description.contains(searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 230),
                        Image(image: AssetImage('assets/profile.jpg'), width: 300),
                        const SizedBox(height: 20), // Space between the image and the text
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15,0,15,0),
                          child: const Text(
                            'You don\'t have any listings. Time to get started!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 160),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
                          child: Container(
                            width: 100, // Custom width
                            height: 40, // Custom height
                            child: FloatingActionButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddListing()),
                                );
                              },
                              child: const Text(
                                'Add Listing',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.blue[200],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }

                final List<Widget> boardingWidgets = filteredDocs.map((DocumentSnapshot doc) {
                  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  final String name = data['item'] ?? 'No Name';
                  final String description = data['description'] ?? 'No Description';
                  final String imageUrl = data['imageurl'] ?? '';
                  final String price = data['price']?.toString() ?? '0';
                  final String docId = doc.id;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => detailsPage(
                              documentId: docId,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    width: double.infinity,
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, color: Colors.grey, size: 50),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.blue[300]),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => ConfirmDeletionDialog(
                                              onConfirm: () async {
                                                // Your delete logic here
                                                await FirebaseFirestore.instance
                                                    .collection('Locations')
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
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList();

                return ListView(
                  children: boardingWidgets,
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}