import 'dart:convert';

import 'package:http/http.dart' as http;

class UserApi {
  static Future<List<User>> getUsers(String query) async {
    // final url = Uri.parse('http://localhost:9000/employees');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'http://localhost:9000/employees');
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List users = json.decode(response.body);

      return users.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future login(String password, String phone) async {
    // final url = Uri.parse('http://localhost:9000/employees');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'http://localhost:9000/employees/login');
    final response = await http.post(url,
        body: {"password": password, "phone": phone},
        headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final obj = json.decode(response.body);
      return {
        "allowed": true,
        "employee": obj['employee'],
        "userType": obj['userType']
      };
    } else {
      return {"allowed": false};
    }
  }

  static Future updateToken(String userId, String? token) async {
    // final url = Uri.parse('http://localhost:9000/employees');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'http://localhost:9000/employees/token/' +
            userId);
    final response = await http.put(url,
        body: {"token": token}, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final obj = json.decode(response.body);

      return obj;
    } else {
      return {"message": "operation failed"};
    }
  }
}

class User {
  final String userId;
  final String firstName;
  final String lastName;

  const User({
    required this.firstName,
    required this.lastName,
    required this.userId,
  });

  static User fromJson(Map<String, dynamic> json) => User(
        firstName: json['firstName'],
        lastName: json['lastName'],
        userId: json['_id'],
      );
}
