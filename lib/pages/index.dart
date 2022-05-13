import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:bus_tracker/pages/emergency_contacts.dart';
import 'package:bus_tracker/pages/select_destination.dart';
import 'package:bus_tracker/pages/sos_button.dart';

class Index extends StatefulWidget {
  Index({Key? key}) : super(key: key);

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    SelectDestination(),
    EmergencyContacts(),
    SosButton(),
  ];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  List<Widget> pages = [
    const SelectDestination(),
    const EmergencyContacts(),
    const SosButton()
  ];

  List appbar = [
    null,
    AppBar(
      title: const Text('Contact Details'),
    ),
    AppBar(
      title: const Text('Emergency'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appbar[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
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
              label: 'Contacts',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.emergency,
              ),
              label: 'Emergency',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (newIndex) {
            setState(() {
              _selectedIndex = newIndex;
              _pageController.jumpToPage(newIndex);
            });
          },
        ),
        body: PageView(
          controller: _pageController,
          children: _pages,
        ),
      ),
    );
  }
}

// _pageController.animateToPage(
//   newIndex,
//   duration: const Duration(milliseconds: 600),
//   curve: Curves.easeIn,
// );
