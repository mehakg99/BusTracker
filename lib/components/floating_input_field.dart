import 'package:bus_tracker/components/single_child_scroll_view.dart';
import 'package:bus_tracker/models/Location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FloatingInputField extends StatefulWidget {
  final String title;
  final Function setDestination;
  final Location? destination;
  final Location? source;
  final List<Location> listData;
  const FloatingInputField({
    Key? key,
    this.title = "",
    required this.setDestination,
    required this.destination,
    required this.source,
    required this.listData,
  }) : super(key: key);

  @override
  State<FloatingInputField> createState() => _FloatingInputFieldState();
}

class _FloatingInputFieldState extends State<FloatingInputField> {
  getStops() {
    return widget.listData.map((busStop) {
      return DropdownMenuItem(
          child: Text(
            busStop.name,
          ),
          value: busStop.name);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SearchChoices.single(
        items: getStops(),
        value: widget.destination?.name,
        hint: const SizedBox(
          height: 48,
          child: Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text("Select a destination"),
          ),
        ),
        searchHint: "select",
        onClear: () {
          widget.setDestination(null);
        },
        onChanged: (value) {
          print(value);
          Location locationObject =
              widget.listData.firstWhere((element) => element.name == value);
          widget.setDestination(locationObject);
        },
        isExpanded: true,
      ),
    );
  }
}
