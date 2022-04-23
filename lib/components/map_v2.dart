import 'dart:async';

import 'package:bus_tracker/models/Location.dart';
import 'package:bus_tracker/models/Route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapComponentV2 extends StatefulWidget {
  final Location? destination, source;
  final Stream<Position>? positionStream;
  final RouteModal? route;
  const MapComponentV2(
      {Key? key,
      required this.destination,
      required this.source,
      required this.route,
      this.positionStream})
      : super(key: key);

  @override
  _MapComponentV2State createState() => _MapComponentV2State();
}

class _MapComponentV2State extends State<MapComponentV2> {
  final Completer<GoogleMapController> _controller = Completer();

  Set<Marker> getMarkers(Position? position,
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>? busSnapshot) {
    Set<Marker> markers = position == null
        ? {}
        : {
            Marker(
              markerId: const MarkerId("currentLocation"),
              position: LatLng(position.latitude, position.longitude),
              // TODO: change icon of current location
              infoWindow: const InfoWindow(
                title: "Current Location",
                snippet: "Your current location",
              ),
            ),
          };
    if (widget.destination != null && widget.source != null) {
      markers.addAll({
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(widget.destination!.lat, widget.destination!.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
        Marker(
          markerId: const MarkerId('source'),
          position: LatLng(widget.source!.lat, widget.source!.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      });
    } else if (widget.destination != null) {
      markers.addAll({
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(widget.destination!.lat, widget.destination!.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      });
    } else if (widget.source != null) {
      markers.addAll({
        Marker(
          markerId: const MarkerId('source'),
          position: LatLng(widget.source!.lat, widget.source!.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      });
    }
    if (busSnapshot != null &&
        busSnapshot.hasData &&
        busSnapshot.data != null) {
      print('data meraaa');
      print(busSnapshot.data!.docs);

      busSnapshot.data!.docs.map((DocumentSnapshot document) {
        print('data bus');
        print(document.data());
      });
    }
    return markers;
  }

  // late CameraPosition cameraPosition;

  CameraPosition getCameraPosition(Position? position) {
    CameraPosition temp = CameraPosition(
      zoom: 14.4746,
      tilt: 0,
      bearing: 0,
      target: LatLng(
        position?.latitude ?? 30.73,
        position?.longitude ?? 76.77,
      ),
    );
    return temp;
  }

  GoogleMap googleMapBuilder(snapshot,
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> busSnapshot) {
    return GoogleMap(
      // onCameraMove: (CameraPosition position) {
      //   setState(() {
      //     cameraPosition = position;
      //   });
      // },
      mapType: MapType.normal,
      initialCameraPosition: getCameraPosition(snapshot.data),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: (busSnapshot != null &&
              busSnapshot.connectionState != ConnectionState.waiting)
          ? getMarkers(snapshot.data, busSnapshot)
          : getMarkers(snapshot.data, null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: StreamBuilder<Position>(
          stream: widget.positionStream,
          builder: (context, snapshot) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('routes')
                  .where('route',
                      isEqualTo:
                          (widget.route != null) ? (widget.route!.id) : (null))
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                      busSnapshot) {
                return googleMapBuilder(snapshot, busSnapshot);
              },
            );
          }),
      width: double.infinity,
      height: double.infinity,
    );
  }
}
