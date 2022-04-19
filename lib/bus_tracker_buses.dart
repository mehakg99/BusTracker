import 'package:bus_tracker/bus_tracker_buses.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:flutter/material.dart';
import 'package:bus_tracker/components/map_component.dart';
import 'dart:async';
import 'custom_scaffold.dart';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class BusTrackerBuses extends StatefulWidget {
  final String routeNumber;

  const BusTrackerBuses({Key? key, this.routeNumber = ""}) : super(key: key);

  @override
  State<BusTrackerBuses> createState() => BusTrackerBusesState();
}

class BusWidget {
  final String busNumber;
  final String busType;
  final double lat;
  final double long;

  BusWidget(this.busNumber, this.busType, this.lat, this.long);

  BusWidget.fromJson(Map<dynamic, dynamic> json)
      : busNumber = json['busNumber'] as String,
        busType = json['busType'] as String,
        lat = double.parse(json['lat'] as String),
        long = double.parse(json['lon'] as String);
}

class BusTrackerBusesState extends State<BusTrackerBuses> {
  Position? _currentPosition;
  Widget singleCard(MapEntry entry) {
    try {
      BusWidget bw = BusWidget.fromJson((entry.value));
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5),
        child: Card(
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_bus,
                  color: bw.busType == "AC" ? Colors.red : Colors.green,
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              // MaterialPageRoute(builder: (context) => BusTrackerBuses()),
              PageRouteBuilder(
                pageBuilder: (c, a1, a2) => MapComponent(
                  busNumber: bw.busNumber,
                  routeNumber: widget.routeNumber,
                ),
                transitionsBuilder: (c, anim, a2, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: Duration(milliseconds: 300),
              ),
            ),
            title: Text('${bw.busNumber} ${bw.busType}'),
            subtitle: _currentPosition != null
                ? Text(
                    'Distance: ${calculateDistance(_currentPosition?.latitude, _currentPosition?.longitude, bw.lat, bw.long).toStringAsFixed(2)} km')
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                        Text('Calculating distance '),
                        SizedBox(width: 5),
                        SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ))
                      ]),
          ),
        ),
      );
    } catch (e) {
      return Text('');
    }
  }

  bool isLoaded = false;

  Map buses = {};
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _getCurrentLocation() {
    Geolocator.requestPermission().then((value) {
      Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
              forceAndroidLocationManager: true)
          .then((Position position) {
        if (!mounted) return;
        setState(() {
          _currentPosition = position;
        });
      }).catchError((e) {
        print(e);
      });
    });
  }

  getBuses() async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("routes/${widget.routeNumber}/buses/");
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
      // print(event.snapshot.value); // DatabaseEventType.value;\
      if (!mounted) return;
      setState(() {
        buses = {};
        try {
          buses = (json.decode(json.encode(event.snapshot.value)));
        } catch (e) {
          print('error getting routes ${e}');
        }
      });
    });
  }

  @override
  initState() {
    super.initState();
    getBuses();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        isLoaded = true;
      });
    });
    Widget routeWidgets =
        (buses.entries.map((entry) => singleCard(entry)).toList()).isNotEmpty
            ? Column(
                children:
                    (buses.entries.map((entry) => singleCard(entry)).toList()),
              )
            : const Center(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'No buses available',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    )),
              );
    ;
    return MyScaffold(
      title: 'Buses',
      body: AnimatedOpacity(
        opacity: isLoaded ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: routeWidgets,
      ),
    );
  }
}
