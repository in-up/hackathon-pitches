import 'package:flutter/material.dart';
import '../app/home.dart';

final Widget homeRoute = HomeScreen();

final Map<String, WidgetBuilder> routes = {
  '/home': (context) => HomeScreen(),
};