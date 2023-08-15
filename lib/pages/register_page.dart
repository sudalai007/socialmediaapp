import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:socialmediaapp/buttons/button.dart';
import 'package:socialmediaapp/components/text_field.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //TextEditing Controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  void signUp() async {
    //show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    //make sure password matched
    if (passwordTextController.text != confirmPasswordTextController.text) {
      //pop loading circle
      Navigator.pop(context);
      //show error to message
      displayMessage("Password don't match! ");
      return;
    }
    //try creating the user
    try {
      //Create the user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      //after Creating the User, create a new document in cloud firestore called users
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': emailTextController.text.split('@')[0], //initial username
        'bio': 'Empty bio ..' //initially empty bio
        //add any additional fields as needed
      });

      //pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // pop leading circle
      Navigator.pop(context);

      //show error to user
      displayMessage(e.code);
    }
  }

  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
          child: Center(
              child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Create Icon
            Icon(
              Icons.lock,
              size: 100,
            ),
            SizedBox(
              height: 50,
            ),

            //Create Welcome back message
            Text(
              "Lets create an account for you",
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(
              height: 50,
            ),

            //Create email textfield
            MyTextField(
                controller: emailTextController,
                hinttext: 'Email',
                obscureText: false),
            SizedBox(
              height: 10,
            ),

            //Create passward texfield
            MyTextField(
                controller: passwordTextController,
                hinttext: 'Password',
                obscureText: true),
            SizedBox(
              height: 10,
            ),

            //Create passward texfield
            MyTextField(
                controller: confirmPasswordTextController,
                hinttext: 'Confrim Password',
                obscureText: true),
            SizedBox(
              height: 25,
            ),

            //sign in button
            MyButton(onTap: signUp, text: "Sign up"),
            SizedBox(
              height: 25,
            ),

            //go to register page
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(
                  width: 8,
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    "Log in",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                )
              ],
            )
          ],
        ),
      ))),
    );
  }
}
