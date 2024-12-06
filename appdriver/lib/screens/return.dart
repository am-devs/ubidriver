import 'package:appdriver/models/databasehelper.dart';
import 'package:appdriver/screens/detailpage.dart';
import 'package:appdriver/screens/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appdriver/screens/globalVars.dart';
import 'package:appdriver/models/globalFunctions.dart';

class ReturnPage extends StatefulWidget {
  final GlobalVars globalvars;
  final int invoiceId;
  final List<dynamic> data;
  final String businessPartnerId;
  final String businessPartner;
  final String ticket_id;
  final String documentoNo;

  ReturnPage({
    required this.globalvars,
    required this.invoiceId,
    required this.businessPartnerId,
    required this.businessPartner,
    required this.ticket_id,
    required this.documentoNo,
    required this.data,
  });

  @override
  _ReturnPageState createState() => _ReturnPageState(
        globalVars: globalvars,
        invoiceId: invoiceId,
        businessPartnerId: businessPartnerId,
        businessPartner: businessPartner,
        ticket_id: ticket_id,
        documentoNo:documentoNo,
        data: data,
      );
}

class _ReturnPageState extends State<ReturnPage> {
  final GlobalVars globalVars;
  final int invoiceId;
  final List<dynamic> data;
  final String businessPartnerId;
  final String businessPartner;
  final String ticket_id;
  final String documentoNo;
  Map<String, dynamic> dataLog = {};
  GlobalFunctions globalFunctions = GlobalFunctions();
  late List<Map<String, dynamic>> mutableData;
  late List<Map<String, dynamic>> originalData;
  List<TextEditingController> _controllers = [];
  bool isLoading = false;

  _ReturnPageState({
    required this.globalVars,
    required this.invoiceId,
    required this.businessPartnerId,
    required this.businessPartner,
    required this.ticket_id,
    required this.documentoNo,
    required this.data,
  });

  @override
  void initState() {
    super.initState();
    originalData = data.map((item) => Map<String, dynamic>.from(item)).toList();
    mutableData = data.map((item) => Map<String, dynamic>.from(item)).toList();
    _controllers = List.generate(
      mutableData.length,
      (index) => TextEditingController(text: '0'),
    );
  }

