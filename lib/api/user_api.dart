import 'dart:convert';

import 'package:http/http.dart' as http;

class UserApi {
  static Future<List<User>> getUsers(String query) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/employees');
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/employees');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List users = json.decode(response.body);

      return users.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future login(String password, String phone) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/employees');
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/employees/login');
    final response =
        await http.post(url, body: {"password": password, "phone": phone});

    if (response.statusCode == 200) {
      final obj = json.decode(response.body);

      return {"allowed": true, "employee": obj['employee']};
    } else {
      return {"allowed": false};
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
