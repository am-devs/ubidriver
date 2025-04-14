import 'package:driver_return/services.dart';
import 'package:flutter/material.dart';
import 'package:driver_return/pages/home.dart';
import 'package:driver_return/pages/login.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider(create: (context) => ApiService())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: LoginPage(),
        routes: {
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage()
        },
      );
  }
}