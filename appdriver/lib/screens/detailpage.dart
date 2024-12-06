import 'package:appdriver/models/databasehelper.dart';
import 'package:appdriver/screens/mainpage.dart';
import 'package:appdriver/screens/return.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appdriver/screens/globalVars.dart';
import 'package:appdriver/models/globalFunctions.dart';

class DetailPage extends StatefulWidget {
  final GlobalVars globalvars;
  final int invoiceId;
  final String businessPartnerId;
  final String businessPartner;
  final String ticket_id;
  final String documentoNo;
  DetailPage({required this.globalvars, required this.invoiceId, required this.businessPartnerId, required this.businessPartner, required this.ticket_id, required this.documentoNo});
  
  @override
  _DetailPageState createState() => _DetailPageState(globalVars: globalvars, invoiceId: invoiceId, businessPartnerId:businessPartnerId, businessPartner:businessPartner, ticket_id:ticket_id, documentoNo: documentoNo);
}

class _DetailPageState extends State<DetailPage> {
  final GlobalVars globalVars;
  final int invoiceId;
  final String businessPartnerId;
  final String businessPartner;
  final String ticket_id;
  final String documentoNo;
  GlobalFunctions globalFunctions = GlobalFunctions();
  _DetailPageState({required this.globalVars, required this.invoiceId, required this.businessPartnerId, required this.businessPartner, required this.ticket_id, required this.documentoNo});
  bool _isLoading = true;
  List<dynamic> _dataList = [];
  Map<String, dynamic> dataLog = {};

  @override
  void initState() {
    super.initState();
    //fetchData();
    getDetailInvoice();
  }


  Future<void> getDetailInvoice() async {

      DatabaseHelper databaseHelper = DatabaseHelper();
      List<Map> result = await databaseHelper.querySpecifInt(invoiceId, 'detail_invoice','invoice_id');
      setState((){
             _dataList = result;
             _isLoading = false;
           });
  } 

  // Future<void> fetchData() async {
  //   final response = await http.get(Uri.parse('https://apiubitransport.iancarina.com.ve/detailInvoices/$invoiceId'));
  //    //final response = await http.get(Uri.parse('http://0.0.0.0:8000/detailInvoices/$invoiceId'));
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     setState(() {
  //       _dataList = data;
  //       _isLoading = false;
  //     });
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     throw Exception('Failed to load data');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 189, 180, 180), // Fondo rojo
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Utiliza Navigator.pop para regresar al widget anterior
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainPage(globalvars: globalVars)),
            );
          },
        ),
        title: Text(
          'ChoferApp',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 207, 23, 9),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: _dataList.map((item) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(
                                'Producto: ${item['name']}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cantidad: ${item['quantity']}',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              trailing: Icon(Icons.check, color: Colors.red),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 207, 23, 9),
                          minimumSize: Size(screenWidth * 0.45, screenHeight * 0.08),
                        ),
                        onPressed: () {
                          DialogoConfirmar(context);
                        },
                        child: Text(
                          'Confirmar',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 207, 23, 9),
                          minimumSize: Size(screenWidth * 0.45, screenHeight * 0.08),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReturnPage(globalvars: globalVars, invoiceId: invoiceId, businessPartnerId: businessPartnerId, businessPartner: businessPartner,ticket_id:ticket_id, documentoNo: documentoNo,data: _dataList)),
                        ); 
                        },
                        child: Text(
                          'Devolución',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> DialogoConfirmar(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, //No se puede cerrar tocando fuera del diálogo
      builder: (BuildContext context) {
        return AlertDialog(
        title: Text(
          '¿Esta seguro de confirmar la entrega? asegurese de que no realizara una devolucion.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color.fromARGB(255, 189, 180, 180),
        content: ButtonBar(
          alignment: MainAxisAlignment.spaceAround, // Centra los botones
          children: [
            TextButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 207, 23, 9), // Color del botón
              ),
              child: Text(
                'SI',
                style: TextStyle(color: Colors.white),
              ),
              onPressed:(){
                confirms(invoiceId); // Cierra el diálogo
              },
            ),
            TextButton(
              // Color del botón
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 207, 23, 9), // Color del botón
              ),
              child: Text(
                'NO',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
          ],
        ),
      );
      },
      );
    }

    Future<void> confirms(invoiceId) async { 
    DatabaseHelper databaseHelper = DatabaseHelper();

    try{
    final response = await http.get(Uri.parse('https://apiubitransport.iancarina.com.ve'));

    if(response.statusCode == 200){

          String apiUrl = 'https://apiubitransport.iancarina.com.ve/updateInvoiceConfirm/$invoiceId';
          var response2 = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          );

          if(response2.statusCode != 200){
          globalFunctions.errorDialog('Error al confirmar la factura.', context);
          }

          if(response2.statusCode == 200){
              print("Se confirmo la factura $invoiceId"); 
              var apiUrl = 'https://apiubitransport.iancarina.com.ve/updateDeliveryConfirm/$invoiceId';
              var response = await http.post(
              Uri.parse(apiUrl),
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
              );

              if(response.statusCode==200){
                print('se confirmaron correctamente las entregas de la factura: $invoiceId');
              }

              if(response.statusCode!=200){
                print('no se confirmaron las entrega');
              }
            
          databaseHelper.delete(invoiceId, 'invoice', 'invoice_id');
          databaseHelper.delete(invoiceId, 'detail_invoice', 'invoice_id');
          return showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('CONFIRMADO', style: TextStyle(color: Colors.white),),
                  backgroundColor: const Color.fromARGB(255, 189, 180, 180),
                  content: Text('Factura y entrega confirmada.', style:const TextStyle(color: Colors.white),),
                  actions:[
                    TextButton(
                       style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 207, 23, 9), // Color del botón
                       ),
                       onPressed: () {
                         Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainPage(globalvars: globalVars)),
                        );
                       },
                       child: const Text('OK', style: TextStyle(color: Colors.white),),
                       ),
                    ],
                  );
       },   
     );
    }
        
    }
    
    if(response.statusCode!=200){
        globalFunctions.errorDialog('Error no hay conexion.', context);
    }

    }catch(e){
      print('SIN CONEXION, Error: $e');
      //Actualiza la data en la BD Local
      Map<String, dynamic> invoiceUpdate={
            'invoice_id':invoiceId,
            'is_confirm': 1,
      };
      DatabaseHelper databaseHelper = DatabaseHelper();
      databaseHelper.update(invoiceUpdate, 'invoice', 'invoice_id');
      List<Map> result = await databaseHelper.queryAll('invoice');
            if(result.isNotEmpty){
            for(var res in result){
                print('FACTURA ID: '+res['invoice_id'].toString()+'  SYNC: '+res['is_confirm'].toString());
            }
            }
            if(result.isEmpty){
                print('NO SE ACTUALIZO LA FACTURA');
            }

      return showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('CONFIRMADO', style: TextStyle(color: Colors.white),),
                  backgroundColor: const Color.fromARGB(255, 189, 180, 180),
                  content: Text('Se confirmo la factura en base de datos local.', style:const TextStyle(color: Colors.white),),
                  actions:[
                    TextButton(
                       style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 207, 23, 9), // Color del botón
                       ),
                       onPressed: () {
                         Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainPage(globalvars: globalVars)),
                        );
                       },
                       child: const Text('OK', style: TextStyle(color: Colors.white),),
                       ),
                 ],
               );
       },
      );
    }
} 
}