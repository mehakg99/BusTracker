import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';

class FloatingInputField extends StatefulWidget {
  final String title;
  const FloatingInputField({Key? key, this.title = ""}) : super(key: key);

  @override
  State<FloatingInputField> createState() => _FloatingInputFieldState();
}

class _FloatingInputFieldState extends State<FloatingInputField> {
  String destination = "";
  List<DropdownMenuItem> cities = const [
    DropdownMenuItem(
      child: Text(
        'Bangalore',
      ),
      value: 1,
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
    // return TextFormField(
    //   decoration: InputDecoration(
    //     filled: true,
    //     border: OutlineInputBorder(),
    //     fillColor: Colors.white,
    //     labelText: title,
    //   ),
    // );
    return Padding(
      padding: EdgeInsets.all(10),
      child: SearchChoices.single(
        items: cities,
        value: destination,
        hint: SizedBox(
          height: 48,
          child: Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text("Select a destination"),
          ),
        ),
        searchHint: "select",
        onChanged: (value) {
          setState(() {
            destination = value;
          });
        },
        isExpanded: true,
      ),
    );
  }
}
