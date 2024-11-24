import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roofmate/pages/HomePage.dart';

class AddListing extends StatefulWidget {
  @override
  _AddListingState createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> {
  final _formKey = GlobalKey<FormState>();
  String _itemName = '';
  String _description = '';
  String _price = '';
  LatLng? _selectedLocation;
  File? _imageFile;
  bool _isLoading = false;
  final user = FirebaseAuth.instance.currentUser!;
  final locationsCollection = FirebaseFirestore.instance.collection('Locations');
  final usersCollection = FirebaseFirestore.instance.collection('Users');
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Function to add a new listing to Firestore
  Future<void> _addListing() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null && _imageFile != null) {
      setState(() {
        _isLoading = true;
      });

      DocumentSnapshot userDoc = await usersCollection.doc(user.uid).get();

      // Extract the phone number and display nam
      String? imageUrl;

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('listing_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(_imageFile!);

        final snapshot = await uploadTask.whenComplete(() => {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      await locationsCollection.add({
        'item': _itemName,
        'description': _description,
        'price': double.parse(_price),
        'imageurl': imageUrl,
        'userId': user.uid,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Listing added successfully!')),
      );

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image and location')),
      );
    }
  }

  // Function to open the map and allow location selection
  Future<void> _selectLocationOnMap() async {
    LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
    if (pickedLocation != null) {
      setState(() {
        _selectedLocation = pickedLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _itemName = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Price (Rs.)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _price = value;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectLocationOnMap,
                child: Text(_selectedLocation == null
                    ? 'Select Location on Map'
                    : 'Location Selected: (${_selectedLocation!.latitude}, ${_selectedLocation!.longitude})'),
              ),
              SizedBox(height: 16),
              _imageFile == null
                  ? Text('No image selected.', style: TextStyle(color: Colors.grey))
                  : Image.file(_imageFile!, height: 150),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: Icon(Icons.image),
                label: Text('Select Image'),
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _imageFile == null ? null : _addListing,
                child: Text('Add Listing'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _pickedLocation == null
                ? null
                : () {
              Navigator.of(context).pop(_pickedLocation);
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(6.9271, 79.8612), // Set initial position (Colombo, Sri Lanka)
          zoom: 12,
        ),
        onTap: _selectLocation,
        markers: _pickedLocation == null
            ? {}
            : {
          Marker(
            markerId: MarkerId('picked-location'),
            position: _pickedLocation!,
          ),
        },
      ),
    );
  }
}