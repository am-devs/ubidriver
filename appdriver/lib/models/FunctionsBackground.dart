import 'package:appdriver/models/databasehelper.dart';
import 'package:appdriver/screens/globalVars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FunctionsBackground {

//FUNCION QUE BUSCA LAS LINEAS DE LAS FACTURAS EN ADEMPIERE
Future<List> fetchDetailInvoice(String invoiceId) async{
    FunctionsBackground globalFunctions = FunctionsBackground();
    final List<dynamic> data =[];
    final response = await http.get(Uri.parse('https://apiubitransport.iancarina.com.ve/detailInvoices/$invoiceId'));
     String bodystr = response.body;
      if(bodystr == 'null'){
         print('no tiene facturas asociadas');
    }

    if(response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    }
    else{
      return data;
    }
  }

  Future<List<dynamic>> fetchInvoice(String driver_id) async{
    final List<dynamic> data =[];
    final response = await http.get(Uri.parse('https://apiubitransport.iancarina.com.ve/Invoices/$driver_id'));
    //final response = await http.get(Uri.parse('http://0.0.0.0:8000/Invoices/$driver_id'));
    String bodystr = response.body;
      if(bodystr == 'null'){
         print('no tiene facturas asociadas');
         return data;
      }
      if(response.statusCode == 200){
        final List<dynamic> data = json.decode(response.body);
        print(data);
        return data;
      } 
      
    else {
      return data;
    }
  }
  
  // FUNCION QUE HACE LA SINCRONIZACION DE LA DATA LOCAL A LA BD DE ADEMPIERE
  Future<bool>updateAdempiere(String driver_id, GlobalVars globalVars) async {
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
          await confirms(invoiceIdInt, globalVars);
          bool returns = await upReturn(invoiceIdInt, businessPartnerIdInt, globalVars.id, globalVars.username);
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
  Future<String> createReturnAdempiere(String driver_id, String name_driver, String C_BPartner_ID)async{
    print ('ENTRE EN CREATE RETURN ADEMPIERE///');
    FunctionsBackground globalFunctions = FunctionsBackground();
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
      print('Error de conexion creando la devolucion');
    }
  } catch (e) {
    // Maneja la excepción
     print('Error de conexion: $e');
  }
  
    return recordID;
  }

  //FUNCION PARA AGREGAR LAS LINEAS DE LA ORDEN
  Future<String> createReturnLineAdempiere(String order_id, String product_id, String quantity)async{
    FunctionsBackground globalFunctions = FunctionsBackground();
    String url='https://apiubitransport.iancarina.com.ve/createOrderReturnLine/';
    String recordID='';
    final Map<String, String> headers = {
        'Content-Type': 'application/json',
  };

    final Map<String, String> body_map = {
    "order_id": order_id,
    "product_id":product_id,
    "quantity": quantity,
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
       print('Error de conexion creando la devolucion');
    }
  } catch (e) {
    // Maneja la excepción
    print('Excepción: $e');
  }
    return recordID;
  }  

  
  //FUNCION QUE BUSCA LAS DEVOLUCIONES EN LA BD LOCAL
  Future<bool> upReturn(int invoice_id, int businessPartnerId, String driver_id, String name_driver) async{
    FunctionsBackground globalFunctions = FunctionsBackground();
    DatabaseHelper databaseHelper = DatabaseHelper();
    List<Map> result = await databaseHelper.querySpecifInt(invoice_id, 'return','invoice_id');
    print('devolucion: '+result.toString());

    if(result.isEmpty) {
      print('no tiene devoluciones');
      return false;
  }

    if(result.isNotEmpty) {
    
      String record_id =  await createReturnAdempiere(driver_id, name_driver, businessPartnerId.toString());

        if(record_id.isNotEmpty){

          print('Se creo la cabecera de la devolucion, ID: $record_id');

          for(var return_invoice in result){
          
          String line_record_id = await createReturnLineAdempiere(record_id, return_invoice['product_id'],  return_invoice['quantity']);
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
  Future<void> confirms(invoiceId, globalVars) async{
    FunctionsBackground globalFunctions = FunctionsBackground();
    Map<String, dynamic> dataLog = {};
    var apiUrl = 'https://apiubitransport.iancarina.com.ve/updateInvoiceConfirm/$invoiceId';
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if(response.statusCode != 200){
      print('Error al confirmar la Factura.');
    }

    if (response.statusCode == 200){
      dataLog = json.decode(response.body);
      apiUrl = 'https://apiubitransport.iancarina.com.ve/updateDeliveryConfirm/$invoiceId';
  
      var response2 = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if(response2.statusCode != 200){
        print('Error al confirmar las entregas de la factura.');
      }

      if(response2.statusCode == 200){
      print('Factura y entrega confirmada.');
      }
    }
  }
}