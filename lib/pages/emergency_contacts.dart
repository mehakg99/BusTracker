import 'package:bus_tracker/components/contact_tile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContacts extends StatefulWidget {
  const EmergencyContacts({Key? key}) : super(key: key);

  @override
  _EmergencyContactsState createState() => _EmergencyContactsState();
}

class _EmergencyContactsState extends State<EmergencyContacts> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String contact = "";
  List userDets = [];

  @override
  initState() {
    super.initState();
    _getContacts();
  }

  void deleteContactHandler(item) {
    setState(() {
      userDets.removeWhere((element) =>
          element["name"] == item["name"] &&
          element["contact"] == item["contact"]);
    });
    _deleteUser(item["name"]);
  }

  _deleteUser(name) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(name);
  }

  _saveUser(userName, userContact) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(userName, int.parse(userContact));
  }

  _getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    List savedUserDets = [];
    for (String key in keys) {
      savedUserDets.add({'name': key, 'contact': prefs.getInt(key).toString()});
    }
    setState(() {
      userDets = savedUserDets;
    });
  }

  void submitHandler() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        userDets.add({'name': name, 'contact': contact});
      });
      _saveUser(name, contact);
      Navigator.pop(context, 'Save');
    }
  }

  void addNewContact() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add new contact'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
                onChanged: (value) {
                  name = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Name',
                  icon: Icon(Icons.account_box),
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  } else if (double.tryParse(value) == null) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
                onChanged: (value) {
                  contact = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  icon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text(
              'Cancel',
            ),
          ),
          TextButton(
            onPressed: () => {submitHandler()},
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          userDets.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Text(
                      'No contacts added',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                        children: userDets
                            .map<Widget>(
                              (contactDets) => ContactTile(
                                  contactDets: contactDets,
                                  deleteContactHandler: deleteContactHandler),
                            )
                            .toList()),
                  ),
                ),
          FloatingActionButton(
            onPressed: () => addNewContact(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
