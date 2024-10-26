import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/init.dart';
import 'data/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homeRoute,
      routes: routes,
      theme: ThemeData(
        useMaterial3: false,
        canvasColor: Color(0xFFfcfcfc),
        primaryColor: Color(0xFF1E0E62),
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF60646C)),
          headlineMedium: TextStyle(color: Color(0xFF60646C)),
          headlineSmall: TextStyle(color: Color(0xFF60646C)),
          bodyMedium: TextStyle(color: Color(0xFF1E0E62)),
        ),
        fontFamily: 'Pretendard',
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder()
        }),
        appBarTheme: AppBarTheme(
          color: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF1E0E62),
          actionsIconTheme: IconThemeData(color: Color(0xFF1E0E62)),
          iconTheme: IconThemeData(color: Color(0xFF1E0E62)),
          titleTextStyle: TextStyle(color: Color(0xFF1E0E62), fontSize: 16, fontWeight: FontWeight.w700)
        ),
        listTileTheme: ListTileThemeData(iconColor: Color(0xFF1E0E62), textColor: Color(0xFF1E0E62))
      ),
    );
  }
}