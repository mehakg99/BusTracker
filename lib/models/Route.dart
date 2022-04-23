import 'package:bus_tracker/utils/calculate_distance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModal {
  late final List<dynamic> stops;
  late final String name;
  late final DocumentReference<Map<String, dynamic>> id;
  RouteModal({required this.name, required this.stops}) {}
  RouteModal.fromDoc(doc) {
    name = doc['name'];
    stops = doc['stops'];
    id = doc['id'];
  }
}
