import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  late final DocumentReference<Map<String, dynamic>> route;
  late final String name;
  late final double lat, lng;
  Location(
      {required this.name,
      required this.lat,
      required this.lng,
      required this.route}) {}
  Location.fromDoc(doc) {
    name = doc['name'];
    lat = doc['lat'];
    lng = doc['lng'];
    route = doc['route'];
  }
}
