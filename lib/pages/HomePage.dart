// lib/pages/HomePage.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roofmate/pages/AddListingPage.dart';
import 'package:roofmate/pages/ProfilePage.dart';
import 'package:roofmate/pages/chatPage.dart';
import 'package:roofmate/pages/detailsPage.dart';
import 'package:roofmate/pages/payment_handler.dart';
import 'package:roofmate/pages/savedPage.dart';
import 'package:roofmate/pages/userFavorites.dart';
import 'filterPage.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final searchController = TextEditingController();
  int _selectedIndex = 0;

  void signUserOut(BuildContext context) async {
    bool confirmLogout = await showLogoutConfirmationDialog(context);

    if (confirmLogout) {
      FirebaseAuth.instance.signOut();
    }
  }

  Future<bool> showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
            fontFamily: 'SF-Pro',
          ),
        ),

        backgroundColor: Colors.blue[100],
        actions: [
          IconButton(
            onPressed: () => signUserOut(context),
            icon: const Icon(Icons.logout),
          )
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
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddListing()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue[200],
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
  Map<String, dynamic> filters = {}; // State to hold active filters

  Future<bool> isFavorite(String listingId) async {
    final favorite = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('favorites')
        .doc(listingId)
        .get();

    return favorite.exists;
  }

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

  Future<void> _openFilterPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPage(initialFilters: filters),
      ),
    );

    if (result != null) {
      setState(() {
        filters = result; // Update filters based on user input
      });
    }
  }

  List<DocumentSnapshot> _applyFilters(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final price = int.tryParse(data['price']?.toString() ?? "0") ?? 0;

      if (filters['priceRange'] == "<5000" && price >= 5000) return false;
      if (filters['priceRange'] == "5000-10000" && (price < 5000 || price > 10000)) return false;
      if (filters['priceRange'] == ">10000" && price <= 10000) return false;

      if (filters['location'] != null && filters['location']!.isNotEmpty) {
        final location = data['location']?.toString().toLowerCase() ?? '';
        if (!location.contains(filters['location']!.toString().toLowerCase())) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Padding(
        padding: const EdgeInsets.fromLTRB(5,15,5,15),
        child: Text('Your home away from home is just a few taps away!',
          style:
          TextStyle(fontSize: 16,
          fontWeight: FontWeight.bold),),
      ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
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
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _openFilterPage,
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Locations').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                final List<DocumentSnapshot> boardingDocs = streamSnapshot.data!.docs;

                final List<DocumentSnapshot> filteredDocs = _applyFilters(
                  boardingDocs.where((doc) {
                    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    final String name = data['item'].toString().toLowerCase();
                    final String description = data['description'].toString().toLowerCase();
                    return name.contains(searchQuery) || description.contains(searchQuery);
                  }).toList(),
                );

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text('No listings found.'),
                  );
                }

                return ListView(
                  children: filteredDocs.map((DocumentSnapshot doc) {
                    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    final String name = data['item'] ?? 'No Name';
                    final String imageUrl = data['imageurl'] ?? '';
                    final String price = data['price']?.toString() ?? '0';
                    final String docId = doc.id;

                    return FutureBuilder<bool>(
                      future: isFavorite(docId),
                      builder: (context, snapshot) {
                        bool isFav = snapshot.data ?? false;
                        return Padding(
                          padding: const EdgeInsets.all(10),
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
                                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                isFav ? Icons.favorite : Icons.favorite_border,
                                                color: isFav ? Colors.red : Colors.blue,
                                              ),
                                              onPressed: () => toggleFavorite(docId),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Rs. $price per month",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 1,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentHandler(hotel: data),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.grey,
                                          width: 3,
                                        ),
                                      ),
                                      child: const Text("Book Now"),
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
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}

