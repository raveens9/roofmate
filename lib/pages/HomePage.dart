import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roofmate/readData/get_location.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final searchController = TextEditingController();

  List<String> docIds = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    getDocIds();
  }

  Future<void> getDocIds() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .orderBy('price', descending: true) // Sort documents by 'price' in descending order
        .get();
    setState(() {
      docIds = querySnapshot.docs.map((doc) => doc.id).toList();
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _widgetOptions = <Widget>[
    Text('Home Page'),
    Text('Chats Page'),
    Text('Updates Page'),
    Text('Camera Page'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RoofMate'),
        centerTitle: true,
        backgroundColor: Colors.blue[100],
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
          ),
          Expanded(
            child: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Updates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
