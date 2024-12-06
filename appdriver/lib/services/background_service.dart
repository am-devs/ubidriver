import 'dart:async';
import 'dart:ui';
import 'package:appdriver/models/FunctionsBackground.dart';
import 'package:appdriver/models/databasehelper.dart';
import 'package:http/http.dart' as http;
import 'package:appdriver/screens/globalVars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';

late BuildContext appContext;

Future<void> initializeService(BuildContext context) async{
  appContext = context;
  final service = FlutterBackgroundService();
  await service.configure(iosConfiguration: IosConfiguration(
    autoStart: true,
    onForeground: onStart,
    onBackground: onIosBackground,
    
  ),
  androidConfiguration: AndroidConfiguration(onStart: onStart, isForegroundMode: false, autoStart: true));
}

@pragma('vm:entry-point')
Future <bool> onIosBackground (ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  if(service is AndroidServiceInstance){
    service.on('setAsForeground').listen((event) { 
      service.setAsForegroundService();
    });
  }

  if(service is AndroidServiceInstance){
    service.on('setAsBackground').listen((event) { 
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 30), (timer) async{
     if(service is AndroidServiceInstance){
      if(await service.isForegroundService()){
        service.setForegroundNotificationInfo(title:"SCRIPT FOREGROUND MODE", content: "Testtttt");
      }
     }
     updateData();
     //getLocation();
     print("backgroundddd service running");
     service.invoke('update');
  });
            
}

// Codigo para obtener coordenadas con el gps activo.
// Es necesario activar la ubicacion del telefono y darle permisos de ubicacion a la aplicacion
// Future<void> getLocation() async{
//   String _locationMessage = "";
//   DatabaseHelper dbHelper = DatabaseHelper();
//   GlobalVars globalVars = GlobalVars();
//   List<Map<String, dynamic>> users = await dbHelper.queryAll('driver');
//   for(var user in users){
//   print('USUARIO: '+user.toString());
//   globalVars.username = user['username'];
//   globalVars.code = user['code'];
//   globalVars.id = user['driver_id'].toString();
//   globalVars.company = user['company'];
//   }

  
//   // final position = await Geolocator.getCurrentPosition(
//   //     desiredAccuracy: LocationAccuracy.high,
//   //   );
//   // var latitud = position.latitude;
//   // var longitud = position.longitude;

//   //dbHelper.insert(row, table) quedaste en guardar la latitud y la longitud en la base de datos local.
//   // _locationMessage = "${position.latitude}, ${position.longitude}";
//   // print('POSICION: '+_locationMessage);
// }

Future<void> updateData() async{
    try{
      FunctionsBackground globalFunctions =FunctionsBackground();
      DatabaseHelper dbHelper = DatabaseHelper();
      GlobalVars globalVars = GlobalVars();
      List<Map<String, dynamic>> users = await dbHelper.queryAll('driver');
      for(var user in users){
      print('USUARIO: '+user.toString());
      globalVars.username = user['username'];
      globalVars.code = user['code'];
      globalVars.id = user['driver_id'].toString();
      globalVars.company = user['company'];
      }
      print(globalVars.username);
      print(globalVars.id);
      final response = await http.get(Uri.parse('https://apiubitransport.iancarina.com.ve'));
      if(response.statusCode == 200){
      //Sincroniza la Data con Adempiere
      bool checkUpdates = await globalFunctions.updateAdempiere(globalVars.id, globalVars);
      if(checkUpdates){
      print('se sincronizaron los datos correctamente');
      getInvoices(globalVars);
      }
      else{
      print('no existen Facturas por actualizar.');
      getInvoices(globalVars);
      }
    }
    }catch(e){
     print('ERROR: $e');DatabaseHelper dbHelper=DatabaseHelper();
     print('SIN CONEXION');
    }
  }

Future<void> getInvoices(GlobalVars globalVars) async {
    DatabaseHelper dbHelper=DatabaseHelper();
    FunctionsBackground globalFunctions =FunctionsBackground();
    List<dynamic> invoices_clean=[];  
    List<dynamic> invoices=await globalFunctions.fetchInvoice(globalVars.id); 

      if(invoices.isNotEmpty){
        
        int count = 0;
        int invoiceOld_id=0; 
       
        for(var invoice in invoices){
          count++;
          if(count ==1){
            invoiceOld_id = int.parse(invoice['invoiceID']);
            invoices_clean.add(invoice);
          }
          if(count>1){
              if(invoiceOld_id != int.parse(invoice['invoiceID'])){
                invoices_clean.add(invoice);
                  invoiceOld_id = int.parse(invoice['invoiceID']);
              }

              if(invoiceOld_id == int.parse(invoice['invoiceID'])){
                print('ya existe la factura');
              }
          }
        } 


        for(var invoice in invoices_clean){

          int invoiceID = int.parse(invoice['invoiceID']); 
          //checkinvoice chequea que la factura extraida de la BD de ADempiere no exista en la BD Local.
          List<dynamic> checkinvoice = await dbHelper.querySpecifInt(invoiceID, 'invoice','invoice_id');

          if(checkinvoice.isEmpty){
              print('CHECKINVOICE: La factura NO existe en la BD local.');
              dbHelper.insertInvoiceBackgorund(invoices);
              List<dynamic> products = await globalFunctions.fetchDetailInvoice(invoice['invoiceID']);
              if(products.isNotEmpty){
              for(var productr in products){
                    int productId = int.parse(productr['product_id']);
                    Map<String, dynamic> product={
                'product_id': productId,
                'invoice_id': invoiceID,
                'name': productr['name'],
                'quantity': productr['quantity'],
              };
              await dbHelper.insert(product, 'detail_invoice'); 
              }
          }
          if(products.isEmpty){
            print('no posee productos la factura');
          }

          }

          if(checkinvoice.isNotEmpty){
            print('CHECKINVOICE: La factura ya existe en la BD local.');
          }

      }

      }

    if(invoices.isEmpty){
       print('No tiene facturas asociadas este chofer.');
    }
  } 