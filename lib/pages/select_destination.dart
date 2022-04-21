import 'package:bus_tracker/components/floating_input_field.dart';
import 'package:bus_tracker/components/map_v2.dart';
import 'package:bus_tracker/components/pickup_component.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectDestination extends StatefulWidget {
  const SelectDestination({Key? key}) : super(key: key);

  @override
  State<SelectDestination> createState() => _SelectDestinationState();
}

class _SelectDestinationState extends State<SelectDestination> {
  @override
  initState() {
    super.initState();
  }

  LatLng? destination, source;

  void setDestination({required double? lat, required double? lng}) {
    setState(() {
      if (lat != null && lng != null) {
        destination = LatLng(lat, lng);
      } else {
        destination = null;
      }
    });
  }

  void setSource({required double lat, required double lng}) {
    setState(() {
      source = LatLng(lat, lng);
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
