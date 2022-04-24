import 'package:bus_tracker/components/list_tile.dart';
import 'package:flutter/material.dart';

import 'package:bus_tracker/models/Location.dart';
import 'package:geolocator/geolocator.dart';

const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100,
);

class PickUpComponent extends StatefulWidget {
  final void Function(Location?) setSource;
  final Location? source;
  final List<Location> listData;
  final Position? currentPosition;
  final bool isLoading;
  const PickUpComponent({
    Key? key,
    required this.setSource,
    required this.source,
    required this.listData,
    required this.currentPosition,
    required this.isLoading,
  }) : super(key: key);

  @override
  _PickUpComponentState createState() => _PickUpComponentState();
}

class _PickUpComponentState extends State<PickUpComponent> {
  @override
  void initState() {
    super.initState();
  }

  List getPickupLocations() {
    List distanceList = widget.listData
        .map((Location busStop) => {
              "busStop": busStop,
              "distance": busStop.distanceFromPosition(widget.currentPosition!)
            })
        .toList();
    distanceList.sort((a, b) => a["distance"].compareTo(b["distance"]));
    return (distanceList.length > 3)
        ? distanceList.sublist(0, 2)
        : distanceList;
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
          widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: getPickupLocations().map((busStop) {
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
                      }).toList(),
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
