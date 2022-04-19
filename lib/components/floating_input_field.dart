import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingInputField extends StatelessWidget {
  final String title;
  const FloatingInputField({Key? key, this.title = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(),
        fillColor: Colors.white,
        labelText: title,
      ),
    );
  }
}
