import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FloatingInputField extends StatelessWidget {
  const FloatingInputField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        filled: true,
        border: OutlineInputBorder(),
        fillColor: Colors.white,
        labelText: 'Name',
      ),
    );
  }
}
