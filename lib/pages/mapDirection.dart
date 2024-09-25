import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MapDirection extends StatelessWidget {
  final String documentId; // Pass the document ID from Firestore to this page

  MapDirection({required this.documentId});

  // Function to create the Google Maps link and open it
  void _openMap(double latitude, double longitude) async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunchUrlString(googleMapsUrl)) {
      await launchUrlString(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open in Google Maps'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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

          final Map<String, dynamic> data = snapshot.data!.data()!;
          final double latitude = double.parse(data['latitude']);
          final double longitude = double.parse(data['longitude']);
          final String locationName = data['item'] ?? 'Location';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location: $locationName',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text('Latitude: $latitude'),
                Text('Longitude: $longitude'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _openMap(latitude, longitude); // Open Google Maps
                  },
                  child: Text('Open in Google Maps'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
