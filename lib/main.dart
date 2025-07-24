import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:register_user/firebase_options.dart';
import 'package:register_user/home_screen.dart';

void main() async {

  try {
    await Firebase.initializeApp(
      options: firebaseoption,
    );

    print("Firebase Connected Successfully");
  } catch (err) {
    print("Firebase Connection Failed ${err}");
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: HomeScreen(),
      ),
    );
  }
}
