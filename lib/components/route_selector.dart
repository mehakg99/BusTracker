import 'package:bus_tracker/components/list_tile.dart';
import 'package:bus_tracker/models/Route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:bus_tracker/models/Location.dart';
import 'package:geolocator/geolocator.dart';

const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100,
);

class RouteSelector extends StatefulWidget {
  final void Function() setRoute;
  final Location? source;
  final Location? destination;
  const RouteSelector({
    Key? key,
    required this.setRoute,
    required this.source,
    required this.destination,
  }) : super(key: key);

  @override
  _RouteSelectorState createState() => _RouteSelectorState();
}

class _RouteSelectorState extends State<RouteSelector> {
  List routesData = [];
  @override
  void initState() {
    super.initState();
    getRoutes();
  }

  getRoutes() async {
    // CollectionReference busStops =
    //     FirebaseFirestore.instance.collection("/routes");
    //
    // QuerySnapshot querySnapshot = await busStops.get();
    // setState(() {
    //   routesData =
    //       querySnapshot.docs.map((doc) => RouteModal.fromDoc(doc)).toList();
    //   print(routesData);
    // });
    print('routes 1');
    List lists = [widget.source!.routes, widget.destination!.routes];

    List commonElements = lists
        .fold<Set>(lists.first.toSet(), (a, b) => a.intersection(b.toSet()))
        .toList();
    List<Future> futures = commonElements
        .map<Future>((docReference) => docReference.get())
        .toList();
    List dataFinal = await Future.wait(futures);
    print('routes 2');

    setState(() {
      routesData = dataFinal.map((snapshot) => snapshot.data()).toList();
      print('routes 3');
      print(routesData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 15),
            child: Row(
              children: const [
                Text(
                  'Select a Route',
                  style: TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: routesData
                    .map((route) => Card(
                          child: ListTile(
                            minLeadingWidth: 5,
                            leading: Icon(
                              Icons.call_split,
                              color: Colors.blue,
                            ),
                            title: Row(children: [
                              Text(
                                route['name'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ]),
                            onTap: () {
                              widget.setRoute();
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
    );
  }
}
