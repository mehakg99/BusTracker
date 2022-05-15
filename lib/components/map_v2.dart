import 'dart:async';
import 'dart:ui';

import 'package:bus_tracker/models/Location.dart';
import 'package:bus_tracker/models/Route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapComponentV2 extends StatefulWidget {
  final Location? destination, source;
  final RouteModal? route;
  final Position? currentPosition;
  final bool isLoading;
  final List<LatLng> polylineCoordinates;
  final List busStopWaypointsMarkers;
  const MapComponentV2({
    Key? key,
    required this.destination,
    required this.source,
    required this.route,
    required this.currentPosition,
    required this.isLoading,
    required this.polylineCoordinates,
    required this.busStopWaypointsMarkers,
  }) : super(key: key);

  @override
  _MapComponentV2State createState() => _MapComponentV2State();
}

class _MapComponentV2State extends State<MapComponentV2> {
  BitmapDescriptor busIconNonAC = BitmapDescriptor.defaultMarker;
  BitmapDescriptor busIconAC = BitmapDescriptor.defaultMarker;
  BitmapDescriptor busStopIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor busStopDestinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor wayPointIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor userIcon = BitmapDescriptor.defaultMarker;
  late var myController;
  final Completer<GoogleMapController> _controller = Completer();
  resetCameraFinal(Position? position) {
    if (position != null) {
      if (widget.destination != null && widget.source != null) {
        updateCameraLocation(
            LatLng(widget.source!.lat, widget.source!.lng),
            LatLng(widget.destination!.lat, widget.destination!.lng),
            myController);
      } else if (widget.destination != null) {
        updateCameraLocation(
            LatLng(widget.destination!.lat, widget.destination!.lng),
            LatLng(position.latitude, position.longitude),
            myController);
      } else if (widget.source != null) {
        updateCameraLocation(LatLng(widget.source!.lat, widget.source!.lng),
            LatLng(position.latitude, position.longitude), myController);
      } else {
        updateCameraLocation(LatLng(position.latitude, position.longitude),
            LatLng(position.latitude, position.longitude), myController);
      }
    }
  }

  resetCamera() {
    if (widget.currentPosition != null) {
      resetCameraFinal(widget.currentPosition);
    }
  }

