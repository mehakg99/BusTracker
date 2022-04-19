import 'dart:convert';
import 'dart:io';

import 'package:bus_tracker/bus_tracker_buses.dart';
import 'package:flutter/material.dart';
import 'package:bus_tracker/components/map_component.dart';
import 'dart:async';
import 'custom_scaffold.dart';
import 'saved_states.dart' as savedStates;
import 'package:firebase_database/firebase_database.dart';

class BusTrackerRoutes extends StatefulWidget {
  @override
  State<BusTrackerRoutes> createState() => _BusTrackerRoutesState();
}

class RouteWidget {
  final String routeId;
  final String desc;
  final String title;

  RouteWidget(this.routeId, this.desc, this.title);

  RouteWidget.fromJson(Map<dynamic, dynamic> json)
      : routeId = json['routeId'] as String,
        desc = json['desc'] as String,
        title = json['title'] as String;
}

class _BusTrackerRoutesState extends State<BusTrackerRoutes> {
  Widget singleCard(MapEntry entry) {
    RouteWidget rw = RouteWidget.fromJson((entry.value));
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5),
      child: Card(
        child: ListTile(
          onTap: () => Navigator.push(
            context,
            // MaterialPageRoute(builder: (context) => BusTrackerBuses()),
            PageRouteBuilder(
              pageBuilder: (c, a1, a2) => BusTrackerBuses(
                routeNumber: rw.routeId,
              ),
              transitionsBuilder: (c, anim, a2, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: Duration(milliseconds: 300),
            ),
          ),
          title: Text(rw.title),
          subtitle: Text(rw.desc),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    if (!savedStates.favouriteRoutes.contains(rw.routeId)) {
                      savedStates.favouriteRoutes.add(rw.routeId);
                    } else {
                      savedStates.favouriteRoutes.remove(rw.routeId);
                    }
                  },
                  icon: Icon(
                    Icons.star,
                    color: savedStates.favouriteRoutes.contains(rw.routeId)
                        ? Colors.amber
                        : Colors.grey,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  bool isLoaded = false;
  Map routes = {};

  getRoutes() async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = FirebaseDatabase.instance.ref("routes/");
    print('reached here');
    DatabaseEvent event = await ref.once();
    print('data ${event.snapshot.value}');
    Stream<DatabaseEvent> stream = ref.onValue;
    stream.listen((DatabaseEvent event) {
      // print(event.snapshot.value); // DatabaseEventType.value;\
      if (!mounted) return;
      setState(() {
        routes = {};
        try {
          routes = (json.decode(json.encode(event.snapshot.value)));
        } catch (e) {
          print('error getting routes ${e}');
        }
      });
    });
  }

  @override
  initState() {
    super.initState();
    getRoutes();
  }

  //
  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        isLoaded = true;
      });
    });
    return MyScaffold(
      title: 'Routes',
      body: AnimatedOpacity(
        opacity: isLoaded ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: Column(
          children: (routes.entries.map((entry) => singleCard(entry)).toList()),
        ),
      ),
    );
  }
}
