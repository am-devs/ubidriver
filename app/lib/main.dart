import 'package:driver_return/pages/return.dart';
import 'package:driver_return/services.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:driver_return/pages/home.dart';
import 'package:driver_return/pages/login.dart';
import 'package:driver_return/pages/deliver.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider(create: (context) => ApiService()),
      ChangeNotifierProvider(create:(context) => InvoiceMap()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        ),
        home: LoginPage(),
        onGenerateRoute: (settings) {
          if(settings.name == "/return") {
            final args = settings.arguments as ReturnArguments;

            return MaterialPageRoute(
              builder: (context) => ReturnPage(args)
            );
          }

          var routes = <String, WidgetBuilder> {
            '/login': (context) => LoginPage(),
            '/home': (context) => HomePage(),
            '/deliver': (context) => DeliverPage(),
          };

          WidgetBuilder builder = routes[settings.name]!;

          return MaterialPageRoute(builder: (ctx) => builder(ctx));
        }
      );
  }
}