  generateMarkerFromIcon(iconData, Color color, double size) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final iconStr = String.fromCharCode(iconData.codePoint);
    textPainter.text = TextSpan(
        text: iconStr,
        style: TextStyle(
          letterSpacing: 0.0,
          fontSize: size,
          fontFamily: iconData.fontFamily,
          color: color,
        ));
    textPainter.layout();
    textPainter.paint(canvas, Offset(0.0, 0.0));
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    final bitmapDescriptor =
        BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
    return bitmapDescriptor;
  }

  Set<Marker> getMarkers(
    Position? position,
    AsyncSnapshot<QuerySnapshot>? busSnapshot,
    BitmapDescriptor busIconNonAC,
    BitmapDescriptor busIconAC,
    BitmapDescriptor busStopIcon,
    BitmapDescriptor wayPointIcon,
    BitmapDescriptor busStopDestinationIcon,
    BitmapDescriptor userIcon,
  ) {
    Set<Marker> markers = position == null
        ? {}
        : {
            Marker(
              markerId: const MarkerId("currentLocation"),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: const InfoWindow(
                title: "Current Location",
              ),
              icon: userIcon,
            ),
          };
    if (position != null) {
      if (widget.destination != null && widget.source != null) {
        markers.addAll({
          Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(widget.destination!.lat, widget.destination!.lng),
            icon: busStopDestinationIcon,
            infoWindow: InfoWindow(
              title: widget.destination?.name,
            ),
          ),
          Marker(
            markerId: const MarkerId('source'),
            position: LatLng(widget.source!.lat, widget.source!.lng),
            icon: busStopIcon,
            infoWindow: InfoWindow(
              title: widget.source?.name,
            ),
          ),
        });
        resetCamera();
      } else if (widget.destination != null) {
        markers.addAll({
          Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(widget.destination!.lat, widget.destination!.lng),
            icon: busStopDestinationIcon,
            infoWindow: InfoWindow(
              title: widget.destination?.name,
            ),
          ),
        });
        resetCamera();
      } else if (widget.source != null) {
        markers.addAll({
          Marker(
            markerId: const MarkerId('source'),
            position: LatLng(widget.source!.lat, widget.source!.lng),
            icon: busStopIcon,
            infoWindow: InfoWindow(
              title: widget.source?.name,
            ),
          ),
        });
        resetCamera();
      } else {
        resetCamera();
      }
      for (Location busStop in widget.busStopWaypointsMarkers) {
        markers.add(Marker(
          markerId: MarkerId("${busStop.id}"),
          position: LatLng(busStop.lat, busStop.lng),
          icon: wayPointIcon,
          infoWindow: InfoWindow(
            title: busStop.name,
          ),
        ));
      }
    }

    if (busSnapshot != null) {
      if (widget.route != null) {
        List<Marker> busLocations = [];

        busSnapshot.data!.docs.forEach((DocumentSnapshot document) {
          dynamic data = document.data();
          double lat = data['lat'];
          double lng = data['lng'];
          busLocations.add(Marker(
            markerId: MarkerId('bus${data['number']}'),
            position: LatLng(lat, lng),
            icon: data['type'] == "AC" ? busIconAC : busIconNonAC,
            infoWindow: InfoWindow(
              title: "${data['number']}",
              snippet: "Size: ${data['size']}",
            ),
          ));
        });
        // markers.clear();
        markers.addAll(busLocations);
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
    currentPosition,
    AsyncSnapshot<QuerySnapshot> busSnapshot,
    BitmapDescriptor busIconNonAC,
    busIconAC,
    busStopIcon,
    wayPointIcon,
    busStopDestinationIcon,
    userIcon,
  ) {
    return GoogleMap(
      // onCameraMove: (CameraPosition position) {
      //   setState(() {
      //     cameraPosition = position;
      //   });
      // },
      polylines: {
        Polyline(
          polylineId: PolylineId('line1'),
          visible: true,
          //latlng is List<LatLng>
          points: widget.polylineCoordinates,
          width: 2,
          color: Colors.blue,
        )
      },
      mapType: MapType.normal,
      initialCameraPosition: getCameraPosition(currentPosition),
      onMapCreated: (GoogleMapController controller) {
        setState(() {
          myController = controller;
        });
        _controller.complete(controller);
      },
      markers: (busSnapshot.connectionState != ConnectionState.waiting)
          ? getMarkers(currentPosition, busSnapshot, busIconNonAC, busIconAC,
              busStopIcon, wayPointIcon, busStopDestinationIcon, userIcon)
          : getMarkers(currentPosition, null, busIconNonAC, busIconAC,
              busStopIcon, wayPointIcon, busStopDestinationIcon, userIcon),
    );
  }

  Future<void> updateCameraLocation(
    LatLng source,
    LatLng destination,
    GoogleMapController mapController,
  ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }

  getBusIcon() async {
    print('updating busIcon');
    BitmapDescriptor busIconNewNonAC =
        await generateMarkerFromIcon(Icons.directions_bus, Colors.green, 100.0);
    BitmapDescriptor busIconNewAC =
        await generateMarkerFromIcon(Icons.directions_bus, Colors.red, 100.0);
    BitmapDescriptor busStopNewSourceIcon =
        await generateMarkerFromIcon(Icons.push_pin, Colors.red, 120.0);
    BitmapDescriptor busStopNewDestinationIcon =
        await generateMarkerFromIcon(Icons.push_pin, Colors.green, 120.0);
    BitmapDescriptor wayPointNewIcon =
        await generateMarkerFromIcon(Icons.adjust, Colors.blueGrey, 60.0);
    BitmapDescriptor userIconNew =
        await generateMarkerFromIcon(Icons.man, Colors.blue, 100.0);
    setState(() {
      busIconNonAC = busIconNewNonAC;
      busIconAC = busIconNewAC;
      busStopIcon = busStopNewSourceIcon;
      busStopDestinationIcon = busStopNewDestinationIcon;
      wayPointIcon = wayPointNewIcon;
      userIcon = userIconNew;
      print('updated busIcon');
    });
  }

  @override
  initState() {
    getBusIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('buses')
              .where('route',
                  isEqualTo:
                      (widget.route != null) ? (widget.route!.id) : (null))
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> busSnapshot) {
            return googleMapBuilder(
                widget.currentPosition,
                busSnapshot,
                busIconNonAC,
                busIconAC,
                busStopIcon,
                wayPointIcon,
                busStopDestinationIcon,
                userIcon);
          },
        ),
        width: double.infinity,
        height: double.infinity,
      ),
      Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                resetCamera();
              },
              child: Icon(Icons.location_searching, color: Colors.white),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(2),
                primary: Colors.blue, // <-- Button color
                onPrimary: Colors.red, // <-- Splash color
              ),
            ),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    ]);
  }
}
