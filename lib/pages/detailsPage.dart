// Import necessary packages and services
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roofmate/models/user_profile.dart';
import 'package:roofmate/pages/chat_page.dart';
import 'package:roofmate/pages/map.dart';
import 'package:roofmate/pages/mapDirection.dart';
import 'package:roofmate/services/database_service.dart';
import 'package:roofmate/pages/posterDetailsPage.dart';
import 'package:roofmate/pages/payment_handler.dart';


class detailsPage extends StatelessWidget {
  final String documentId;

  detailsPage({required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
          final String userId = data['userId']; // Fetch the userId
          final String name = data['item'];
          final String description = data['description'];
          final String imageUrl = data['imageurl'];
          final String ownerId = data['userId']; // Advertisement owner's UID

          // Log the ownerId to check if it's being fetched correctly
          print("Owner ID from chat: $ownerId");


          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
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
                  Text(
                    name,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),


                  SizedBox(height: 20),
                  Column(
                    children: [Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.person),
                            label: Text('Contact Owner'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PosterDetailsPage(userId: userId),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                          ),
                          SizedBox(width: 20,),

                          ElevatedButton.icon(
                            icon: Icon(Icons.chat),
                            label: Text('Chat'),
                            onPressed: () async {
                              final DatabaseService dbService = DatabaseService();

                              // Fetch advertisement owner's profile
                              final DocumentSnapshot<Map<String, dynamic>> ownerDoc =
                              await FirebaseFirestore.instance.collection('users').doc(ownerId).get();

                              final Map<String, dynamic> ownerData = ownerDoc.data()!;
                              print(ownerData);  // Print out the fields of the document

                              if (!ownerDoc.exists) {
                                // Handle the case where the owner document doesn't exist
                                print('Owner document not found for ownerId: $ownerId');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Owner data not found')),
                                );
                                return;
                              }

                              final UserProfile ownerProfile = UserProfile.fromJson(ownerDoc.data()!);

                              // Fetch current user's profile
                              final currentUser = FirebaseAuth.instance.currentUser;

                              if (currentUser == null) {
                                // Handle the case where the user is not authenticated
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('User is not authenticated')),
                                );
                                return;
                              }

                              final UserProfile currentUserProfile = UserProfile(
                                uid: currentUser.uid,
                                name: currentUser.displayName ?? "Anonymous",
                                pfpURL: currentUser.photoURL ?? "",
                              );

                              // Create user profile for current user if it doesn't exist
                              await dbService.createUserProfile(userProfile: currentUserProfile);

                              // Check if a chat already exists between the two users
                              bool chatExists = await dbService.checkChatExists(currentUser.uid, ownerId);

                              // If chat doesn't exist, create one
                              if (!chatExists) {
                                await dbService.createNewChat(currentUser.uid, ownerId);
                              }

                              // Navigate to ChatPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(chatUser: ownerProfile),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.directions),
                              label: Text('Get Directions'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapDirection(documentId: documentId),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: Icon(Icons.map),
                              label: Text('Maps'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapPage(documentId: documentId),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                            ),

                            // Text(data)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
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
                              width: 1,
                            ),
                          ),
                          child: const Text("Book Now"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}