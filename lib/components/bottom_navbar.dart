import 'package:bus_tracker/pages/emergency_contacts.dart';
import 'package:bus_tracker/pages/select_destination.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';

class BottomNavbar extends StatefulWidget {
  final selectedIndex;
  const BottomNavbar({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  List pages = [SelectDestination(), EmergencyContacts()];

  @override
  Widget build(BuildContext context) {
    int index = widget.selectedIndex;

    return BottomNavigationBar(
      selectedLabelStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
          ),
          label: 'Emergency',
        ),
      ],
      currentIndex: index,
      onTap: (newIndex) {
        setState(() {
          index = newIndex;
        });
        if (newIndex == 1) {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const EmergencyContacts()));
        } else {
          // Navigator.pop(context);
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
    );
  }
}
