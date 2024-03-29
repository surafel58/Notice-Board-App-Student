import 'package:digital_notice_board/home_screen.dart';
import 'package:digital_notice_board/login_screen.dart';
import 'package:digital_notice_board/signup_screen.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'constants.dart';
import 'detail_screen.dart';

///loading screen mechemer
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Notice Board',
      initialRoute: '/',
      theme: ThemeData.dark().copyWith(
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 3, color: kPrimaryColor),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
        ),
        appBarTheme: const AppBarTheme(
          // centerTitle: true,
          color: kPrimaryColor,
        ),
      ),
      routes: {
        '/': (context) => const MainScreen(),
        '/loginscreen': (context) => const LoginScreen(),
        '/homescreen': (context) => const HomeScreen(),
        '/signupscreen': (context) => const SignupScreen(),
        '/detailscreen': (context) => const DetailScreen(),
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error: Something went wrong"));
          } else if (snapshot.hasData) {
            return HomeScreen();
          } else
            return LoginScreen();
        },
      ),
    );
  }
}
