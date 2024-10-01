import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPage extends StatefulWidget {
  final String documentId; // Pass the document ID from Firestore to this page

  MapPage({required this.documentId});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  LatLng _initialPosition = const LatLng(37.7749, -122.4194); // Default location (San Francisco)
  bool _isLoading = true; // To manage loading state
  Marker? _locationMarker; // Marker for the fetched location

  @override
  void initState() {
    super.initState();
    _fetchLocationFromFirestore();
  }

  Future<void> _fetchLocationFromFirestore() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> locationSnapshot = await FirebaseFirestore.instance
          .collection('Locations')
          .doc(widget.documentId)
          .get();

      if (locationSnapshot.exists && locationSnapshot.data() != null) {
        // Fetch latitude and longitude as double directly
        double latitude = locationSnapshot.data()?['latitude'] ?? 0.0;
        double longitude = locationSnapshot.data()?['longitude'] ?? 0.0;

        setState(() {
          _initialPosition = LatLng(latitude, longitude);
          _locationMarker = Marker(
            markerId: MarkerId('locationMarker'),
            position: _initialPosition,
            infoWindow: InfoWindow(
              title: locationSnapshot.data()?['item'] ?? 'Unknown Item', // Set the location name as title
              snippet: locationSnapshot.data()?['description'] ?? 'No description available', // Set the description as snippet
            ),
          );
          _isLoading = false; // Finished loading
        });
      } else {
        print('Document does not exist!');
        setState(() {
          _isLoading = false; // Even if the document doesn't exist, stop loading
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner while fetching data
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 13.0, // Adjust the zoom level as needed
        ),
        myLocationEnabled: true, // Enables 'My Location' feature on the map
        zoomControlsEnabled: true, // Enables zoom control buttons
        markers: _locationMarker != null ? {_locationMarker!} : {}, // Add the marker
      ),
    );
  }
}
