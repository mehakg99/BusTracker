import 'dart:async';

import 'package:bus_tracker/components/floating_input_field.dart';
import 'package:bus_tracker/components/map_v2.dart';
import 'package:bus_tracker/components/pickup_component.dart';
import 'package:bus_tracker/components/route_selector.dart';
import 'package:bus_tracker/components/selected_source.dart';
import 'package:bus_tracker/models/Location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100,
);

class SelectDestination extends StatefulWidget {
  const SelectDestination({Key? key}) : super(key: key);

  @override
  State<SelectDestination> createState() => _SelectDestinationState();
}

class _SelectDestinationState extends State<SelectDestination> {
  List<Location> destinationsData = [];

  setRoute() {
    //  TODO: set route here
  }
  getDestinations() async {
    CollectionReference busStops =
        FirebaseFirestore.instance.collection("/busStops");

    QuerySnapshot querySnapshot = await busStops.get();

    destinationsData =
        querySnapshot.docs.map((doc) => Location.fromDoc(doc)).toList();
  }

  @override
  initState() {
    super.initState();
    _checkLocationPermissions();
    getDestinations();
  }

  Location? destination, source;
  bool locationPermissionProvided = true;
  Stream<Position>? positionStream;

  void setDestination(Location? location) {
    setState(() {
      if (location != null) {
        destination = location;
      } else {
        destination = null;
      }
    });
  }

  void setSource(Location? location) {
    setState(() {
      if (location != null) {
        source = location;
      } else {
        source = null;
      }
    });
  }

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

  //
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      MapComponentV2(
                        destination: destination,
                        source: source,
                        positionStream: positionStream,
                      ),
                      (source != null)
                          ? SelectedSource(
                              setSource: setSource,
                              source: source!.name,
                            )
                          : Text('hi'),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          child: FloatingInputField(
                            destination: destination,
                            source: source,
                            title: "Destination",
                            listData: destinationsData,
                            setDestination: setDestination,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            FractionallySizedBox(
                heightFactor: 0.4,
                child: ((source == null)
                    ? PickUpComponent(
                        source: source,
                        setSource: setSource,
                        listData: destinationsData,
                      )
                    : (source != null && destination != null)
                        ? RouteSelector(
                            source: source,
                            destination: destination,
                            setRoute: setRoute)
                        : Container())),
            // TODO: SHOW LOCATION PERMISSION MODAL HERE
          ],
        ),
      ),
    );
  }
}
