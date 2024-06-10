import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roofmate/components/textBox.dart';


class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final user = FirebaseAuth.instance.currentUser!;
  final usersCollection=FirebaseFirestore.instance.collection('Users');

  Future<void> editField(String field) async
  {
    String newValue="";
    await showDialog(context: context, builder: (context)=>AlertDialog(
      title: Text("Edit $field"),
      content: TextField(
        autofocus: true,
        decoration: InputDecoration(
            hintText: 'Edit $field'
        ),
        onChanged: (value){
          newValue=value;
        },
      ),
      actions: [
        TextButton(child: Text('Cancel'),onPressed: ()=> Navigator.pop(context),),
        TextButton(child: Text('Save'),onPressed: ()=> Navigator.of(context).pop(newValue)),
      ],
    )
    );


    if(newValue.trim().length>0)
    {
      await usersCollection.doc(user.email).update({field:newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: Colors.blue[100],
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('Users').doc(user.email).snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData)
            {
              final userData = snapshot.data!.data() as Map<String,dynamic>;

              return ListView(
                children: [
                  SizedBox(height: 50,),
                  Icon(Icons.person,size: 72,),
                  Text(user.email!,textAlign: TextAlign.center,),
                  SizedBox(height: 20,),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("My Details"),
                  ),
                  MyTextBox(text: userData['username'], sectionName: 'Name',onPressed: ()=> editField('username') ,),
                  MyTextBox(text: userData['bio'], sectionName: 'Bio',onPressed: ()=> editField('bio') ,),
                  MyTextBox(text: 'Empty', sectionName: 'Posts',onPressed: ()=> editField('posts') ,)
                ],
              );

            }
            else if(snapshot.hasError)
            {
              return Center(child: Text("Error${snapshot.error}"));
            }
            return const Center(child: CircularProgressIndicator());
          }
      ),
    );
  }
}
