import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:bus_tracker/pages/emergency_contacts.dart';
import 'package:bus_tracker/pages/select_destination.dart';
import 'package:bus_tracker/pages/sos_button.dart';
import 'package:geolocator/geolocator.dart';

const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100,
);

class Index extends StatefulWidget {
  Index({Key? key}) : super(key: key);

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool locationPermissionProvided = true;
  Stream<Position>? positionStream;
  int _selectedIndex = 0;

  late PageController _pageController;

  void _checkLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // TODO: Show dialog to enable location services.
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      setState(() {
        locationPermissionProvided = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // TODO: show dialog to enable location services.
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        setState(() {
          locationPermissionProvided = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // TODO: show dialog to enable location services.
      // Permissions are denied forever, handle appropriately.
      setState(() {
        locationPermissionProvided = false;
      });
      return;
    }
    setState(() {
      positionStream ??=
          Geolocator.getPositionStream(locationSettings: locationSettings);
      locationPermissionProvided = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermissions();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  List appbar = [
    null,
    AppBar(
      title: const Text('Contact Details'),
    ),
    AppBar(
      title: const Text('Emergency'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Position>(
        stream: positionStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return locationPermissionProvided
              ? SafeArea(
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: appbar[_selectedIndex],
                    bottomNavigationBar: BottomNavigationBar(
                      selectedLabelStyle: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.home,
                          ),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.person,
                          ),
                          label: 'Contacts',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.emergency,
                          ),
                          label: 'Emergency',
                        ),
                      ],
                      currentIndex: _selectedIndex,
                      onTap: (newIndex) {
                        setState(() {
                          _selectedIndex = newIndex;
                          _pageController.jumpToPage(newIndex);
                        });
                      },
                    ),
                    body: PageView(
                      controller: _pageController,
                      children: [
                        SelectDestination(
                            snapshot: snapshot,
                            locationPermissionProvided:
                                locationPermissionProvided),
                        EmergencyContacts(),
                        SosButton(
                            snapshot: snapshot,
                            locationPermissionProvided:
                                locationPermissionProvided),
                      ],
                      physics: NeverScrollableScrollPhysics(),
                    ),
                  ),
                )
              : Container(
                  color: Colors.blue,
                  child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Image(image: AssetImage('assets/logo.png')),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'The location service on the device is disabled.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ]),
                  ),
                );
        });
  }
}
