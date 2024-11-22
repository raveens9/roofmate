import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:roofmate/components/mytextfield.dart';
import 'package:roofmate/components/mybutton.dart';

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

  void wrongEmailMessage(){
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Wrong Email'),
        );
      },
    );
  }

  void wrongPasswordMessage(){

    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Wrong Password'),
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

        // Add user details to Firestore, including the userId
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.email)
            .set({
          'userId': userId, // Include userId in Firestore document
          'username': displayNameController.text,
          'bio': 'Tell us about yourself',
          'phoneNo': phoneNumberController.text,
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.email)
            .set({
          'name': displayNameController.text, // Include userId in Firestore document
          'pfpURL':"",
          'uid': userId,
        });

        Navigator.pop(context); // Close the loading dialog
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
              SizedBox(height: 30,),
              Image(image: AssetImage('assets/logo.png'),width: 300,),

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
                controller: usernameController, hintText: 'Email Address', obscureText: false,
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

              const SizedBox(height: 50,),

              MyButton(
                onTap: signUserUp,
                text: 'Sign Up',
              ),

              SizedBox(height: 20,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  SizedBox(width: 10,),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text('Login Now',
                      style: TextStyle(color: Colors.blueAccent
                      ),),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}