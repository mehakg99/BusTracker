import 'package:flutter/material.dart';

class PermissionDenied extends StatelessWidget {
  const PermissionDenied({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Image(image: AssetImage('assets/logo.png')),
              SizedBox(
                height: 10,
              ),
              Text(
                'The location service on the device is disabled.',
                style: TextStyle(color: Colors.white),
              ),
            ]),
      ),
    );
  }
}
