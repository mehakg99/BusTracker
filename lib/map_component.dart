// ignore_for_file: use_function_type_syntax_for_parameters
import 'dart:async';
import 'dart:convert';
import 'package:bus_tracker/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class BusWidget {
  final String busNumber;
  final String busType;
  final double lat;
  final double long;

  BusWidget(this.busNumber, this.busType, this.lat, this.long);

  BusWidget.fromList(List<dynamic> list)
      : busNumber = list[0] as String,
        busType = list[1] as String,
        lat = list[2] as double,
        long = list[3] as double;
}

class MapComponent extends StatefulWidget {
  final String busNumber;
  final String routeNumber;
  const MapComponent({Key? key, this.busNumber = "", this.routeNumber = ""})
      : super(key: key);

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  final Completer<GoogleMapController> _controller = Completer();

  Map busDetails = {};
  bool mapLoading = true;

  getLocation() async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("routes/${widget.routeNumber}/buses/${widget.busNumber}/");
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
      // print(event.snapshot.value); // DatabaseEventType.value;\
      if (!mounted) return;
      setState(() {
        busDetails = {};
        try {
          busDetails = (json.decode(json.encode(event.snapshot.value)));
          print('before update');
          updatePinOnMap(busDetails['lat'], busDetails['lon']);
        } catch (e) {
          print('error getting routes ${e}');
        }
      });
    });
  }

  CameraPosition marker = const CameraPosition(
    zoom: 14.4746,
    tilt: 0,
    bearing: 0,
    target: LatLng(
      30.55,
      76.71,
    ),
  );

  void updatePinOnMap(double lat, double long) async {
    print('updating camera position ${lat} ${long}');
    CameraPosition cPosition = CameraPosition(
      zoom: 14.4746,
      tilt: 0,
      bearing: 0,
      target: LatLng(
        lat,
        long,
      ),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  initState() {
    super.initState();
    getLocation();
    Timer(const Duration(milliseconds: 700), () {
      setState(() {
        mapLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (busDetails["busNumber"] == null || mapLoading) {
      return MyScaffold(
          title: 'Map : ${widget.routeNumber} ${widget.busNumber}',
          body: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Loading",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                  ),
                )
              ],
            ),
          ));
    }
    BusWidget bw = BusWidget.fromList([
      busDetails["busNumber"],
      busDetails["busType"],
      busDetails["lat"],
      busDetails["lon"]
    ]);

    setState(() {
      marker = CameraPosition(
        target: LatLng(bw.lat, bw.long),
        zoom: 14.4746,
      );
    });
    print('inside map position ${marker.target}');
    return MyScaffold(
      title: 'Map : ${widget.routeNumber} ${widget.busNumber}',
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: marker,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          Marker(
            icon: BitmapDescriptor.defaultMarker,
            markerId: MarkerId('${bw.busNumber} ${bw.busType}'),
            position: LatLng(
              marker.target.latitude,
              marker.target.longitude,
            ),
            infoWindow: InfoWindow(
              title: bw.busNumber,
              snippet: bw.busType,
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
