import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final contactDets;
  final Function deleteContactHandler;
  const ContactTile(
      {Key? key, required this.contactDets, required this.deleteContactHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Card(
        child: ListTile(
          leading: const Icon(
            Icons.person,
            size: 35,
          ),
          title: Text(
            contactDets["name"],
            style: TextStyle(fontSize: 20),
          ),
          subtitle: Text(
            contactDets["contact"],
            style: TextStyle(fontSize: 15),
          ),
          trailing: GestureDetector(
              onTap: () {
                deleteContactHandler(contactDets);
              },
              child: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        ),
      ),
    );
  }
}
