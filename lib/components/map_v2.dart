import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapComponentV2 extends StatefulWidget {
  final LatLng? destination, source;
  const MapComponentV2({Key? key, this.destination, this.source})
      : super(key: key);

  @override
  _MapComponentV2State createState() => _MapComponentV2State();
}

class _MapComponentV2State extends State<MapComponentV2> {
  final Completer<GoogleMapController> _controller = Completer();

  Set<Marker> getMarkers() {
    if (widget.destination != null && widget.source != null) {
      return {
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destination!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
        Marker(
          markerId: const MarkerId('source'),
          position: widget.source!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };
    } else if (widget.destination != null) {
      return {
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.destination!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    } else if (widget.source != null) {
      return {
        Marker(
          markerId: const MarkerId('source'),
          position: widget.source!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      };
    } else {
      return {};
    }
  }

  CameraPosition cameraPosition = const CameraPosition(
    zoom: 14.4746,
    tilt: 0,
    bearing: 0,
    target: LatLng(
      30.73,
      76.77,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
        markers: getMarkers(),
      ),
      width: double.infinity,
      height: double.infinity,
    );
  }
}
