import 'dart:async';
import 'package:bus_tracker/map_component.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const AppEntry());
}

class MispBusTracker extends StatefulWidget {
  const MispBusTracker({Key? key}) : super(key: key);

  @override
  State<MispBusTracker> createState() => _MispBusTrackerState();
}

class AppEntry extends StatelessWidget {
  const AppEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MispBusTracker();
  }
}

class _MispBusTrackerState extends State<MispBusTracker> {
  bool isLoaded = false;

  void initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Timer(const Duration(seconds: 1), () {
        setState(() {
          isLoaded = true;
        });
      });
    } catch (e) {
      // ignore: avoid_print
      print('Firebase connection Error');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // TODO: firebase init
    initFirebase();
  }

  Widget getCurrentComponent() {
    return isLoaded
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Bus Tracker'),
            ),
            body: Container(
              padding: const EdgeInsets.all(10),
              child: MapComponent(),
            ),
          )
        : const SplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: getCurrentComponent(),
      ),
    );
  }
}
