import 'package:flutter/material.dart';
import 'package:pitches/app/loading.dart';
import 'package:pitches/app/menu.dart';
import '../app/filelist.dart';
import '../app/home.dart';
import '../app/now_record.dart';
import '../app/setting.dart';
import '../app/markdown.dart';

final Widget homeRoute = HomeScreen();

final Map<String, WidgetBuilder> routes = {
  '/home': (context) => HomeScreen(),
  '/menu': (context) => MenuScreen(),
  '/files': (context) => FileScreen(),
  '/record': (context) => NowRecordScreen(),
  '/setting': (context) => SettingsScreen(),
  '/loading': (context) => LoadingScreen(),
  '/markdown': (context) => MarkdownExample(),
};