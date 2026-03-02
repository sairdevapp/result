import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'screens/home_screen.dart';

void main() async {
  // Ensure Flutter engine is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for Web manually
  await Firebase.initializeApp(
    options: DefaultFirebaseConfig.webOptions,
  );

  runApp(const ResultCheckingApp());
}

class ResultCheckingApp extends StatelessWidget {
  const ResultCheckingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Results',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomeScreen(),
    );
  }
}