import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final _baseUrl = Uri.parse("http://192.168.1.222:8084/v1");
  String _token = "";

  Future<bool> authenticate(String cedula) async {
    var response = await http.post(
      Uri.parse("$_baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'cedula': cedula}),
    );

    Map<String, dynamic> data = jsonDecode(response.body);

    if(data.containsKey('error')) {
      print("Error $data");

      return false;
    } else {
      _token = data["token"] as String;
      return true;
    }
  }

  Future<T> get<T>(String route) async {
    var response = await http.get(
      Uri.parse("$_baseUrl/$route"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $_token"}
    );

    var data = jsonDecode(response.body);

    if(data is Map && data.containsKey("error")) {
      throw Exception(data);
    } else {
      print("Data: $data");

      return data;
    }
  }
}
