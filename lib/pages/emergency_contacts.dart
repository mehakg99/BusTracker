import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bus_tracker/components/bottom_navbar.dart';

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

  List<Widget> displayContacts() {
    List<Widget> list = userDets
        .map((item) => Padding(
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
                        setState(() {
                          userDets.removeWhere((element) =>
                              element["name"] == item["name"] &&
                              element["contact"] == item["contact"]);
                        });
                        _removeContact(item["name"]);
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                ),
              ),
            ))
        .toList();
    return list;
  }

  _removeContact(name) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(name);
  }

  _saveContact(userName, userContact) async {
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
      _saveContact(name, contact);
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

  void clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: const BottomNavbar(selectedIndex: 1),
        appBar: AppBar(
          title: const Text('Emergency Contacts'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: userDets.isEmpty
              ? GestureDetector(
                  onTap: () {
                    clearPrefs();
                  },
                  child: const Center(
                    child: Text(
                      'No contacts added',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: displayContacts(),
                  ),
                ),
        ),
        floatingActionButton: userDets.length == 5
            ? null
            : FloatingActionButton(
                onPressed: () => addNewContact(),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }
}
