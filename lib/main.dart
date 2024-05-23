import 'package:flutter/material.dart';

import 'screens/detail.dart';
import 'screens/home.dart';
import 'screens/splashscreen.dart';

void main() async {
  runApp(const AnimeApp());
}

class AnimeApp extends StatelessWidget {
  const AnimeApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime app',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Set splash screen sebagai halaman pertama
      routes: {
        '/home': (context) => const HomePage(),
        '/detail': (context) => const DetailPage(item: 0, title: ''),
      },
    );
  }
}
