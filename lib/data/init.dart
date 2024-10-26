import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> init() async {
  await initializeDateFormatting('ko_KR', null);
  await Hive.initFlutter();
  var box = await Hive.openBox('localdata');
  var box2 = await Hive.openBox('prompt');
}