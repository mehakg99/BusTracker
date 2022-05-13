import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';

class SosButton extends StatefulWidget {
  const SosButton({Key? key}) : super(key: key);

  @override
  _SosButtonState createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  final Telephony telephony = Telephony.instance;
  List<String> contacts = [];
  int counter = 0;
  bool activeButton = false;
  bool locationShared = false;

  @override
  void initState() {
    super.initState();
    _getContacts();
  }

  final SmsSendStatusListener listener = (SendStatus status) {
    print("Message status: $status");
  };

  void _sendSMS(String message, List<String> recipents) async {
    telephony.sendSms(
        to: contacts.join(";"),
        message: "Current location of user",
        statusListener: listener);
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

  @override
  Widget build(BuildContext context) {
    return locationShared
        ? Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    locationShared = false;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                ),
                child: const Text(
                  "Stop sharing",
                  style: TextStyle(fontSize: 20, letterSpacing: 2),
                ),
              ),
            ],
          )
        : GestureDetector(
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
                _sendSMS("Test message", contacts);
                _showMyDialog();
                setState(() {
                  counter = 0;
                  locationShared = true;
                });
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Tap 3 times to send live location!",
                  style: TextStyle(fontSize: 20),
                ),
                Container(
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
                            color: activeButton ? Colors.red[400] : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
