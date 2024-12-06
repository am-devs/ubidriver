import 'dart:convert';
import 'package:appdriver/models/databasehelper.dart';
import 'package:appdriver/models/globalFunctions.dart';
import 'package:appdriver/screens/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appdriver/screens/globalVars.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _codeController = TextEditingController();
  late List<dynamic> datos = [];
  Map<String, dynamic> dataLog = {};
  GlobalVars globalVars = GlobalVars();
  bool isLoading = false;
  GlobalFunctions globalFunctions = GlobalFunctions();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 189, 180, 180),
      appBar: AppBar(
        title: const Text(
          'ChoferApp',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 207, 23, 9),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 70.0),
              child: const Image(
                image: AssetImage('lib/assets/MaryLogo-removebg-preview.png'),
                width: 200,
                height: 200,
                alignment: Alignment.topCenter,
              ),
            ),
            TextField(
              controller: _codeController,
              cursorColor: Colors.white,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                labelText: 'Ingrese su Cedula',
                labelStyle: TextStyle(color: Colors.white),
                floatingLabelStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 207, 23, 9),
              ),
              child: isLoading
                  ? Image.asset(
                      'lib/assets/loading.gif',
                      width: 24,
                      height: 24,
                    )
                  : const Text(
                      'Iniciar sesión',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });
    var ci = _codeController.text;
    DatabaseHelper dbHelper = DatabaseHelper();
    bool dbExists = await dbHelper.databaseExists();
    print('LA BD EXISTE?: $dbExists');

    //SI LA BD LOCAL NO EXISTE
    if(dbExists == false){
    try{
      var apiUrl = 'https://apiubitransport.iancarina.com.ve/logindriver/$ci';

    var response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    print(response.statusCode);

    

    if(response.statusCode != 200){
      setState(() {
      isLoading = false;
    });
    globalFunctions.errorDialog('Error al ingresar al sistema, revise las credenciales.', context);
    return;
    }
    if(response.statusCode == 200){
      dataLog = json.decode(response.body);
      globalVars.username = dataLog['username'];
      globalVars.code = dataLog['code'];
      globalVars.id = dataLog['id'];
      globalVars.company = dataLog['company'];
      print(dataLog['username']);
      print(globalVars.id);

      Map<String, dynamic> driver = {
        'driver_id':globalVars.id,
        'username':globalVars.username,
        'code':globalVars.code,
        'company':globalVars.company, 
      };
      dbHelper.insert(driver, 'driver');
      String driver_id = globalVars.id;
      List<dynamic> invoices =await globalFunctions.fetchInvoice(driver_id, context);
      List<dynamic> invoices_clean=[];

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
       
        dbHelper.insertInvoice(invoices_clean, context);
    
    
          for (var invoice in invoices_clean){
          print('FACTURA ID:'+invoice['invoice_id'].toString());
          List<dynamic> products = await globalFunctions.fetchDetailInvoice(invoice['invoiceID'], context);
          int invoiceID = int.parse(invoice['invoiceID']);

          if(products.isNotEmpty){
            for(var productr in products){
            int productId = int.parse(productr['product_id']);

            Map<String, dynamic> product={
              'product_id': productId,
              'invoice_id': invoiceID,
              'name': productr['name'],
              'quantity': productr['quantity'],
            };

            print(product.toString());
            await dbHelper.insert(product, 'detail_invoice'); 
            }
          }

          if(products.isEmpty){
          print('no hay productos');
          }  

        }
        setState(() {
          isLoading = false;
        });
         Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainPage(globalvars: globalVars)),
        ); 
      }

        if(invoices.isEmpty){
          print('No tiene facturas asociadas este chofer.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainPage(globalvars: globalVars)),
          );
        }
         
    }

    }catch(e){
      
      globalFunctions.errorDialog('Error de conexion: $e', context);
      setState(() {
      isLoading = false;
      });

    }
    
    }

    //SI LA BD LOCAL EXISTE
    if(dbExists){
      List<Map<String, dynamic>> users = await dbHelper.querySpecif(ci, 'driver', 'code');
      if(users.isNotEmpty){
      
      for(var user in users){
      print('USUARIO: '+user.toString());
      globalVars.username = user['username'];
      globalVars.code = user['code'];
      globalVars.id = user['driver_id'].toString();
      globalVars.company = user['company'];
      }
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainPage(globalvars: globalVars)),
      );
      
      }

       if(users.isEmpty){
         globalFunctions.errorDialog('No existe el usuario. ${globalVars.username} ', context);
         setState(() {
      isLoading = false;
      });
         return;
      }
    }
  }
}
