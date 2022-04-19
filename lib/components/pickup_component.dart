import 'package:bus_tracker/components/list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PickUpComponent extends StatefulWidget {
  const PickUpComponent({Key? key}) : super(key: key);

  @override
  _PickUpComponentState createState() => _PickUpComponentState();
}

class _PickUpComponentState extends State<PickUpComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, top: 15),
            child: Row(
              children: [
                const Text(
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  ListTileCustom(
                    title: 'hi',
                    subtitle: 'distance: 1km',
                    icon: Icon(
                      Icons.home,
                      color: Colors.blue,
                    ),
                  ),
                  ListTileCustom(
                    title: 'hi',
                    subtitle: 'distance: 2km',
                    icon: Icon(
                      Icons.home,
                      color: Colors.blue,
                    ),
                  ),
                ],
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
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
    );
  }
}
