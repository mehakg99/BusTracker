import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectedSource extends StatelessWidget {
  final String source;
  final Function setSource;

  const SelectedSource(
      {Key? key, required this.source, required this.setSource})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 200,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Colors.white,
                border: Border.all(color: Colors.blue),
              ),
              margin: EdgeInsets.all(20),
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 22, horizontal: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(source,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400)),
                      GestureDetector(
                          onTap: () {
                            setSource(null);
                          },
                          child: Icon(Icons.close, color: Colors.grey[700])),
                    ]),
              ),
            )
          ],
        ));
  }
}
