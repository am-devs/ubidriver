import 'dart:convert';
import 'package:driver_return/state.dart';
import 'package:http/http.dart' as http;

class ApiService implements Memento {
  static final _baseUrl = Uri.parse("http://192.168.1.189:8084/v1");
  String _token = "";

  bool get isLoggedIn => _token.isNotEmpty;
  
  Future<bool> validateToken() async {
    if (_token.isEmpty) {
      return false;
    }

    final data = await get<Map<String, dynamic>>("/user");

    if (data.isNotEmpty) {
      print("token is valid!");
      return true;
    } else {
      print("token is invalid!");
      _token = "";

      return false;
    }
  }

  Future<bool> authenticate(String username, String password) async {
    final body = jsonEncode({'username': username, 'password': password});

    print(body);

    var response = await http.post(
      Uri.parse("$_baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: body,
    ).timeout(const Duration(seconds: 10));

    Map<String, dynamic> data = jsonDecode(response.body);

    if(data.containsKey('error')) {
      print("Error $data");

      return false;
    } else {
      _token = data["client_secret"] as String;

      return true;
    }
  }

  void unauthenticated() {
    _token = "";
  }

  Future<T> get<T>(String route) async {
    var response = await http.get(
      _baseUrl.resolve(route),
      headers: {"Authorization": "Bearer $_token"}
    ).timeout(const Duration(seconds: 10));

    var data = jsonDecode(utf8.decode(response.bodyBytes));

    if(data is Map && data.containsKey("error")) {
      throw Exception(data);
    } else {
      print("Data ${data.runtimeType}");

      return data;
    }
  }

  Future<T> post<T>(String route, { Object? body }) async {
    var response = await http.post(
      _baseUrl.resolve(route),
      body: body != null ? jsonEncode(body) : null,
      headers: {"Authorization": "Bearer $_token", "Content-Type": "application/json"}
    ).timeout(const Duration(seconds: 10));

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
  
  @override
  void loadFromSnapshot(AppSnapshot snapshot) {
    _token = snapshot.data["token"] ?? "";
  }
  
  @override
  Map<String, dynamic> toJson() => {
    "token": _token
  };
}