  @override
  void dispose() {
    // Dispose all text editing controllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 189, 180, 180),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailPage(
                        globalvars: globalVars,
                        invoiceId: invoiceId,
                        businessPartnerId: businessPartnerId,
                        businessPartner: businessPartner,
                        ticket_id: ticket_id,
                        documentoNo: documentoNo,
                      )),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: List.generate(mutableData.length, (index) {
                    var item = mutableData[index];
                    String invoice_quantity = item['quantity'].toString();
                    TextEditingController _controller = _controllers[index];
                    String selectedReason = item['reason'] ?? '';
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          'Producto: ${item['name']}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: <Widget>[
                                Text(
                                  'Cantidad a Entregar: $invoice_quantity',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  'Cantidad a Devolver:',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.left,
                                    onChanged: (value) {
                                      setState(() {
                                        int? devolver = int.tryParse(value);
                                        item['quantity_return'] = devolver ?? 0;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                _showSelectionDialog(context, item);
                              },
                              child: Text('Seleccionar Motivo', style: TextStyle(color: Colors.black)),
                            ),
                            if (selectedReason.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Motivo: $selectedReason',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        trailing: Icon(Icons.check, color: Colors.red),
                      ),
                    );
                  }),
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
                    minimumSize: Size(screenWidth * 0.9, screenHeight * 0.08),
                  ),
                  onPressed: () {
                    DialogoConfirmar(context);
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

  Future<void> _showSelectionDialog(BuildContext context, Map<String, dynamic> item) async {
    String? selectedReason = item['reason'];

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Motivo', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Mercancía Vencida'),
                leading: Radio<String>(
                  value: 'Mercancía Vencida',
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setState(() {
                      item['reason'] = value;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text('Mercancía Defectuosa'),
                leading: Radio<String>(
                  value: 'Mercancía Defectuosa',
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setState(() {
                      item['reason'] = value;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> DialogoConfirmar(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '¿Esta seguro de confirmar la devolución?',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color.fromARGB(255, 189, 180, 180),
          content: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 207, 23, 9),
                ),
                child:  isLoading
                  ? Image.asset(
                      'lib/assets/loading.gif',
                      width: 24,
                      height: 24,
                    )
                  : const Text(
                      'SI',
                      style: TextStyle(color: Colors.white),
                    ),
                onPressed: isLoading ? null : () {
                  confirms(context);
                },
                
              ),
              TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 207, 23, 9),
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

  Future<void> confirms(BuildContext context) async {
     setState(() {
      isLoading = true;
    });
    bool validation_quantity = false;
    bool validation_zero = false;
    bool validation_reason = false;
    var modifiedItems = mutableData.where((item){
      var originalItem = originalData.firstWhere((original) => original['name'] == item['name']);
      String? reason = item['reason'];
      print('REASON: $reason');

      if (item['quantity_return'] == null){
        return false;
      }

      if (item['quantity_return'] > originalItem['quantity']){
        validation_quantity = true;
        return false;
      }

      if (item['quantity_return'] == 0 || item['quantity_return'] <= 0) {
          validation_zero = true;
          return false;
      }

      if (reason == null || reason.isEmpty) {
        print('VALIDACION DE RAZONNNNN');
        validation_reason = true;
        return false;
      }

      if (item['quantity_return'] <= originalItem['quantity']) {
        if (reason != null || reason.isNotEmpty) {
          return true;
        }
      }

      return false;
    }).toList();

    if (modifiedItems.isEmpty) {
      setState(() {
      isLoading = false;
    });
      globalFunctions.errorDialog(
        'No hay productos modificados para la devolucion. Debe seleccionar el MOTIVO y la cantidad del producto debe ser menor o igual a la de la factura.',
        context,
        onDialogClosed: () {
          Navigator.of(context).pop();
        },
      );
    }

    if (modifiedItems.isNotEmpty) {
      bool internet = false;
      DatabaseHelper databaseHelper = DatabaseHelper();

      if (validation_reason) {
      setState(() {
      isLoading = false;
    });
      globalFunctions.errorDialog(
        'Hay un producto que no posee razon de devolucion.',
        context,
        onDialogClosed: () {
          Navigator.of(context).pop();
        },
      );
      return;
    }

      if (validation_quantity) {
        setState(() {
      isLoading = false;
    });
        globalFunctions.errorDialog(
          'Hay un producto con la cantidad mayor a la de la factura.',
          context,
          onDialogClosed: () {
            Navigator.of(context).pop();
          },
        );
        return;
      }
    
    if (validation_zero) {
      setState(() {
      isLoading = false;
    });
      globalFunctions.errorDialog(
        'Hay un producto con la cantidad menor o igual de la factura.',
        context,
        onDialogClosed: () {
          Navigator.of(context).pop();
        },
      );
      return;
    }

      try {
        const String url = 'https://apiubitransport.iancarina.com.ve';
        final http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          internet = true;
          String return_id = await globalFunctions.createReturnAdempiere(globalVars.id.toString(), globalVars.username, businessPartnerId, context);
          if(return_id.isNotEmpty) {
            print('Se creo la cabecera de la devolucion, ID: $return_id');
            for (var item in modifiedItems) {
              print(item['product_id'].toString());
              print(item['quantity_return'].toString());

              if(item['quantity_return'] > 30){
              String authorizationStr = await globalFunctions.createAuthorization(return_id, documentoNo, item['name'].toString(), businessPartner, item['product_id'].toString(), item['quantity_return'].toString(), item['reason'].toString(),context);

              if(authorizationStr.isNotEmpty){
                 print('Se creo correctamente la autorizacion del producto:' + item['product_id'].toString());
              }

              if(authorizationStr.isEmpty){
                 print('No se pudo crear correctamente la autorizacion del producto:' + item['product_id'].toString());
              }

              }
              
              String return_line_id = await globalFunctions.createReturnLineAdempiere(return_id, item['product_id'].toString(), item['quantity_return'].toString(), item['reason'].toString(),context);
              if (return_line_id.isEmpty) {
                print('Error creando la linea de devolucion del producto:' + item['product_id'].toString());
              }
              if (return_line_id.isNotEmpty) {
                print('Se creo correctamente la linea de devolucion del producto:' + item['product_id'].toString());
              }
            }
          }

          if (return_id.isEmpty) {
            setState(() {
              isLoading = false;
            });
            print('el ID de la devolucion es vacio, hubo error en la creacion');
          }
        }
        if (response.statusCode != 200) {
          internet = false;
          setState(() {
          isLoading = false;
          });
          globalFunctions.errorDialog('No se pudo crear la devolucion correctamente', context);
        }
      } catch (e) {
        for (var item in modifiedItems) {
          DatabaseHelper databaseHelper = DatabaseHelper();
          Map<String, dynamic> return_new = {
            'invoice_id': invoiceId,
            'businessPartnerId': businessPartnerId.toString(),
            'product_id': item['product_id'].toString(),
            'reason': item['reason'].toString(),
            'quantity': item['quantity_return'].toString(),
          };

          Map<String, dynamic> invoiceUpdate = {
            'invoice_id': invoiceId,
            'is_confirm': 1,
          };
          databaseHelper.insert(return_new, 'return');
          databaseHelper.update(invoiceUpdate, 'invoice', 'invoice_id');
          internet = false;

          List<Map> result = await databaseHelper.queryAll('return');
          if (result.isNotEmpty) {
            for (var res in result) {
              print('DEVOLUCION: ' + res['return_id'].toString() + 'id de la factura: ' + res['invoice_id'].toString());
            }
          }
          if (result.isEmpty) {
            print('NO SE INSERTO LA DEVOLUCION');
            setState(() {
              isLoading = false;
              });
          }
        }
      }

      if (internet) {
        await confirmInvoice(invoiceId);
        databaseHelper.delete(invoiceId, 'invoice', 'invoice_id');
        print('se borraron la facturas');
        databaseHelper.delete(invoiceId, 'detail_invoice', 'invoice_id');
        print('se borraron la lineas de las facturas');
        setState(() {
              isLoading = false;
              });
      }

      if (internet == false) {
        print('Se hicieron las operaciones para guardar en BD local.');
        setState(() {
              isLoading = false;
              });
      }

      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'DEVOLUCION CREADA',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color.fromARGB(255, 189, 180, 180),
            content: Text(
              'Se ha creado la devolucion y se confirmo la factura.',
              
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 207, 23, 9),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainPage(globalvars: globalVars)),
                  );
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> confirmInvoice(invoiceId) async {
    var apiUrl = 'https://apiubitransport.iancarina.com.ve/updateInvoiceConfirm/$invoiceId';

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode != 200) {
      globalFunctions.errorDialog('Error al confirmar la factura.', context);
    }

    if (response.statusCode == 200) {
      dataLog = json.decode(response.body);
      print(response.body);
      print(dataLog);
      apiUrl = 'https://apiubitransport.iancarina.com.ve/updateDeliveryConfirm/$invoiceId';

      var response2 = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response2.statusCode != 200) {
        globalFunctions.errorDialog('Error al confirmar las entregas de la factura.', context);
      }

      if (response2.statusCode == 200) {
        print('Factura y entregada confirmada');

      }
    }
  }
}
