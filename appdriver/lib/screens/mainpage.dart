import 'package:appdriver/models/databasehelper.dart';
import 'package:appdriver/screens/detailpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:appdriver/screens/globalVars.dart';
import 'package:appdriver/models/globalFunctions.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class MainPage extends StatefulWidget {
  final GlobalVars globalvars;
  MainPage({required this.globalvars});

  @override
  _MainPageState createState() => _MainPageState(globalVars: globalvars);
}

class _MainPageState extends State<MainPage> {
  final GlobalVars globalVars;
  GlobalFunctions globalFunctions = GlobalFunctions();
  _MainPageState({required this.globalVars});
  bool _isLoading = true;
  List<dynamic> _dataList = [];

  @override
  void initState(){
    super.initState();
    FlutterBackgroundService().invoke('setAsBackground');
    getInvoices();
  }

  //Chequea si hay facturas nuevas por agregar a la bd local.  
  Future<void> getInvoices() async {
    try{
      final response = await http.get(Uri.parse('https://apiubitransport.iancarina.com.ve'));
      if(response.statusCode == 200){
         DatabaseHelper dbHelper=DatabaseHelper();
    List<dynamic> invoices_clean=[];  
    List<dynamic> invoices=await globalFunctions.fetchInvoice(globalVars.id, context); 

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
              dbHelper.insertInvoice(invoices, context);
              List<dynamic> products = await globalFunctions.fetchDetailInvoice(invoice['invoiceID'], context);
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
      DatabaseHelper databaseHelper = DatabaseHelper();
      //Database db = await databaseHelper.database;
      List<Map> result = await databaseHelper.querySpecifInt(0,'invoice','is_confirm'); 
       setState(() {
        _dataList = result;
        _isLoading = false;
       });

      }

    if(invoices.isEmpty){
       print('No tiene facturas asociadas este chofer.');
       DatabaseHelper databaseHelper = DatabaseHelper();
      //Database db = await databaseHelper.database;
      List<Map> result = await databaseHelper.querySpecifInt(0,'invoice','is_confirm'); 
       setState(() {
        _dataList = result;
        _isLoading = false;
       });

      }
       
    }
      
    }catch(e){
      print('No hay conexion a internet.');
       DatabaseHelper databaseHelper = DatabaseHelper();
      //Database db = await databaseHelper.database;
      List<Map> result = await databaseHelper.querySpecifInt(0,'invoice','is_confirm'); 
       setState(() {
        _dataList = result;
        _isLoading = false;
       });
      
    }
  } 
  
  // Future<void> updateData() async{
  //   try{
  //     final response = await http.get(Uri.parse('https://apiubitransport.iancarina.com.ve'));
  //     if(response.statusCode == 200){
  //     //Sincroniza la Data con Adempiere
  //     bool checkUpdates = await globalFunctions.updateAdempiere(globalVars.id, context, globalVars);
  //     if(checkUpdates){
  //     print('se sincronizaron los datos correctamente');
  //     getInvoices();
  //     setState((){
  //           _isLoading = false;
  //          });
  //     }
  //     else {
  //     print('no existen Facturas por actualizar.');
  //     getInvoices();
  //     DatabaseHelper databaseHelper = DatabaseHelper();
  //     Database db = await databaseHelper.database;
  //     List<Map> result = await db.query('invoice');
  //     print('RESULTADO'+result.toString());
  //     setState((){
  //            _dataList = result;
  //            _isLoading = false;
  //          });
  //     }
  //   }
  //   }catch(e){
  //    print('ERROR: $e');
  //    print('SIN CONEXION');
  //    //Busca la data en la BD Local
  //    DatabaseHelper databaseHelper = DatabaseHelper();
  //    //Database db = await databaseHelper.database;
  //    List<Map> result = await databaseHelper.querySpecifInt(0,'invoice','is_confirm');
      
  //    setState((){
  //            _dataList = result;
  //            _isLoading = false;
  //                 });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 189, 180, 180),
      appBar: AppBar(
        title: Text(
          'ChoferApp',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 207, 23, 9),
      ),
      drawer: Drawer( 
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('Chofer: '+globalVars.username),
              accountEmail: Text('Codigo: '+globalVars.code),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  globalVars.username[0],
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 207, 23, 9),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Menu'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Autorizaciones de Devoluciones'),
              onTap: () {
              //  Navigator.pushReplacement(
              //          context,
              //          MaterialPageRoute(builder: (context) => DetailPage(globalvars: globalVars, invoiceId: item['invoice_id'],businessPartnerId: item['businessPartnerId'],businessPartner: item['businessPartner'], ticket_id: item['ticket'])),
              //  );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Salir'),
              onTap: () {
                globalFunctions.mostrarDialogoSalir(context);
              },
            ),
          ],
        ),
      ),
      body:
       _isLoading
          ? Center(child: CircularProgressIndicator())
          :  
          _dataList.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0), // Ajusta el valor según sea necesario
                  child: Text(
                    'No tienes Entregas por Despachar.',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              )
          :
          SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: 
                  _dataList.map((item) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                      child: InkWell(
                      onTap: (){
                      print(globalVars.toString());
                      print('INVOICE ID:'+ item['invoice_id'].toString());
                      print('BUSINESSPARTNER ID:'+ item['businessPartnerId']);
                      print(item['businessPartner']);
                      print(item['ticket']);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DetailPage(globalvars: globalVars, invoiceId: item['invoice_id'],businessPartnerId: item['businessPartnerId'],businessPartner: item['businessPartner'], ticket_id: item['ticket'], documentoNo: item['documentoNo'])),
                      );
                      },
                     child:
                     ListTile(
                        title: Text(
                          'Nro Documento: ${item['documentoNo']}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Organización: ${item['org']}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Cliente: ${item['businessPartner']}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Fecha: ${item['date']}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                        color: Colors.red),
                      ),
                      ), 
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
