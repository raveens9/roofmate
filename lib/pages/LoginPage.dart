import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roofmate/components/mybutton.dart';
import 'package:roofmate/components/mytextfield.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

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
  void signUserIn() async{

    showDialog(context: context, builder: (context){
      return const Center(
        child: CircularProgressIndicator(),
      );
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: usernameController.text,
          password: passwordController.text);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e)

    {
      Navigator.pop(context);
      if(e.code=='user-not-found')
      {
        wrongEmailMessage();
      }
      else if(e.code=='wrong-password')
        {
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
              const SizedBox(height: 60,),
              Image(image: AssetImage('assets/logo.png'),width: 300,),
        
              const SizedBox(height: 90),
        
              const Text(
                'Welcome back!',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 26,
                ),
              ),
        
              const SizedBox(height: 40),
        
              MyTextField(
                controller: usernameController, hintText: 'Email', obscureText: false,
              ),
        
              const SizedBox(height: 30),
        
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
        
              const SizedBox(height: 110,),
        
              const Text('Forgot Password?'),
        
              const SizedBox(height: 20),
        
              MyButton(
                onTap: signUserIn,
                text:  'Sign In'
              ),

              const SizedBox(height: 20,),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not a Member?'),
                  const SizedBox(width: 10,),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text('Register Now',
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
