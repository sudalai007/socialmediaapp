import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialmediaapp/buttons/button.dart';
import 'package:socialmediaapp/components/text_field.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //TextEditing Controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  //sign in user
  void signIn() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    // try sign in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text);

      // pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);

      //display error Message
      displayMessage(e.code);
    }
  }

  //display a dialog message
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
              "Welcom back, you've been missed",
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
              height: 25,
            ),

            //sign in button
            MyButton(onTap: signIn, text: "Sign in"),
            SizedBox(
              height: 25,
            ),

            //go to register page
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Not a member?',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(
                  width: 8,
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    "Register now",
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
