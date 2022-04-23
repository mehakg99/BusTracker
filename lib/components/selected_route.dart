import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectedRoute extends StatelessWidget {
  final String route;
  final Function setRoute;

  const SelectedRoute({Key? key, required this.route, required this.setRoute})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                border: Border.all(color: Colors.blue),
              ),
              margin: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(route,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400)),
                      GestureDetector(
                          onTap: () {
                            setRoute(null);
                          },
                          child: Icon(Icons.close, color: Colors.grey[700])),
                    ]),
              ),
            )
          ],
        ));
  }
}
