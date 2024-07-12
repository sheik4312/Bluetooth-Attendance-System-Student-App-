import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'wrapper.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();

  String? validatePassword(String value) {
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? validateEmail(String value) {
    if (!value.endsWith("@psnacet.edu.in")) {
      return 'Please enter a valid Gmail address';
    }
    return null;
  }

  Future<void> signup() async {
    String? passwordError = validatePassword(password.text);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(passwordError),
      ));
      return;
    }

    String? emailError = validateEmail(email.text);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(emailError),
      ));
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );

      await FirebaseFirestore.instance
          .collection('students login')
          .doc(userCredential.user!.uid)
          .set({
        'name': name.text,
        'email': email.text,
        // Remove the role field from here
      });

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const wrapper()));
    } catch (e) {
      print("Error signing up: $e");
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("The email address is already in use by another account."),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error signing up. Please try again."),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Your', // Added text
                    style: const TextStyle(
                      fontSize: 36, // Adjust size as needed
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      // Adjust color as needed
                    ),
                  ),
                  const Text(
                    'Account', // Added text
                    style: TextStyle(
                      fontSize: 36, // Adjust size as needed
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      // Adjust color as needed
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Make your mark, sign up! ', // Added text
                    style: TextStyle(
                      fontSize: 16, // Adjust size as needed
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 1,
                      // Adjust color as needed
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  const Text(
                    'Name', // Added text
                    style: TextStyle(
                      fontSize: 16, // Adjust size as needed
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      // Adjust color as needed
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      hintText: 'Enter name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Email Address', // Added text
                    style: TextStyle(
                      fontSize: 16, // Adjust size as needed
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      // Adjust color as needed
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      hintText: 'Enter email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Enter password', // Added text
                    style: TextStyle(
                      fontSize: 16, // Adjust size as needed
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      // Adjust color as needed
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 90.0,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 36, 197, 157), // Set button color to blue
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
