import 'package:appdriver/models/globalFunctions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{
    String path = join(await getDatabasesPath(), 'geolocate.db');
    print('PATHHH:  '+path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async{
    
    await db.execute('''
    CREATE TABLE user(
      user_id INTEGER PRIMARY KEY,
      m_warehouse_id TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE driver(
      driver_id INTEGER PRIMARY KEY,
      username TEXT,
      code TEXT,
      company TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE invoice(
      invoice_id INTEGER PRIMARY KEY,
      documentoNo TEXT,
      date TEXT,
      org TEXT,
      businessPartner TEXT,
      businessPartnerId TEXT,
      ticket TEXT,
      sync INT,
      is_confirm INT
    )
    ''');

    await db.execute('''
    CREATE TABLE detail_invoice(
      detail_invoice INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INT,
      invoice_id INT,
      name TEXT,
      quantity REAL,
      FOREIGN KEY(invoice_id) REFERENCES invoice(invoice_id)
    )
    ''');
    
    await db.execute('''
    CREATE TABLE location_driver(
      location_driver_id INTEGER PRIMARY KEY AUTOINCREMENT,
      latitud REAL,
      longitud REAL,
      driver_id INT,
      FOREIGN KEY(driver_id) REFERENCES driver(driver_id)
    )
    ''');
    
    await db.execute('''
    CREATE TABLE return(
      return_id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INT,
      businessPartnerId TEXT,
      product_id TEXT,
      reason TEXT,
      quantity TEXT,
      FOREIGN KEY(invoice_id) REFERENCES invoice(invoice_id)
    )
    ''');
  }

  Future<void> insertInvoiceBackgorund(List<dynamic> invoices) async {
  GlobalFunctions globalFunctions = GlobalFunctions();
  DatabaseHelper databaseHelper = DatabaseHelper(); 
  for (var item in invoices) {
    try {
      int invoiceId = int.parse(item['invoiceID']);
      Map<String, dynamic> invoicelocal = {
        'invoice_id': invoiceId,
        'documentoNo': item['documentoNo'],
        'date': item['date'],
        'org': item['org'],
        'businessPartner': item['businessPartner'],
        'businessPartnerId': item['businessPartnerId'],
        'ticket': item['ticket'],
        'sync': 0,
        'is_confirm': 0,
      };
      print(invoicelocal.toString());
      await databaseHelper.insert(invoicelocal, 'invoice');
      print('Factura insertada correctamente');
      //await databaseHelper.insertProduct(detailInvoices, invoiceId); // Asegúrate de esperar a que termine
    } catch (e) {
      print('Error inserting invoice: $e');
    }
  }
  print('Facturas insertadas correctamente');
  }


  Future<void> insertInvoice(List<dynamic> invoices,  context) async {
  GlobalFunctions globalFunctions = GlobalFunctions();
  DatabaseHelper databaseHelper = DatabaseHelper(); 
  for (var item in invoices) {
    try {
      int invoiceId = int.parse(item['invoiceID']);
      Map<String, dynamic> invoicelocal = {
        'invoice_id': invoiceId,
        'documentoNo': item['documentoNo'],
        'date': item['date'],
        'org': item['org'],
        'businessPartner': item['businessPartner'],
        'businessPartnerId': item['businessPartnerId'],
        'ticket': item['ticket'],
        'sync': 0,
        'is_confirm': 0,
      };
      print(invoicelocal.toString());
      await databaseHelper.insert(invoicelocal, 'invoice');
      print('Factura insertada correctamente');
      //List<dynamic> detailInvoices = await globalFunctions.fetchDetailInvoice(item['invoiceID'], context);
      //await databaseHelper.insertProduct(detailInvoices, invoiceId); // Asegúrate de esperar a que termine
    } catch (e) {
      print('Error inserting invoice: $e');
    }
  }
  print('Facturas insertadas correctamente');
}

Future<void> insertProduct(List<dynamic> products, int invoiceId) async{
  DatabaseHelper databaseHelper = DatabaseHelper();
  for (var item in products) {
    try {
      int productId = int.parse(item['product_id']);
      Map<String, dynamic> product = {
        'product_id': productId,
        'invoice_id': invoiceId,
        'name': item['name'],
        'quantity': item['quantity'],
      };
      print(product.toString());
      await databaseHelper.insert(product, 'product'); // Asegúrate de esperar a que termine
    } catch (e) {
      print('Error inserting product: $e');
    }
  }
  print('Productos insertados correctamente');
}



  Future<int> insert(Map<String, dynamic> row, String table) async{
  Database db = await database;
  try {
    return await db.insert(table, row);
  } catch (e) {
    print('Error inserting into $table: $e');
    return -1;
  }
}
  
  //Nueva función para consultas específicas
  Future<List<Map<String, dynamic>>> querySpecif(String condition, String table, String varWhere) async{
    Database db = await database;
    return await db.query(
      table,
      where: '$varWhere = ?',
      whereArgs: [condition],
    );
  }

  //Nueva función para consultas específicas
  Future<List<Map<String, dynamic>>> querySpecifInt(int condition, String table, String varWhere) async{
    Database db = await database;
    return await db.query(
      table,
      where: '$varWhere = ?',
      whereArgs: [condition],
    );
  }

  
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    Database db = await database;
    return await db.query(table);
  }

  Future<int> update(Map<String, dynamic> row, String table, String rowId) async {
    Database db = await database;
    int id = row[rowId];
    return await db.update(table, row, where: '$rowId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id, String table,String rowId) async{
    Database db = await database;
    return await db.delete(table, where: '$rowId = ?', whereArgs: [id]);
  }

   Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }

  Future<bool> databaseExists() async {
    String path = join(await getDatabasesPath(), 'geolocate.db');
    return await databaseFactory.databaseExists(path);
  }



}
