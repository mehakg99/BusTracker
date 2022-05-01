import 'package:flutter/material.dart';
import 'package:bus_tracker/components/bottom_navbar.dart';

class SosButton extends StatefulWidget {
  const SosButton({Key? key}) : super(key: key);

  @override
  _SosButtonState createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Emergency'),
        ),
        bottomNavigationBar: const BottomNavbar(selectedIndex: 2),
        body: GestureDetector(
          onTap: () {},
          child: Center(
            child: Container(
              width: 360,
              height: 460,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 330,
                  height: 430,
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: const Center(
                          child: Text(
                        'SOS',
                        style: TextStyle(
                          fontSize: 80,
                          letterSpacing: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                      width: 300,
                      height: 400,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
