import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:roofmate/models/chat_tile.dart';
import 'package:roofmate/models/user_profile.dart';
import 'package:roofmate/pages/chat_page.dart';
import 'package:roofmate/services/auth_service.dart';
import 'package:roofmate/services/database_service.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({super.key});

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late TextEditingController _searchController;
  
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.blue[200],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 226, 226, 225), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 20.0,
          ),
          child: Column(
            children: [Text('Manage your stays and visits here!'),
              SizedBox(height: 20,),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Color.fromARGB(255, 251, 252, 250),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) => _onSearchChanged(),
              ),
              const SizedBox(height: 20.0),
              Expanded(child: _chatList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error: ${snapshot.error}");
          return const Center(
            child: Text("Unable to load data."),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final users = snapshot.data!.docs;
          final filteredUsers = users.where((doc) {
            final user = doc.data() as UserProfile;
            final userName = user.name!.toLowerCase();
            return userName.contains(_searchQuery.toLowerCase());
          }).toList();
          print("Number of users: ${filteredUsers.length}");
          return ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              UserProfile user = filteredUsers[index].data() as UserProfile;
              return Column(
                children: [
                  ChatTile(
                    userProfile: user,
                    onTap: () async {
                      final chatExists = await _databaseService.checkChatExists(
                        _authService.user!.uid,
                        user.uid!,
                      );
                      if (!chatExists) {
                        await _databaseService.createNewChat(
                          _authService.user!.uid,
                          user.uid!,
                        );
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(chatUser: user),
                        ),
                      );
                    },
                  ),
                  if (index != filteredUsers.length - 1)
                    const Divider(
                      thickness: 1,
                      indent: 15,
                      endIndent: 15,
                    ),
                ],
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
