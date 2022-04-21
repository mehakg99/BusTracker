import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double calculateDistance(LatLng pos1, LatLng pos2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((pos2.latitude - pos1.latitude) * p) / 2 +
      c(pos1.latitude * p) *
          c(pos2.latitude * p) *
          (1 - c((pos2.longitude - pos1.longitude) * p)) /
          2;
  return 12742 * asin(sqrt(a));
}
