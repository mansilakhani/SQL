import 'package:flutter/material.dart';

import 'homepage.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context) => const HomePage(),
    },
  ));
}
