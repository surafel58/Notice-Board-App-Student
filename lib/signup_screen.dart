import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:email_validator/email_validator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isValid = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
          ),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(labelText: "Email"),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (email) {
              if (email != null && !EmailValidator.validate(email)) {
                isValid = false;
                return 'Enter a valid email';
              } else {
                isValid = true;
                return null;
              }
            },
          ),
          SizedBox(
            height: 4,
          ),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (password) {
              if (password != null && password.length < 7) {
                isValid = false;
                return 'Enter min 7 characters';
              } else {
                isValid = true;
                return null;
              }
            },
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text != "" &&
                  emailController.text != "" &&
                  isValid) {
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim());

                  showDialog(
                    context: context,
                    builder: (context) => const Center(
                      child: AlertDialog(
                        title: Text(
                          "Sign up successful!",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ).then((value) => Navigator.pop(context));
                } on FirebaseAuthException catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) => const Center(
                      child: AlertDialog(
                        title: Text(
                          "Email already exists!",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_forward),
                Text("Sign Up"),
              ],
            ),
          ),
          SizedBox(
            height: 2,
            child: Divider(
              thickness: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an Account?"),
              TextButton(
                onPressed: () {
                  // Navigator.of(context).pushReplacementNamed("/loginscreen");
                  Navigator.pop(context);
                },
                child: Text("Sign in"),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
