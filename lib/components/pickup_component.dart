import 'package:bus_tracker/components/list_tile.dart';
import 'package:flutter/material.dart';

import 'package:bus_tracker/models/Location.dart';
import 'package:geolocator/geolocator.dart';

class PickUpComponent extends StatefulWidget {
  final void Function(Location?) setSource;
  final Location? source;
  final List<Location> listData;
  final Stream<Position>? positionStream;
  const PickUpComponent(
      {Key? key,
      required this.setSource,
      required this.source,
      required this.listData,
      required this.positionStream})
      : super(key: key);

  @override
  _PickUpComponentState createState() => _PickUpComponentState();
}

class _PickUpComponentState extends State<PickUpComponent> {
  @override
  void initState() {
    super.initState();
  }

  void handleTileTap(String title, String subtitle) {}

  List<ListTileCustom> getPickupLocations(Position? position) {
    List distanceList = widget.listData
        .map((Location busStop) => {
              "busStop": busStop,
              "distance": busStop.distanceFromPosition(position!)
            })
        .toList();
    distanceList.sort((a, b) => a["distance"].compareTo(b["distance"]));
    return distanceList.sublist(0, 2).map((busStop) {
      return ListTileCustom(
        title: busStop["busStop"].name,
        subtitle: busStop["distance"].toString(),
        icon: const Icon(
          Icons.home,
          color: Colors.blue,
        ),
        onTap: () {
          widget.setSource(busStop["busStop"]);
        },
      );
    }).toList();
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
                  'Pickup Location',
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
              child: StreamBuilder<Position>(
                stream: widget.positionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: getPickupLocations(snapshot.data),
                    );
                  } else {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: CircularProgressIndicator(),
                    ),
                  );
                  }
                },
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
