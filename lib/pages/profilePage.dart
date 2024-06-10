import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:roofmate/services/media_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _profileFormKey = GlobalKey();

  late MediaService _mediaService;

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    //_mediaService = _getIt.get<MediaService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 20.0,
        ),
        child: Column(
          children: [
            _headerText(),
            _profileForm(),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Profile",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileForm() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.05,
      ),
      child: Form(
        key: _profileFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _pfpSelectionField(),
            //CustomFormField(),
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width*0.15,
        backgroundImage: selectedImage != null
        ? FileImage(selectedImage!)
        : NetworkImage('https://www.google.com/url?sa=i&url=https%3A%2F%2Ffineartsconference.com%2Fconference-chair-and-committee%2Fimage-placeholder-icon-11%2F&psig=AOvVaw0fmBvYepEm94CBL-2KL4Jh&ust=1717772580456000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCMDf5aKfx4YDFQAAAAAdAAAAABAR') as ImageProvider,
      ),
    );
  }

  Widget _registerButton(){
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        color: Theme.of(context).colorScheme.primary,
        onPressed: () async{
        /*  try{
            if((_registerFormKey.currentState?.validate() ?? false) && 
            selectedImage != null){
              _registerFormKey.currentState?.save();
              bool result = await _authService.signup(email!,password!);
              if(result){
                String? pfpURL = await _storageService.uploadUserPfp(// commented 1
                  file: selectedImage!, uid: _authService.user!.uid, // commented 2
                  );
                  if(pfpURL != null){// commented 1
                    await _databaseService.createUserProfile:(userProfile: UserProfile(// commented 3
                      uid: _authService.user!.uid,// commented 4
                    name: name, pfpURL: pfpURL))// commented 5
                  }
              }
            }
            
          }catch(e){
            print(e);
          }*/
        },
        child: const Text(
          "Confirm",
          style: TextStyle(
            color: Colors.white,
          )
        ),
        )

    );
  }

}
