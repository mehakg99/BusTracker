import 'dart:async';
import 'dart:typed_data';

import 'package:bus_tracker/models/Location.dart';
import 'package:bus_tracker/models/Route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapComponentV2 extends StatefulWidget {
  final Location? destination, source;
  final Stream<Position>? positionStream;
  final RouteModal? route;
  const MapComponentV2({
    Key? key,
    required this.destination,
    required this.source,
    required this.route,
    this.positionStream,
  }) : super(key: key);

  @override
  _MapComponentV2State createState() => _MapComponentV2State();
}

class _MapComponentV2State extends State<MapComponentV2> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Polyline> _polyline = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Future<PolylineResult> getRouteFromWayPoints() async {
    //TODO: update api key
    PointLatLng source = PointLatLng(widget.source!.lat, widget.source!.lng);
    PointLatLng destination =
        PointLatLng(widget.destination!.lat, widget.destination!.lng);
    List<PolylineWayPoint> busStopWayPoints = [];
    for (DocumentReference element in widget.route!.stops) {
      dynamic data = await element.get();
      Location busStop = Location.fromDoc({...data, 'id': element});
      PolylineWayPoint wayPoint =
          PolylineWayPoint(location: '${busStop.lat},${busStop.lng}');
      busStopWayPoints.add(wayPoint);
    }

    return polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyB4h9nOc-5EycIt0XR1g6ZGhyF3Ne8116M', source, destination,
        wayPoints: busStopWayPoints);
  }

  Set<Marker> getMarkers(
      Position? position, AsyncSnapshot<QuerySnapshot>? busSnapshot) {
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

    if (busSnapshot != null) {
      if (widget.route != null) {
        print('polylines promise');
        Future<PolylineResult> resultFuture = getRouteFromWayPoints();
        resultFuture.then((PolylineResult result) {
          //TODO: update this
          print('polylines');
          print(result.points);
          // if (result.isNotEmpty)
          //   {
          //     // loop through all PointLatLng points and convert them
          //     // to a list of LatLng, required by the Polyline
          //     result.forEach((PointLatLng point) {
          //       polylineCoordinates
          //           .add(LatLng(point.latitude, point.longitude));
          //     })
          //   }
        });
        print('data');
        List<Marker> busLocations = [];

        busSnapshot.data!.docs.forEach((DocumentSnapshot document) {
          dynamic data = document.data();
          print(data);
          double lat = data['lat'];
          double lng = data['lng'];
          busLocations.add(Marker(
            markerId: MarkerId('bus${data['number']}'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ));
        });
        // markers.clear();
        print('adding markers');
        markers.addAll(busLocations);
        print(markers);
      }
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

  GoogleMap googleMapBuilder(
      snapshot, AsyncSnapshot<QuerySnapshot> busSnapshot) {
    return GoogleMap(
      // onCameraMove: (CameraPosition position) {
      //   setState(() {
      //     cameraPosition = position;
      //   });
      // },
      polylines: _polyline,
      mapType: MapType.normal,
      initialCameraPosition: getCameraPosition(snapshot.data),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        setState(() {
          _polyline.add(Polyline(
            polylineId: PolylineId('line1'),
            visible: true,
            //latlng is List<LatLng>
            points: polylineCoordinates,
            width: 2,
            color: Colors.blue,
          ));
        });
      },
      markers: (busSnapshot.connectionState != ConnectionState.waiting)
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
            print('widget');
            if (widget.route != null) {
              print(widget.route!.id);
            }
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('buses')
                  .where('route',
                      isEqualTo:
                          (widget.route != null) ? (widget.route!.id) : (null))
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> busSnapshot) {
                return googleMapBuilder(snapshot, busSnapshot);
              },
            );
          }),
      width: double.infinity,
      height: double.infinity,
    );
  }
}
