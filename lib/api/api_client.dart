import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient(this.baseUrl);
  final String baseUrl;

  Future<Map<String, dynamic>> signup(String email, String pass) async {
    final res = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': pass}),
    );
    return _process(res);
  }

  Future<Map<String, dynamic>> login(String email, String pass) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': pass}),
    );
    return _process(res);
  }

  Map<String, dynamic> _process(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
  }
}
