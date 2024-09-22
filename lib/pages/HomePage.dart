import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roofmate/pages/chatPage.dart';
import 'package:roofmate/pages/savedPage.dart';
import 'package:roofmate/pages/ProfilePage.dart';
// import 'package:roofmate/components/textBox.dart';
import 'detailsPage.dart';

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
    ExplorePage(),
    Chatpage(),
    SavedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoofMate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
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
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        onTap: _onItemTapped,
      ),
    );
  }
}

class ExplorePage extends StatefulWidget {
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search...',
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Locations').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                final List<DocumentSnapshot> boardingDocs = streamSnapshot.data!.docs;

                final List<DocumentSnapshot> filteredDocs = boardingDocs.where((doc) {
                  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  final String name = data['item'].toString().toLowerCase();
                  final String description = data['description'].toString().toLowerCase();
                  final String imageUrl = data['imageurl'] ?? '';
                  final String price = data['price '].toString().toLowerCase();
                  return name.contains(searchQuery) || description.contains(searchQuery);
                }).toList();

                final List<Widget> boardingWidgets = filteredDocs.map((DocumentSnapshot doc) {
                  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  final String name = data['item'];
                  final String description = data['description'];
                  final String imageUrl = data['imageurl'] ?? '';
                  final String price = data['price '];
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            imageUrl.isNotEmpty
                                ? Image.network(imageUrl, width: double.infinity, height: 150, fit: BoxFit.cover)
                                : Container(
                              width: double.infinity,
                              height: 150,
                              color: Colors.grey[300],
                              child: Icon(Icons.image, color: Colors.grey[700]),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8,8,8,0),
                                      child: Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                    // IconButton(
                                    Icon(Icons.favorite_border),
                                    // onPressed: () {
                                    //   toggleFavorite(docId);
                                    // },

                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Rs."+price+" per night",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                                )
                              ],

                            ),

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

              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}
