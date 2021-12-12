// ignore_for_file: use_function_type_syntax_for_parameters

import 'package:bus_tracker/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class MapComponent extends StatefulWidget {
  final String busNumber;
  MapComponent({Key? key, this.busNumber = ""}) : super(key: key);
  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(30.704649, 76.717873),
    zoom: 14.4746,
  );

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: 'Map',
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: MapComponent._kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          Marker(
            icon: BitmapDescriptor.defaultMarker,
            markerId: const MarkerId('google_plex'),
            position: LatLng(
              MapComponent._kGooglePlex.target.latitude,
              MapComponent._kGooglePlex.target.longitude,
            ),
            infoWindow: const InfoWindow(
              title: "You've tapped the Google Plex",
              snippet: 'Enjoy',
            ),
            onTap: () {
              // ignore: avoid_print
              print('Marker tapped');
            },
          ),
        },
      ),
    );
  }
}
