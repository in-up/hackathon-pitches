import 'package:flutter/material.dart';
import 'package:pitches/app/menu.dart';
import '../app/filelist.dart';
import '../app/home.dart';
import '../app/setting.dart';

final Widget homeRoute = HomeScreen();

final Map<String, WidgetBuilder> routes = {
  '/home': (context) => HomeScreen(),
  '/menu': (context) => MenuScreen(),
  '/files': (context) => FileScreen(),
  '/setting': (context) => SettingsScreen(),
};