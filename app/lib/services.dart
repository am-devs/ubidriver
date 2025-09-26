import 'dart:convert';
import 'dart:io';
import 'package:gdd/state.dart';
import 'package:geolocator/geolocator.dart';

class ApiService implements Memento {
  static final _baseUrl = Uri.parse("https://chofer.iancarina.com.ve/v1");
  // static final _baseUrl = "http://192.168.1.189:8084/v1";

  String _token = "";
  late HttpClient _httpClient;

  ApiService() {
    _httpClient = HttpClient();

    _httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };
  }

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

    try {
      final request = await _httpClient.postUrl(Uri.parse("$_baseUrl/login"));
      request.headers.set('Content-Type', 'application/json');
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      Map<String, dynamic> data = jsonDecode(responseBody);

      if(data.containsKey('error')) {
        print("Error $data");
        return false;
      } else {
        _token = data["client_secret"] as String;
        return true;
      }
    } catch (e) {
      print("Error en authenticate: $e");
      return false;
    }
  }

  void unauthenticated() {
    _token = "";
  }

  Future<T> get<T>(String route) async {
    try {
      final request = await _httpClient.getUrl(Uri.parse("$_baseUrl$route"));
      request.headers.set('Authorization', 'Bearer $_token');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      var data = jsonDecode(responseBody);

      if(data is Map && data.containsKey("error")) {
        throw Exception(data);
      } else {
        print("Data ${data.runtimeType}");
        return data;
      }
    } catch (e) {
      print("Error en get: $e");
      rethrow;
    }
  }

  Future<T> post<T>(String route, { Object? body }) async {
    HttpClientRequest? request;

    try {
      request = await _httpClient.postUrl(Uri.parse("$_baseUrl$route"));
      request.headers.set('Authorization', 'Bearer $_token');
      request.headers.set('Content-Type', 'application/json');

      if (body != null) {
        request.write(jsonEncode(body));
      }

      print(jsonEncode(body));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      // Empty error response
      if (responseBody.isEmpty && response.statusCode >= 400) {
        throw Exception("No se pudo postear nada");
      }

      print(responseBody);

      var data = jsonDecode(responseBody);

      if(response.statusCode >= 400 || (data is Map && data.containsKey("error"))) {
        throw Exception(data);
      } else {
        print("Data: $responseBody");
        return data as T;
      }
    } catch (e) {
      print("Error en post: $e");
      rethrow;
    } finally {
      if (request != null) {
        await request.close();
      }
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

Future<Position> getPosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
