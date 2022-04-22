import 'package:bus_tracker/utils/calculate_distance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Location {
  late final List<dynamic> routes;
  late final String name;
  late final double lat, lng;
  Location(
      {required this.name,
      required this.lat,
      required this.lng,
      required this.routes}) {}
  Location.fromDoc(doc) {
    name = doc['name'];
    lat = doc['lat'];
    lng = doc['lng'];
    routes = doc['routes'];
  }

  double distanceFromLatLng(LatLng position) {
    return calculateDistance(LatLng(lat, lng), position);
  }

  double distanceFromPosition(Position position) =>
      distanceFromLatLng(LatLng(position.latitude, position.longitude));
}
