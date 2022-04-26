import 'dart:async';
import 'package:bus_tracker/pages/select_destination.dart';

import 'bus_tracker_routes.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  await dotenv.load();
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
  bool isLoadedVisible = false;
  initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    Timer(const Duration(seconds: 1), () {
      setState(() {
        isLoaded = true;
      });
      Timer(const Duration(milliseconds: 300), () {
        setState(() {
          isLoadedVisible = true;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initFirebase();
  }

  Widget getCurrentComponent() {
    return isLoadedVisible ? const SelectDestination() : SplashScreen(isLoaded);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/routes': (context) => const BusTrackerRoutes(),
      },
      home: getCurrentComponent(),
    );
  }
}
