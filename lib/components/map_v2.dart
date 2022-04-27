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
  const MapComponentV2({
    Key? key,
    required this.destination,
    required this.source,
    required this.route,
    required this.currentPosition,
    required this.isLoading,
    required this.polylineCoordinates,
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
  final Completer<GoogleMapController> _controller = Completer();

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
                snippet: "Your current location",
              ),
              icon: userIcon,
            ),
          };
    if (widget.destination != null && widget.source != null) {
      markers.addAll({
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(widget.destination!.lat, widget.destination!.lng),
          icon: busStopDestinationIcon,
        ),
        Marker(
          markerId: const MarkerId('source'),
          position: LatLng(widget.source!.lat, widget.source!.lng),
          icon: busStopIcon,
        ),
      });
    } else if (widget.destination != null) {
      markers.addAll({
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(widget.destination!.lat, widget.destination!.lng),
          icon: busStopDestinationIcon,
        ),
      });
    } else if (widget.source != null) {
      markers.addAll({
        Marker(
          markerId: const MarkerId('source'),
          position: LatLng(widget.source!.lat, widget.source!.lng),
          icon: busStopIcon,
        ),
      });
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
        _controller.complete(controller);
      },
      markers: (busSnapshot.connectionState != ConnectionState.waiting)
          ? getMarkers(currentPosition, busSnapshot, busIconNonAC, busIconAC,
              busStopIcon, wayPointIcon, busStopDestinationIcon, userIcon)
          : getMarkers(currentPosition, null, busIconNonAC, busIconAC,
              busStopIcon, wayPointIcon, busStopDestinationIcon, userIcon),
    );
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
        await generateMarkerFromIcon(Icons.push_pin, Colors.blue, 120.0);
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
    return SizedBox(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('buses')
            .where('route',
                isEqualTo: (widget.route != null) ? (widget.route!.id) : (null))
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
    );
  }
}
