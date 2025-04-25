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
      headers: {"Authorization": "Bearer $_token"}
    );

    var data = jsonDecode(response.body);

    if(data is Map && data.containsKey("error")) {
      throw Exception(data);
    } else {
      print("Data: $data");

      return data;
    }
  }

  Future<T> post<T>(String route, { Object? body }) async {
    var response = await http.post(
      Uri.parse("$_baseUrl/$route"),
      body: body != null ? jsonEncode(body) : null,
      headers: {"Authorization": "Bearer $_token", "Content-Type": "application/json"}
    );

    print(jsonEncode(body));

    // Empty error response
    if (response.bodyBytes.isEmpty && response.statusCode > 400) {
      throw Exception("No se pudo postear nada");
    }

    print(response.body);

    var data = jsonDecode(response.body);

    if(response.statusCode >= 400 || (data is Map && data.containsKey("error"))) {
      throw Exception(data);
    } else {
      print("Data: ${response.body}");

      return data as T;
    }
  }
}