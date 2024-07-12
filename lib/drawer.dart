import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class SDrawer extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  SDrawer({Key? key}) : super(key: key);

  signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 16.0,
      child: Container(
        color: Colors.white, // Change the color here
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(37, 56, 141,
                    1), // Change the color of the drawer header to blue
              ),
              accountName: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('stu login')
                    .doc(user!.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.hasData && snapshot.data!.exists) {
                    return Text(snapshot.data!['name']);
                  } else {
                    return const Text(
                        'User'); // Fallback if name is not available
                  }
                },
              ),
              accountEmail: Text('${user?.email ?? ""}'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images.png'),
              ),
            ),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () => signOut(),
            ),
            const Divider(
              height: 0.1,
            )
          ],
        ),
      ),
    );
  }
}
