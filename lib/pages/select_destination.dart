import 'dart:convert';
import 'dart:ffi';
import 'package:bus_tracker/components/floating_input_field.dart';
import 'package:bus_tracker/components/map_v2.dart';
import 'package:bus_tracker/components/pickup_component.dart';
import 'package:bus_tracker/models/Location.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectDestination extends StatefulWidget {
  const SelectDestination({Key? key}) : super(key: key);

  @override
  State<SelectDestination> createState() => _SelectDestinationState();
}

class _SelectDestinationState extends State<SelectDestination> {
  List<Location> destinationsData = [];
  getDestinations() async {
    CollectionReference busStops =
        FirebaseFirestore.instance.collection("/busStops");

    QuerySnapshot querySnapshot = await busStops.get();

    destinationsData =
        querySnapshot.docs.map((doc) => Location.fromDoc(doc)).toList();
  }

  @override
  initState() {
    super.initState();
    getDestinations();
  }

  Location? destination, source;

  void setDestination(Location? location) {
    setState(() {
      if (location != null) {
        destination = location;
      } else {
        destination = null;
      }
    });
  }

  void setSource(Location? sourceParam) {
    setState(() {
      if (source != null) {
        source = sourceParam;
      } else {
        source = null;
      }
    });
  }

  //
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      MapComponentV2(
                        destination: destination,
                        source: source,
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          child: FloatingInputField(
                            destination: destination,
                            source: source,
                            title: "Destination",
                            listData: destinationsData,
                            setDestination: setDestination,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            FractionallySizedBox(
              heightFactor: 0.4,
              child: PickUpComponent(
                setSource: setSource,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
