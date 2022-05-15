import 'package:bus_tracker/components/permission_denied.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100,
);

class SosButton extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final bool locationPermissionProvided;
  const SosButton(
      {Key? key,
      required this.snapshot,
      required this.locationPermissionProvided})
      : super(key: key);

  @override
  _SosButtonState createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  final Telephony telephony = Telephony.instance;
  List<String> contacts = [];
  int counter = 0;
  bool activeButton = false;
  bool locationShared = false;
  bool toUpdate = false;
  String documentId = "";
  bool dataRecieved = false;

  @override
  void initState() {
    super.initState();
    _getContacts();
    _addLocation(widget.snapshot.data);
    setState(() {
      dataRecieved = true;
    });
  }

  final SmsSendStatusListener listener = (SendStatus status) {
    print("Message status: $status");
  };

  void _sendSMS(String message) async {
    if (documentId != "") {
      telephony.sendSms(
          to: contacts.join(";"),
          message:
              "https://bus-tracker-proxy-server.herokuapp.com/sos/$documentId",
          statusListener: listener);
    }
  }

  _getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    List<String> savedUserDets = [];
    for (String key in keys) {
      savedUserDets.add(prefs.getInt(key).toString());
    }
    setState(() {
      contacts = savedUserDets;
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Live Location'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Your live location has been successfully shared'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addLocation(Position? position) {
    CollectionReference sosCollection =
        FirebaseFirestore.instance.collection("sosLocations");
    if (documentId == "") {
      sosCollection.add({
        "lat": position?.latitude,
        "lng": position?.longitude,
        "isActive": true
      }).then((DocumentReference value) => {
            setState(() {
              documentId = value.id;
            })
          });
    }
  }

  void _updateLocation(Position? position) {
    if (documentId != "") {
      CollectionReference sosCollection =
          FirebaseFirestore.instance.collection("sosLocations");
      sosCollection.doc(documentId).set({
        "lat": position?.latitude,
        "lng": position?.longitude,
        "isActive": true,
      });
    }
  }

  void _stopLocationSharing() {
    if (documentId != "") {
      CollectionReference sosCollection =
          FirebaseFirestore.instance.collection("sosLocations");
      sosCollection.doc(documentId).update({
        "isActive": false,
      });
      setState(() {
        locationShared = false;
        toUpdate = false;
        documentId = "";
        dataRecieved = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Position? currentPosition = widget.snapshot.data;
    if (toUpdate) {
      if (!dataRecieved) {
        _addLocation(currentPosition);
        setState(() {
          dataRecieved = true;
        });
      } else {
        _updateLocation(currentPosition);
      }
    }
    return widget.locationPermissionProvided
        ? locationShared
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _stopLocationSharing();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                    ),
                    child: const Text(
                      "Stop sharing",
                      style: TextStyle(fontSize: 16, letterSpacing: 2),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Tap 3 times to send live location!",
                    style: TextStyle(fontSize: 20),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        counter++;
                        activeButton = true;
                        Future.delayed(Duration(milliseconds: 250), () {
                          setState(() {
                            activeButton = false;
                          });
                        });
                      });
                      if (counter == 3) {
                        setState(() {
                          toUpdate = true;
                        });
                        _sendSMS("Test message");
                        _showMyDialog();
                        setState(() {
                          counter = 0;
                          locationShared = true;
                        });
                      }
                    },
                    child: Container(
                      width: 360,
                      height: 460,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 330,
                          height: 430,
                          decoration: BoxDecoration(
                            color: Colors.grey[350],
                            shape: BoxShape.circle,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: const Center(
                                  child: Text(
                                'SOS',
                                style: TextStyle(
                                  fontSize: 80,
                                  letterSpacing: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )),
                              width: 300,
                              height: 400,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    activeButton ? Colors.red[400] : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
        : const PermissionDenied();
  }
}
