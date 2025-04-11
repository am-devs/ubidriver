import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final _baseUrl = Uri.parse("http://192.168.1.102:8084/v1");

  Future authenticate(String cedula) async {
    var response = await http.post(
      Uri.parse("$_baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'cedula': cedula}),
    );

    print(response.statusCode);
    print(response.body);
  }
}
