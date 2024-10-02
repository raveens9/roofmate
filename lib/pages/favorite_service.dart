// lib/services/favorite_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final user = FirebaseAuth.instance.currentUser!;
  final favoritesCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('favorites');

  Future<void> toggleFavorite(String locationId) async {
    final favoriteDoc = await favoritesCollection.doc(locationId).get();
    if (favoriteDoc.exists) {
      await favoritesCollection.doc(locationId).delete(); // Remove from favorites
    } else {
      await favoritesCollection.doc(locationId).set({'locationId': locationId}); // Add to favorites
    }
  }

  Future<bool> isFavorite(String locationId) async {
    final favoriteDoc = await favoritesCollection.doc(locationId).get();
    return favoriteDoc.exists;
  }
}
