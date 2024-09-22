// lib/pages/AddListingPage.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roofmate/pages/HomePage.dart';
import 'dart:io';

class AddListing extends StatefulWidget {
  @override
  _AddListingState createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> {
  final _formKey = GlobalKey<FormState>();
  String _itemName = '';
  String _description = '';
  String _price = ''; // New state variable for price
  File? _imageFile;
  bool _isLoading = false;
  final user = FirebaseAuth.instance.currentUser!;
  final locationsCollection = FirebaseFirestore.instance.collection('Locations');
  final ImagePicker _picker = ImagePicker();

  /// Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// Function to add a new listing to Firestore
  Future<void> _addListing() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

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
        'price': double.parse(_price), // Store price as double
        'imageurl': imageUrl,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(), // Optional: For sorting
      });

      setState(() {
        _isLoading = false; // Stop loading
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Listing added successfully!')),
      );

      // Navigate back to HomePage or previous page
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Listing'),
      ),
      body: SingleChildScrollView( // Prevent overflow when keyboard appears
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Item Name Field
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

              // Description Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3, // Allow multiple lines
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

              // Price Field
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

              // Image Picker Section
              _imageFile == null
                  ? Text(
                'No image selected.',
                style: TextStyle(color: Colors.grey),
              )
                  : Image.file(
                _imageFile!,
                height: 150,
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage, // Disable while loading
                icon: Icon(Icons.image),
                label: Text('Select Image'),
              ),
              SizedBox(height: 24),

              // Add Listing Button or Loading Indicator
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addListing,
                child: Text('Add Listing'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Full-width button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
