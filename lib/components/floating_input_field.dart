import 'package:bus_tracker/components/single_child_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FloatingInputField extends StatefulWidget {
  final String title;
  final Function setDestination;
  final LatLng? destination;
  final LatLng? source;
  const FloatingInputField({
    Key? key,
    this.title = "",
    required this.setDestination,
    required this.destination,
    required this.source,
  }) : super(key: key);

  @override
  State<FloatingInputField> createState() => _FloatingInputFieldState();
}

class _FloatingInputFieldState extends State<FloatingInputField> {
  List<DropdownMenuItem> cities = const [
    DropdownMenuItem(
      child: Text(
        'Bangalore',
      ),
      value: LatLng(30.74, 76.77),
    ),
    DropdownMenuItem(
      child: Text('Bangalore 2'),
      value: 2,
    ),
    DropdownMenuItem(
      child: Text('Bangalore 3'),
      value: 3,
    ),
    DropdownMenuItem(
      child: Text('Bangalore 4'),
      value: 4,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SearchChoices.single(
        items: cities,
        value: widget.destination,
        hint: const SizedBox(
          height: 48,
          child: Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text("Select a destination"),
          ),
        ),
        searchHint: "select",
        onClear: () {
          widget.setDestination(lat: null, lng: null);
        },
        onChanged: (value) {
          widget.setDestination(
            lat: 30.74,
            lng: 76.77,
          );
        },
        isExpanded: true,
      ),
    );
  }
}
