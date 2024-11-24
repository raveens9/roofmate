import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:roofmate/pages/authpage.dart';
import 'package:roofmate/services/auth_service.dart';
import 'package:roofmate/services/media_service.dart';
import 'package:roofmate/utils.dart';

import 'firebase_options.dart';

void main() async {
  await setup();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  // Register AuthService only if it's not already registered
  if (!GetIt.instance.isRegistered<AuthService>()) {
    GetIt.instance.registerSingleton<AuthService>(AuthService());
  }
  // Register MediaService only if it's not already registered
  if (!GetIt.instance.isRegistered<MediaService>()) {
    GetIt.instance.registerSingleton<MediaService>(MediaService());
  }
  runApp(const MyApp());
}

Future<void> setup() async{
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await registerServices();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          fontFamily: 'SF-Pro',
        scaffoldBackgroundColor: Colors.white
      ),
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
