import 'package:appdriver/models/databasehelper.dart';
import 'package:appdriver/screens/globalVars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GlobalFunctions {
  

  Future<void> mostrarDialogoSalir(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, //No se puede cerrar tocando fuera del diálogo
      builder: (BuildContext context) {
        return AlertDialog(
        title: Text(
          '¿Realmente quieres salir?',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color.fromARGB(255, 189, 180, 180),
        content: ButtonBar(
          alignment: MainAxisAlignment.center, // Centra los botones
          children: [
            TextButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 207, 23, 9), // Color del botón
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              // Color del botón
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 207, 23, 9), // Color del botón
              ),
              child: Text(
                'Salir',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                SystemNavigator.pop();// Cierra la App
              },
            ),
          ],
        ),
      );
      },
      );
    }

  Future<void> errorDialog(String error, BuildContext context, {VoidCallback? onDialogClosed}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Error', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 189, 180, 180),
        content: Text(error, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 207, 23, 9), // Color del botón
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo de error
              if (onDialogClosed != null) {
                onDialogClosed(); // Ejecuta la función callback si está definida
              }
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

//FUNCION QUE BUSCA LAS LINEAS DE LAS FACTURAS EN ADEMPIERE
Future<List> fetchDetailInvoice(String invoiceId, BuildContext context) async{
    GlobalFunctions globalFunctions = GlobalFunctions();
    final List<dynamic> data =[];
    final response = await http.get(Uri.parse('https://apiubitransport.iancarina.com.ve/detailInvoices/$invoiceId'));
     String bodystr = response.body;
      if(bodystr == 'null'){
         print('no tiene facturas asociadas');
         globalFunctions.errorDialog('No se encuentra el detalle de la factura.', context);

    }

    if(response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    }
    else{
      return data;
    }
  }

  Future<List<dynamic>> fetchInvoice(String driver_id, BuildContext context) async{
    final List<dynamic> data =[];
    print('entre en fetchinvoiceeee');
    try{
      final response = await http.get(Uri.parse('https://apiubitransport.iancarina.com.ve/Invoices/$driver_id'));
    //final response = await http.get(Uri.parse('http://0.0.0.0:8000/Invoices/$driver_id'));
    String bodystr = response.body;
      if(bodystr == 'null'){
         print('no tiene facturas asociadas');
         return data;
      }
      if(response.statusCode == 200){
        final List<dynamic> data = json.decode(response.body);
        return data;
      } 
    else {
      return data;
    }

    }catch(e){
      print('error de conexion: $e');
      return data;
    }
    
  }
  
  // FUNCION QUE HACE LA SINCRONIZACION DE LA DATA LOCAL A LA BD DE ADEMPIERE
  Future<bool>updateAdempiere(String driver_id, BuildContext context,GlobalVars globalVars) async {
    //Busca Si existen facturas confirmadas en la BD local. Confirma y borra de la BD Local
    DatabaseHelper databaseHelper = DatabaseHelper();
    List<Map> result = await databaseHelper.querySpecifInt(1, 'invoice','is_confirm');
    print('resultado: '+result.toString());
    if(result.isEmpty){
      return false;
    }      
        
    if(result.isNotEmpty) {
      for(var invoice in result) {
          var invoice_id = invoice['invoice_id'];
          var businessPartnerId = invoice['businessPartnerId'];
          int invoiceIdInt;
          int businessPartnerIdInt;

          // Verifica si invoice_id es de tipo String y conviértelo a int
          if (invoice_id is String) { 
            invoiceIdInt = int.parse(invoice_id);
          } else if (invoice_id is int) {
            invoiceIdInt = invoice_id;
          } else {
            throw Exception('invoice_id is not a valid type');
          } 

          // Verifica si businessPartnerId es de tipo String y conviértelo a int
          if(businessPartnerId is String) {
            businessPartnerIdInt = int.parse(businessPartnerId);
          } else if (businessPartnerId is int) {
            businessPartnerIdInt = businessPartnerId;
          } else {
            throw Exception('businessPartnerId is not a valid type');
          }
          await confirms(invoiceIdInt, context, globalVars);
          bool returns = await upReturn(invoiceIdInt, businessPartnerIdInt, globalVars.id, globalVars.username, context);
          databaseHelper.delete(invoice_id, 'invoice', 'invoice_id');
          databaseHelper.delete(invoice_id, 'detail_invoice', 'invoice_id');
          databaseHelper.delete(invoice_id, 'return', 'invoice_id');
          if(returns){
            print('se inserto la factura: $invoice_id con sus devoluciones');
            return true;
          }
          if(returns == false){
            print('se insertaron las factura: $invoice_id. No habian Devoluciones');
            return true;
          }
        }
      }
      return false;
  }

  //Funcion que Crea la Orden de Devolucion en Adempiere
  Future<String> createReturnAdempiere(String driver_id, String name_driver, String C_BPartner_ID, BuildContext context)async{
    print ('ENTRE EN CREATE RETURN ADEMPIERE///');
    GlobalFunctions globalFunctions = GlobalFunctions();
    String url='https://apiubitransport.iancarina.com.ve/createOrderReturn';
    String recordID='';
    final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  final Map<String, String> body_map = {
    "driver_id": driver_id,
    "name_driver": name_driver,
    "c_bpartner_id": C_BPartner_ID,
  };


    try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body_map),
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200){
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      recordID = jsonResponse['record_id'];

      if(recordID.isNotEmpty) {
        print('Se creo la devolucion, RecordID: $recordID');
        return recordID;
      }

      if(recordID.isEmpty){
        print('NO SE CREO LA DEVOLUCION PADRE');
        return recordID;
      }

    }else{
      // Maneja el error
      globalFunctions.errorDialog('Error de conexion creando la devolucion', context);
    }
  } catch (e) {
    // Maneja la excepción
     globalFunctions.errorDialog('Error de conexion: $e', context);
  }
  
    return recordID;
  }

  //FUNCION PARA AGREGAR LAS LINEAS DE LA ORDEN
  Future<String> createReturnLineAdempiere(String order_id, String product_id, String quantity, String  reason, BuildContext context)async{
    GlobalFunctions globalFunctions = GlobalFunctions();
    String url='https://apiubitransport.iancarina.com.ve/createOrderReturnLine/';
    String recordID='';
    final Map<String, String> headers = {
        'Content-Type': 'application/json',
  };
  
    final Map<String, String> body_map = {
    "order_id": order_id,
    "product_id":product_id,
    "quantity": quantity,
    "reason": reason,
  };

    try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body_map),
    );

    print('STATUS CODE:');
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200){
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('JSONRESPONSE: $jsonResponse');
      recordID = jsonResponse['record_id'];

      if(recordID.isNotEmpty){
        print('Se creo la Linea de la devolucion, RecordID: $recordID');
        return recordID;
      }

      if(recordID.isEmpty){
        return recordID;
      }

    }else{
      
      // Maneja el error
       globalFunctions.errorDialog('Error de conexion creando la devolucion', context);
    }
  } catch (e) {
    // Maneja la excepción
    globalFunctions.errorDialog('Error de conexion: $e', context);
    print('Excepción: $e');
  }
    return recordID;
  }

  //FUNCION PARA CREAR AUTORIZACION DE DEVOLUCION
  Future<String> createAuthorization(String order_id, String documentoNo, String name_item,String businessPartner,String product_id, String quantity, String  reason, BuildContext context)async{
    GlobalFunctions globalFunctions = GlobalFunctions();
    //falta crear la ruta en la API
    String url='https://apiubitransport.iancarina.com.ve/createAuthorizationReturn/';
    String recordID='';
    final Map<String, String> headers = {
        'Content-Type': 'application/json',
  };

    final Map<String, String> body_map = {
    "order_id": order_id,
    "documentoNo":documentoNo,
    "name_item":name_item,
    "businessPartner":businessPartner,
    "product_id":product_id,
    "quantity": quantity,
    "reason": reason,
  };

    try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body_map),
    );

    print('STATUS CODE:');
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200){
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print('JSONRESPONSE: $jsonResponse');
      return 'se creo con exito la autorizacion de devolucion';
    }else{ 
      return '';
    }
  } catch (e) {
    // Maneja la excepción
    globalFunctions.errorDialog('Error de conexion: $e', context);
    print('Excepción: $e');
  }
    return recordID;
  }    

  
  //FUNCION QUE BUSCA LAS DEVOLUCIONES EN LA BD LOCAL
  Future<bool> upReturn(int invoice_id, int businessPartnerId, String driver_id, String name_driver, context) async{
    GlobalFunctions globalFunctions = GlobalFunctions();
    DatabaseHelper databaseHelper = DatabaseHelper();
    List<Map> result = await databaseHelper.querySpecifInt(invoice_id, 'return','invoice_id');
    print('devolucion: '+result.toString());

    if(result.isEmpty) {
      print('no tiene devoluciones');
      return false;
    }

    if(result.isNotEmpty) {
    
      String record_id =  await createReturnAdempiere(driver_id, name_driver, businessPartnerId.toString(),context);

        if(record_id.isNotEmpty){

          print('Se creo la cabecera de la devolucion, ID: $record_id');

          for(var return_invoice in result) {
          
          String line_record_id = await createReturnLineAdempiere(record_id, return_invoice['product_id'],  return_invoice['quantity'], return_invoice['reason'],context);
          if(line_record_id.isNotEmpty){
            print('se creo la linea de la devolucion: $line_record_id');
          }
          if(line_record_id.isEmpty){
            print('no se pudo crear la linea de la devolucion del: '+return_invoice['product_id']);
          }
          }
          return true; 
        }
      return true;
    } 
    return false;
  } 

  //FUNCION QUE CONFIRMA LA FACTURA Y LA ENTREGA EN ADEMPIERE
  Future<void> confirms(invoiceId, context, globalVars) async{
    GlobalFunctions globalFunctions = GlobalFunctions();
    Map<String, dynamic> dataLog = {};
    var apiUrl = 'https://apiubitransport.iancarina.com.ve/updateInvoiceConfirm/$invoiceId';
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if(response.statusCode != 200){
      globalFunctions.errorDialog('Error al confirmar la Factura.', context);
    }

    if (response.statusCode == 200){
      dataLog = json.decode(response.body);
      apiUrl = 'https://apiubitransport.iancarina.com.ve/updateDeliveryConfirm/$invoiceId';
  
      var response2 = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if(response2.statusCode != 200){
      globalFunctions.errorDialog('Error al confirmar las entregas de la factura.', context);
      }

      if(response2.statusCode == 200){
      print('Factura y entrega confirmada.');
      }
    }
  }
}