import 'dart:async';

import 'package:bus_tracker/components/floating_input_field.dart';
import 'package:bus_tracker/components/map_v2.dart';
import 'package:bus_tracker/components/permission_denied.dart';
import 'package:bus_tracker/components/pickup_component.dart';
import 'package:bus_tracker/components/route_selector.dart';
import 'package:bus_tracker/components/selected_route.dart';
import 'package:bus_tracker/components/selected_source.dart';
import 'package:bus_tracker/models/Location.dart';
import 'package:bus_tracker/models/Route.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectDestination extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final bool locationPermissionProvided;
  const SelectDestination(
      {Key? key,
      required this.snapshot,
      required this.locationPermissionProvided})
      : super(key: key);

  @override
  State<SelectDestination> createState() => _SelectDestinationState();
}

class _SelectDestinationState extends State<SelectDestination>
    with AutomaticKeepAliveClientMixin<SelectDestination> {
  @override
  bool get wantKeepAlive => true;

  List<Location> destinationsData = [];
  void swapStops() {
    if (destination != null && source != null) {
      Location tempLocation = destination!;
      setRoute(null);
      setDestination(null);
      setDestination(source);
      setSource(tempLocation);
      print(source!.lat);
      print(destination!.lat);
    }
  }

  getDestinations() async {
    CollectionReference busStops =
        FirebaseFirestore.instance.collection("busStops");

    QuerySnapshot querySnapshot = await busStops.get();
    print(querySnapshot);
    setState(() {
      destinationsData = querySnapshot.docs.map((doc) {
        dynamic data = doc;
        DocumentReference<Map<String, dynamic>> ref =
            FirebaseFirestore.instance.doc('busStops/${doc.id}');
        return Location.fromDoc({...(data.data()), "id": ref});
      }).toList();
    });
  }

  @override
  initState() {
    super.initState();
    getDestinations();
  }

  Location? destination, source;
  RouteModal? route;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  List busStopWaypointsMarkers = [];

  Future<PolylineResult> getRouteFromWayPoints() async {
    PointLatLng sourceObj = PointLatLng(source!.lat, source!.lng);
    PointLatLng destinationObj =
        PointLatLng(destination!.lat, destination!.lng);
    List<PolylineWayPoint> busStopWayPoints = [];
    setState(() {
      busStopWaypointsMarkers = [];
    });
    int destinationInd = route!.stops.indexOf(destination!.id);
    int sourceInd = route!.stops.indexOf(source!.id);
    for (DocumentReference element in route!.stops) {
      int elementInd = route!.stops.indexOf(element);
      if (elementInd <= sourceInd) {
        continue;
      }
      if (elementInd >= destinationInd) {
        break;
      }
      dynamic data = await element.get();
      Location busStop = Location.fromDoc({...data.data(), 'id': element});
      PolylineWayPoint wayPoint =
          PolylineWayPoint(location: '${busStop.lat},${busStop.lng}');
      print('adding waypoint!');
      busStopWayPoints.add(wayPoint);
      setState(() {
        busStopWaypointsMarkers.add(busStop);
      });
    }
    print('waypoints');
    print(busStopWayPoints);
    return polylinePoints.getRouteBetweenCoordinates(
        dotenv.env['GOOGLE_API_KEY']!, sourceObj, destinationObj,
        wayPoints: busStopWayPoints);
  }

  void setPolylineCoordinates() {
    print('polylines promise');
    Future<PolylineResult> resultFuture = getRouteFromWayPoints();
    resultFuture.then((PolylineResult result) {
      print('polylines');
      print(result.points);
      if (result.points.isNotEmpty) {
        setState(() {
          result.points.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
        });
      }
    });
    print('data');
  }

  setRoute(RouteModal? routeParam) {
    setState(() {
      route = routeParam;
    });
    if (route != null) {
      setPolylineCoordinates();
    } else {
      setState(() {
        polylineCoordinates = [];
      });
    }
    //  TODO: set route here
  }

  void setDestination(Location? location) {
    setRoute(null);
    setState(() {
      if (location != null) {
        destination = location;
      } else {
        destination = null;
      }
    });
  }

  void setSource(Location? location) {
    setRoute(null);
    setState(() {
      if (location != null) {
        source = location;
      } else {
        source = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Position? currentPosition = widget.snapshot.data;

    return widget.locationPermissionProvided
        ? Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        MapComponentV2(
                          route: route,
                          destination: destination,
                          source: source,
                          currentPosition: currentPosition,
                          isLoading: !widget.snapshot.hasData,
                          polylineCoordinates: polylineCoordinates,
                          busStopWaypointsMarkers: busStopWaypointsMarkers,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, left: 10, right: 0, bottom: 0),
                                    child: FloatingInputField(
                                      destination: destination,
                                      source: source,
                                      title: "Destination",
                                      listData: destinationsData,
                                      setDestination: setDestination,
                                    ),
                                  ),
                                  (source != null)
                                      ? SelectedSource(
                                          setSource: setSource,
                                          source: source!.name,
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  // width: 50,
                                  height: 200,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: (source != null &&
                                                destination != null)
                                            ? swapStops
                                            : null,
                                        child: const Icon(
                                          Icons.swap_vert,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              FractionallySizedBox(
                  heightFactor: 0.4,
                  child: ((source == null)
                      ? PickUpComponent(
                          destination: destination,
                          source: source,
                          setSource: setSource,
                          listData: destinationsData,
                          currentPosition: currentPosition,
                          isLoading: !widget.snapshot.hasData,
                        )
                      : (source != null && destination != null)
                          ? (route == null)
                              ? RouteSelector(
                                  source: source,
                                  destination: destination,
                                  setRoute: setRoute)
                              : SelectedRoute(
                                  route: route!.name, setRoute: setRoute)
                          : Container())),
              // TODO: SHOW LOCATION PERMISSION MODAL HERE
            ],
          )
        : const PermissionDenied();
  }
}
