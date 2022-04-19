import 'dart:convert';
import 'dart:io';

import 'package:bus_tracker/bus_tracker_buses.dart';
import 'package:bus_tracker/components/floating_input_field.dart';
import 'package:bus_tracker/components/map_v2.dart';
import 'package:flutter/material.dart';
import 'package:bus_tracker/components/map_component.dart';
import 'dart:async';
import '../custom_scaffold.dart';
import 'package:firebase_database/firebase_database.dart';

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

  //
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(alignment: Alignment.bottomCenter, children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Stack(
                    children: const [
                      MapComponentV2(),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: FloatingInputField()),
                    ],
                  ),
                ),
              ]),
          FractionallySizedBox(
            heightFactor: 0.3,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: const Text('hi2'),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
