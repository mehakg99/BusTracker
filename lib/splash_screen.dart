import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  late final bool _loaded;
  SplashScreen(isLoaded, {Key? key}) : super(key: key) {
    _loaded = isLoaded;
  }

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.blue,
        child: Center(
          child: AnimatedOpacity(
              // If the widget is visible, animate to 0.0 (invisible).
              // If the widget is hidden, animate to 1.0 (fully visible).
              opacity: widget._loaded ? 0 : 1.0,
              duration: const Duration(milliseconds: 200),
              // The green box must be a child of the AnimatedOpacity widget.
              child: const Image(
                image: AssetImage('assets/logo.png'),
              )),
        ),
      ),
    );
  }
}
