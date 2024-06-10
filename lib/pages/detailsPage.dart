import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
              ],
            ),
          );
        },
      ),
    );
  }
}
