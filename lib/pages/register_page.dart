import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:roofmate/components/mybutton.dart';
import 'package:roofmate/components/mytextfield.dart';
import 'package:roofmate/services/storage_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final displayNameController = TextEditingController();

  // Function to load the default profile picture from assets as a File
  Future<File> getDefaultProfilePicFile() async {
    // Load the image as a byte array
    final byteData = await rootBundle.load('assets/default_profile_pic.jpg');

    // Get the temporary directory
    final tempDir = await getTemporaryDirectory();

    // Create a temporary file
    final tempFile = File('${tempDir.path}/default_profile_pic.jpg');

    // Write the byte data to the file
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());

    return tempFile;
  }

  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Wrong Email'),
        );
      },
    );
  }

  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Passwords do not match'),
        );
      },
    );
  }



  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        // Create the user with Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: usernameController.text,
          password: passwordController.text,
        );

        // Get the user's unique ID
        String userId = userCredential.user!.uid;

        // Load the default profile picture
        final File defaultProfilePicFile = await getDefaultProfilePicFile();

        // Upload default profile picture to Firebase Storage
        String? profilePicURL = await StorageService().uploadUserPfp(
          file: defaultProfilePicFile,
          uid: userId,
        );

        if (profilePicURL != null) {
          // Add user details to Firestore (Users collection) with 'uid' as the document ID
          await FirebaseFirestore.instance
              .collection('Users') // This is for the owner collection
              .doc(userId) // Using 'uid' as the document ID
              .set({
            'userId': userId,
            'username': displayNameController.text,
            'bio': 'Tell us about yourself',
            'phoneNo': phoneNumberController.text,
            'profilePicture': profilePicURL,
          });

          // Add user details to Firestore (users collection)
          await FirebaseFirestore.instance
              .collection('users') // This could be the main users collection
              .doc(userId) // Using 'uid' as the document ID
              .set({
            'name': displayNameController.text,
            'pfpURL': profilePicURL,
            'uid': userId,
          });

          Navigator.pop(context); // Close the loading dialog
        } else {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text('Error uploading profile picture.'),
              );
            },
          );
        }
      } else {
        Navigator.pop(context); // Close the loading dialog
        wrongPasswordMessage();
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the loading dialog
      if (e.code == 'user-not-found') {
        wrongEmailMessage();
      } else if (e.code == 'wrong-password') {
        wrongPasswordMessage();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              Image(image: AssetImage('assets/logo.png'), width: 300),
              const SizedBox(height: 20),
              Text(
                'Welcome!',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 26,
                ),
              ),
              SizedBox(height: 30),
              MyTextField(
                controller: usernameController,
                hintText: 'Email Address',
                obscureText: false,
              ),
              SizedBox(height: 20),
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              SizedBox(height: 20),
              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
              SizedBox(height: 20),
              MyTextField(
                controller: displayNameController,
                hintText: 'Display Name (for users to identify you)',
                obscureText: false,
              ),
              SizedBox(height: 20),
              MyTextField(
                controller: phoneNumberController,
                hintText: 'Phone Number',
                obscureText: false,
              ),
              const SizedBox(height: 50),
              MyButton(
                onTap: signUserUp,
                text: 'Sign Up',
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Login Now',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}