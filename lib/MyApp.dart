// A function that calls the Wake Lock API
// Future<html.WakeLockSentinel> preventDisplaySleep() async {
//   // Request a screen wake lock
//   return await html.window.navigator.wakeLock.request('screen');
// }

import 'package:flutter/material.dart';

import 'Login.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      home: LogIn(),
    );
  }
}