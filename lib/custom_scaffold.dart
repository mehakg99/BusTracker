import 'package:bus_tracker/bus_tracker_routes.dart';
import 'package:bus_tracker/favourite_routes.dart';
import 'package:flutter/material.dart';

class MyScaffold extends StatefulWidget {
  final Widget body;
  String title = 'hi';

  // ignore: use_key_in_widget_constructors
  MyScaffold({required this.body, required this.title});

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  setPage(Widget widget) {
    Navigator.pushAndRemoveUntil(
      context,
      // MaterialPageRoute(builder: (context) => BusTrackerBuses()),
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => widget,
        transitionsBuilder: (c, anim, a2, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 300),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.black54,
            unselectedItemColor: Colors.black54,
            onTap: (newIndex) {
              if (newIndex == 1) {
                setPage(BusTrackerFavouriteRoutes());
              } else {
                setPage(BusTrackerRoutes());
              }
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.bus_alert),
                label: 'All Routes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: 'Favourites',
              ),
            ],
          ),
          body: this.widget.body),
    );
  }
}
