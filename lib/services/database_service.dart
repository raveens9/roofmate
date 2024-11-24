import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:roofmate/models/chat.dart';
import 'package:roofmate/models/message.dart';
import 'package:roofmate/models/user_profile.dart';
import 'package:roofmate/services/auth_service.dart';
import 'package:roofmate/utils.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late AuthService _authService;
  late CollectionReference<UserProfile> _usersCollection;
  CollectionReference<Chat>? _chatsCollection;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    print("Authenticated user UID: ${_authService.user?.uid}");
    _setupCollectionReferences();
  }

  void _setupCollectionReferences() {
    _usersCollection = _firebaseFirestore.collection('users').withConverter<UserProfile>(
      fromFirestore: (snapshot, _) => UserProfile.fromJson(snapshot.data()!),
      toFirestore: (userProfile, _) => userProfile.toJson(),
    );
    _chatsCollection = _firebaseFirestore.collection('chats').withConverter<Chat>(
      fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
      toFirestore: (chat, _) => chat.toJson(),
    );
  }

  // Create a new user profile in Firestore
  Future<void> createUserProfile({required UserProfile userProfile}) async {
    try {
      await _usersCollection.doc(userProfile.uid).set(userProfile);
      print("User profile created successfully in Firestore");
    } catch (e) {
      print("Error creating user profile: $e");
    }
  }

  // Get the list of user profiles except the currently authenticated user
  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usersCollection
        .where("uid", isNotEqualTo: _authService.user!.uid)
        .snapshots();
  }

  // Get a user profile by UID
  Future<UserProfile?> getUserProfileById(String uid) async {
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();
      if (docSnapshot.exists) {
        var data = docSnapshot.data();
        if (data != null) {
          return UserProfile.fromJson(data as Map<String, dynamic>);  // Safely convert to UserProfile
        }
      }
      return null;
    } catch (e) {
      print("Error getting user profile by ID: $e");
      return null;
    }
  }

  // Check if a chat exists between two users
  Future<bool> checkChatExists(String uid1, String uid2) async {
  String chatID = generateChatID(uid1: uid1, uid2: uid2);
  final result = await _chatsCollection?.doc(chatID).get();
  return result != null && result.exists;
}


  // Create a new chat between two users
  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatsCollection!.doc(chatID);
    final chat = Chat(
      id: chatID,
      participants: [uid1, uid2],
      messages: [],
    );
    await docRef.set(chat);
  }

  // Send a new chat message
  Future<void> sendChatMessage(String uid1, String uid2, Message message) async {
    try {
      String chatID = generateChatID(uid1: uid1, uid2: uid2);

      if (_chatsCollection == null) {
        print("Error: _chatsCollection is not initialized");
        return;
      }

      print("Sending message: ${message.toJson()}");

      final chatDocRef = _chatsCollection!.doc(chatID);

      final chatDoc = await chatDocRef.get();
      if (!chatDoc.exists) {
        print("Chat does not exist. Creating new chat.");
        await createNewChat(uid1, uid2); // Create a new chat if it doesn't exist
      }

      await chatDocRef.update({
        'messages': FieldValue.arrayUnion([message.toJson()]),
      });

      print("Message sent successfully.");
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Get chat data between two users
  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatsCollection!.doc(chatID).snapshots();
  }
}
