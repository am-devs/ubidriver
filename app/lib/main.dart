import 'package:driver_return/pages/approval.dart';
import 'package:driver_return/pages/ending.dart';
import 'package:driver_return/pages/invoice.dart';
import 'package:driver_return/pages/resume.dart';
import 'package:driver_return/pages/return.dart';
import 'package:driver_return/pages/search.dart';
import 'package:driver_return/services.dart';
import 'package:driver_return/state.dart';
import 'package:flutter/material.dart';
import 'package:driver_return/pages/login.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider(create: (context) => ApiService()),
      ChangeNotifierProvider(create: (context) => AppState()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppSnapshot.tryToLoad().then(<Snapshot>(snap) async {
        if (context.mounted && snap != null) {
          final api = Provider.of<ApiService>(context);
          
          api.loadFromSnapshot(snap);

          await api.validateToken();

          return snap;
        }

        return false;
      }),
      builder: (context, snapshot) {
        DeliveryState? status;

        if (snapshot.hasData && snapshot.data) {
          final state = Provider.of<AppState>(context, listen: false);

          state.loadFromSnapshot(snapshot.data!);

          if (Provider.of<ApiService>(context).isLoggedIn) {
            if (state.currentState == DeliveryState.confirmed) {
              state.advanceState();
            }

            status = state.currentState;
          }
        }

        print("Se cargó todo?: ${snapshot.data}");

        return MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          title: 'GTT Despacho',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent.shade400)
          ),
          home: switch (status) {
            DeliveryState.approved => ResumePage(),
            DeliveryState.editingInvoice => InvoicePage(),
            DeliveryState.waitingForApproval => ApprovalPage(),
            DeliveryState.searchingInvoice => SearchPage(),
            _ => LoginPage()
          },
          onGenerateRoute: (settings) {
            var routes = <String, WidgetBuilder> {
              '/login': (context) => LoginPage(),
              '/search': (context) => SearchPage(),
              '/invoice': (context) => InvoicePage(),
              '/resume': (context) => ResumePage(),
              '/return': (context) => ReturnPage(),
              '/ending': (context) => EndingPage(),
              '/approval': (context) => ApprovalPage()
            };

            WidgetBuilder builder = routes[settings.name]!;
            return MaterialPageRoute(builder: (ctx) => builder(ctx));
          }
        );
      }
    );
  }
}