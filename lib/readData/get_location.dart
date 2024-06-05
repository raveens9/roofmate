import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetLocation extends StatelessWidget {
  late final String docId;

  GetLocation({required this.docId});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(docId).get(), // Fetch the document using docId
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Check if the snapshot contains data
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            // Access data and return appropriate widget
            return Text('${data['location']} '+' '+'${data['price']}'); // Assuming 'location' is a field in the document
          } else {
            return Text('Document does not exist');
          }
        } else {
          // Return a placeholder widget while data is loading
          return Text('Loading..');
        }
      },
    );
  }
}
