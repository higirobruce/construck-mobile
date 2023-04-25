import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile2/api/equipmentTypes.dart';

class RequestsApi {
  static Future<List<EquipmentRequest>> getRequestsSuggestions() async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/projects');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/requests/');
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List requests = json.decode(response.body);

      return requests.map((json) => EquipmentRequest.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future saveRequest(
      String referenceNumber,
      String equipmentType,
      String quantity,
      String startDate,
      String endDate,
      String shift,
      String project) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/projects');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/requests/');
    final response = await http.post(url, headers: {
      "Authorization": 'Basic ' + encoded
    }, body: {
      "project": project,
      "referenceNumber": referenceNumber,
      "equipmentType": equipmentType,
      "quantity": quantity,
      "startDate": startDate,
      "endDate": endDate,
      "shift": shift
    });

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}

class EquipmentRequest {
  final project;
  final EquipmentType equipmentType;
  final quantity;
  final startDate;
  final endDate;
  final shift;
  final status;

  final String referenceNumber;

  const EquipmentRequest({
    required this.project,
    required this.referenceNumber,
    required this.equipmentType,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.shift,
    required this.status,
  });

  Map toJson() => {
        "project": project,
        "referenceNumber": referenceNumber,
        "equipmentType": equipmentType,
        "quantity": quantity,
        "startDate": startDate,
        "endDate": endDate,
        "shift": shift
      };

  static EquipmentRequest fromJson(Map<String, dynamic> json) =>
      EquipmentRequest(
        project: json['project'],
        referenceNumber: json['referenceNumber'],
        equipmentType: EquipmentType.fromJson(json['equipmentType']),
        endDate: json['endDate'],
        quantity: json['quantity'],
        startDate: json['startDate'],
        shift: json['shift'],
        status: json['status'],
      );
}
