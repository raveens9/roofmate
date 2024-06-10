import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:roofmate/consts.dart';
import 'package:roofmate/models/custom_form_field.dart';
import 'package:roofmate/models/user_profile.dart';
import 'package:roofmate/services/auth_service.dart';
import 'package:roofmate/services/database_service.dart';
import 'package:roofmate/services/media_service.dart';
import 'package:roofmate/services/storage_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({Key? key, this.onTap}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  late MediaService _mediaService;
  late AuthService _authService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  String? email, password, name;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          children: [
            _headerText(),
            _registerForm(),
            _registerButton(),
            SizedBox(height:20),
            _loginRedirectButton(),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Welcome!",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.normal,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
  return Container(
    height: MediaQuery.of(context).size.height * 0.55, 
    margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.05),
    child: Form(
      key: _registerFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _pfpSelectionField(),
          SizedBox(height: 70.0), 
          CustomFormField(
            hintText: "Name",
            height: MediaQuery.sizeOf(context).height * 0.1,
            validationRegEx: NAME_VALIDATION_REGEX,
            onSaved: (value) {
              setState(() {
                name = value;
              });
            },
          ),
          CustomFormField(
            hintText: "Email",
            height: MediaQuery.sizeOf(context).height * 0.1,
            validationRegEx: EMAIL_VALIDATION_REGEX,
            onSaved: (value) {
              setState(() {
                email = value;
              });
            },
          ),
          CustomFormField(
            hintText: "Password",
            height: MediaQuery.sizeOf(context).height * 0.1,
            validationRegEx: PASSWORD_VALIDATION_REGEX,
            obscureText: true,
            onSaved: (value) {
              setState(() {
                password = value;
              });
            },
          ),
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
        radius: MediaQuery.of(context).size.width * 0.185,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  void showCustomSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  spreadRadius: 3,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Widget _registerButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),  
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: 70,
        child: MaterialButton(
          color: const Color.fromARGB(255, 3, 3, 3),
          onPressed: () async {
            try {
              if (selectedImage == null) {
                showCustomSnackbar(context, 'Please upload a profile picture.');
                return; // Stop further execution
              }
              if ((_registerFormKey.currentState?.validate() ?? false)) {
                _registerFormKey.currentState?.save();
                bool result = await _authService.signup(email!, password!);
                if (result) {
                  String? pfpURL = await _storageService.uploadUserPfp(
                    file: selectedImage!,
                    uid: _authService.user!.uid,
                  );
                  if (pfpURL != null) {
                    await _databaseService.createUserProfile(
                      userProfile: UserProfile(
                        uid: _authService.user!.uid,
                        name: name!,
                        pfpURL: pfpURL,
                      ),
                    );
                    print("User profile created successfully");
                  } else {
                    throw Exception("Unable to upload user profile picture");
                  }
                } else {
                  showCustomSnackbar(context, 'Failed to register user. Please try again.');
                }
              }
            } catch (e) {
              print('Error during registration: $e');
              showCustomSnackbar(context, 'An unexpected error occurred. Please try again later.');
            }
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginRedirectButton() {
    return RichText(
      text: TextSpan(
        text: 'Already have an account? ',
        style: TextStyle(
          color: Colors.black,
        ),
        children: <TextSpan>[
          TextSpan(
            text: ' Login Now',
            style: TextStyle(
              color: Colors.blueAccent,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = widget.onTap,
          ),
        ],
      ),
    );
  }
}


