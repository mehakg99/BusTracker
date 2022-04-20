import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapComponentV2 extends StatefulWidget {
  const MapComponentV2({Key? key}) : super(key: key);

  @override
  _MapComponentV2State createState() => _MapComponentV2State();
}

class _MapComponentV2State extends State<MapComponentV2> {
  final Completer<GoogleMapController> _controller = Completer();

  CameraPosition cameraPosition = const CameraPosition(
    zoom: 14.4746,
    tilt: 0,
    bearing: 0,
    target: LatLng(
      30.55,
      76.71,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GoogleMap(
        onCameraMove: (CameraPosition position) {
          setState(() {
            cameraPosition = position;
          });
        },
        mapType: MapType.normal,
        initialCameraPosition: cameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {},
      ),
      width: double.infinity,
      height: double.infinity,
    );
  }
}
