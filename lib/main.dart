import 'dart:async';
import 'package:bus_tracker/bus_tracker_buses.dart';
import 'package:bus_tracker/favourite_routes.dart';
import 'package:bus_tracker/pages/select_destination.dart';

import 'bus_tracker_routes.dart';
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
  bool isLoadedVisible = false;

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
        Timer(const Duration(milliseconds: 300), () {
          setState(() {
            isLoadedVisible = true;
          });
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
    return isLoadedVisible ? SelectDestination() : SplashScreen(isLoaded);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/routes': (context) => BusTrackerRoutes(),
      },
      home: getCurrentComponent(),
    );
  }
}
