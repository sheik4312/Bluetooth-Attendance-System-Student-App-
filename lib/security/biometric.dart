import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/bluetooth%20fix/scan_screen.dart';
import 'package:login/signin&up/wrapper.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FingerprintScreen(),
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FingerprintScreen(),
    );
  }
}

class FingerprintScreen extends StatefulWidget {
  @override
  _FingerprintScreenState createState() => _FingerprintScreenState();
}

class _FingerprintScreenState extends State<FingerprintScreen> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  bool _isFingerprintAvailable = false;
  bool _isAuthenticated = false;
  bool _useFingerprint = false;
  bool _attendanceMarked = false;
  bool _showMarkAttendanceButton = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _checkFingerprintAvailability();
    // Start the timer to periodically check attendance
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkAttendance();
    });
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed to avoid memory leaks
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkFingerprintAvailability() async {
    try {
      _isFingerprintAvailable = await _localAuthentication.isDeviceSupported();
    } catch (e) {
      print("Error checking fingerprint availability: $e");
    }

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _authenticateAndMarkAttendance() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userEmail = currentUser?.email;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;
        final studentDetails = await FirebaseFirestore.instance
            .collection('students')
            .doc(documentId)
            .get();

        final attendanceMarked = studentDetails['attendance'] ?? false;
        final attendanceMarked2 = studentDetails['attendance2'] ?? false;

        if (attendanceMarked && !attendanceMarked2) {
          _isAuthenticated = await _localAuthentication.authenticate(
            localizedReason: 'Scan your fingerprint to mark attendance',
          );

          if (_isAuthenticated) {
            // Perform actions for the authenticated fingerprint
            print('Fingerprint authenticated!');
            await FirebaseFirestore.instance
                .collection('students')
                .doc(documentId)
                .update({'attendance2': true});
            _markAttendance(context, documentId);
          }
        } else if (!attendanceMarked && !attendanceMarked2) {
        } else if (!attendanceMarked && attendanceMarked2) {
        } else {
          print('Attendance already marked!');
          setState(() {
            _attendanceMarked = true;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Attendance already marked'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print("User credentials not found for email: $userEmail");
      }
    } catch (e) {
      print("Error authenticating fingerprint: $e");
    }

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _checkAttendance() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userEmail = currentUser?.email;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;
        final studentDetails = await FirebaseFirestore.instance
            .collection('students')
            .doc(documentId)
            .get();

        bool attendanceMarked = studentDetails['attendance'] ?? false;
        bool attendanceMarked2 = studentDetails['attendance2'] ?? false;

        if (attendanceMarked && !attendanceMarked2) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Mark Your Attendance'),
                content: Text('Your attendance hasn\'t been marked yet.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            _attendanceMarked = attendanceMarked2;
            _showMarkAttendanceButton = !attendanceMarked;
          });
        }
      } else {
        print("User credentials not found for email: $userEmail");
      }
    } catch (e) {
      print("Error checking attendance: $e");
    }
  }

  Future<void> _markAttendance(BuildContext context, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(documentId)
          .update({'attendance2': true});

      setState(() {
        _attendanceMarked = true;
        _showMarkAttendanceButton = false;
      });

      // Call _checkAttendance() here to update the attendance status
      _checkAttendance();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Attendance Marked'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error marking attendance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify Attendance',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 36, 197, 157),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        elevation: 16.0,
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                  FirebaseAuth.instance.currentUser?.displayName ?? "User"),
              accountEmail: Text(
                  FirebaseAuth.instance.currentUser?.email ?? 'user@gmail.com'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images.png'),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(
                    255, 36, 197, 157), // Change this to your desired color
              ),
            ),
            ListTile(
              title: const Text('Verify Attendance'),
              leading: const Icon(Icons.list_alt),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FingerprintScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Bluetooth fix'),
              leading:
                  const Icon(IconData(0xe237, fontFamily: 'MaterialIcons')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () => signout(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.fingerprint,
                  size: 100, // Adjust the size as needed
                  color: Colors.black,
                  // Change the color of the fingerprint icon
                ),
              ],
            ),
            Text(
              'Scan your fingerprint to mark attendance',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20), // Add spacing between icon/text and button
            ElevatedButton(
              onPressed: () {
                _authenticateAndMarkAttendance();
              },
              child: Text(
                'Mark Attendance',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 36, 197, 157),
                padding: EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => wrapper()),
      (route) => false,
    );
  }
}
