// lib/pages/HomePage.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roofmate/pages/chatPage.dart';
import 'package:roofmate/pages/savedPage.dart';
import 'package:roofmate/pages/ProfilePage.dart';
import 'package:roofmate/pages/detailsPage.dart';
import 'package:roofmate/pages/AddListingPage.dart'; // Import the AddListingPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      // Conditionally display the FloatingActionButton only on ExplorePage
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          // Navigate to AddListingPage when FAB is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddListingPage()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      )
          : null, // No FAB for other pages
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Position FAB at bottom right
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.blue[300],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        onTap: _onItemTapped,
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
        // Search TextField
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        // Listings StreamBuilder
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Locations').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                final List<DocumentSnapshot> boardingDocs = streamSnapshot.data!.docs;

                // Filter documents based on search query
                final List<DocumentSnapshot> filteredDocs = boardingDocs.where((doc) {
                  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  final String name = data['item'].toString().toLowerCase();
                  final String description = data['description'].toString().toLowerCase();
                  // Ensure field names are correct (removed trailing space in 'price ')
                  final String price = (data['price'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery) || description.contains(searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text('No listings found.'),
                  );
                }

                final List<Widget> boardingWidgets = filteredDocs.map((DocumentSnapshot doc) {
                  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  final String name = data['item'] ?? 'No Name';
                  final String description = data['description'] ?? 'No Description';
                  final String imageUrl = data['imageurl'] ?? '';
                  final String price = data['price']?.toString() ?? '0';
                  final String docId = doc.id; // Get the document ID

                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => detailsPage(
                              documentId: docId, // Pass the document ID
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Listing Image
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
                                height: 150,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, color: Colors.grey, size: 50),
                              ),
                            ),
                            // Listing Details
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(Icons.favorite_border, color: Colors.redAccent),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Rs. $price per night",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
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

              // Loading Indicator
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}