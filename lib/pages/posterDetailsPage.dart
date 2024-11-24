import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PosterDetailsPage extends StatefulWidget {
  final String userId;

  PosterDetailsPage({required this.userId});

  @override
  _PosterDetailsPageState createState() => _PosterDetailsPageState();
}

class _PosterDetailsPageState extends State<PosterDetailsPage> {
  bool _isLoading = true; // To manage loading state
  String username = 'Unknown User'; // Default username
  String phoneNo = 'No phone number available'; // Default phone number

  @override
  void initState() {
    super.initState();
    _fetchUserDetailsFromFirestore();
  }

  Future<void> _fetchUserDetailsFromFirestore() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        setState(() {
          username = userSnapshot.data()?['username'] ?? 'Unknown User';
          phoneNo = userSnapshot.data()?['phoneNo'] ?? 'No phone number available';
          _isLoading = false;
        });
      } else {
        print('Document does not exist!');
        setState(() {
          _isLoading = false; // Stop loading even if the document doesn't exist
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Owner Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Owner Name: $username',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Phone Number: $phoneNo',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
