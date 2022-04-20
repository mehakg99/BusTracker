import 'package:flutter/material.dart';

class ListTileCustom extends StatefulWidget {
  final String title;
  final String subtitle;
  final Icon icon;
  final Function? onTap;
  const ListTileCustom(
      {Key? key,
      this.title = "",
      this.subtitle = "",
      required this.icon,
      this.onTap})
      : super(key: key);

  @override
  State<ListTileCustom> createState() => _ListTileCustomState();
}

class _ListTileCustomState extends State<ListTileCustom> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Card(
        child: ListTile(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            }
          },
          title: Text(widget.title),
          subtitle: Text(widget.subtitle),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
            ],
          ),
          minLeadingWidth: 5,
        ),
      ),
    );
  }
}
