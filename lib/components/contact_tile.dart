import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final userDets;
  final Function deleteContactHandler;
  const ContactTile(
      {Key? key, required this.userDets, required this.deleteContactHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> list = userDets
        .map<Widget>((item) => Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.person,
                    size: 35,
                  ),
                  title: Text(
                    item["name"],
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(
                    item["contact"],
                    style: TextStyle(fontSize: 15),
                  ),
                  trailing: GestureDetector(
                      onTap: () {
                        deleteContactHandler(item);
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                ),
              ),
            ))
        .toList();
    return Column(children: list);
  }
}
