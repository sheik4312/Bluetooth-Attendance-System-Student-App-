import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:login/drawer.dart';

import '../security/biometric.dart';
import 'scan_result_tile.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen(
      (results) {
        _scanResults = results;
        if (mounted) {
          setState(() {});
        }
      },
    );

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future onScanPressed() async {
    _systemDevices = await FlutterBluePlus.systemDevices;

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    FlutterBluePlus.stopScan();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bluetooth Error Fixed'),
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

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: FloatingActionButton(
            onPressed: onStopPressed,
            backgroundColor: Colors.red,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            child: const Icon(Icons.stop),
          ));
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 50.0), // Add left and right padding
        child: FloatingActionButton(
          onPressed: onScanPressed,
          child: const Text("Fix it"),
          backgroundColor: const Color.fromRGBO(
              225, 230, 255, 1), // Background color of the button
          shape: RoundedRectangleBorder(
            side: const BorderSide(
                color: Color.fromRGBO(37, 56, 141, 1),
                width: 2), // Border color
            borderRadius:
                BorderRadius.circular(40), // Optional: for rounded corners
          ),
        ),
      );
    }
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () {},
          ),
        )
        .toList();
  }

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Fix Bluetooth",
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
          backgroundColor: Color.fromARGB(255, 36, 197, 157),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: Drawer(
          elevation: 16.0,
          child: Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(
                    FirebaseAuth.instance.currentUser?.displayName ?? "User"),
                accountEmail: Text(FirebaseAuth.instance.currentUser?.email ??
                    'user@gmail.com'),
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
                    MaterialPageRoute(
                        builder: (context) => FingerprintScreen()),
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
                onTap: () => signout(),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                buildScanButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
