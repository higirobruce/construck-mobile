import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobile2/api/equipmentTypes.dart';

class RequestsApi {
  static Future<List<EquipmentRequest>> getRequestsSuggestions() async {
    // final url = Uri.parse('http://localhost:9000/projects');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'http://localhost:9000/requests/');
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List requests = json.decode(response.body);

      print(requests);
      return requests.map((json) => EquipmentRequest.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<EquipmentRequest>> getMyRequests(String? owner) async {
    // final url = Uri.parse('http://localhost:9000/projects');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'http://localhost:9000/requests/byOwner/' +
            owner!);
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List requests = json.decode(response.body);
      return requests.map((json) => EquipmentRequest.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<RequestSummary>> getAggregatedRequests(
      String status) async {
    // final url = Uri.parse('http://localhost:9000/projects');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'http://localhost:9000/requests/aggregated/' +
            status);
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List requests = json.decode(response.body);

      return requests.map((json) => RequestSummary.fromJson(json)).toList();
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
      String project,
      String owner,
      String workToBeDone,
      String tripsToBeMade,
      String tripFrom,
      String tripTo) async {
    // final url = Uri.parse('http://localhost:9000/projects');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'http://localhost:9000/requests/');
    final response = await http.post(url, headers: {
      "Authorization": 'Basic ' + encoded
    }, body: {
      "project": project,
      "referenceNumber": referenceNumber,
      "equipmentType": equipmentType,
      "quantity": quantity,
      "startDate": startDate,
      "endDate": endDate,
      "shift": shift,
      "owner": owner,
      "workToBeDone": workToBeDone,
      "tripsToBeMade": tripsToBeMade,
      "tripFrom": tripFrom,
      "tripTo": tripTo
    });

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future assignQuantity(String eqId, String quantity) async {
    // final url = Uri.parse('http://localhost:9000/projects');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'http://localhost:9000/requests/assignQuantity/' +
            eqId);
    final response = await http.put(url, headers: {
      "Authorization": 'Basic ' + encoded
    }, body: {
      "quantity": quantity,
    });

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}

class EquipmentRequest {
  final id;
  final project;
  final EquipmentType equipmentType;
  final quantity;
  final startDate;
  final endDate;
  final shift;
  final status;
  final approvedQuantity;
  final workToBeDone;
  final tripsToBeMade;
  final tripTo;
  final tripFrom;

  final String referenceNumber;

  const EquipmentRequest(
      {required this.id,
      required this.project,
      required this.referenceNumber,
      required this.equipmentType,
      required this.quantity,
      required this.startDate,
      required this.endDate,
      required this.shift,
      required this.status,
      required this.approvedQuantity,
      required this.workToBeDone,
      required this.tripsToBeMade,
      required this.tripTo,
      required this.tripFrom});

  Map toJson() => {
        "id": id,
        "project": project,
        "referenceNumber": referenceNumber,
        "equipmentType": equipmentType,
        "quantity": quantity,
        "startDate": startDate,
        "endDate": endDate,
        "shift": shift,
        "workToBeDone": workToBeDone,
        "tripsToBeMade": tripsToBeMade,
        "tripTo": tripTo,
        "tripFrom": tripFrom
      };

  static EquipmentRequest fromJson(Map<String, dynamic> json) =>
      EquipmentRequest(
          id: json['_id'],
          project: json['project'],
          referenceNumber: json['referenceNumber'],
          equipmentType: EquipmentType.fromJson(json['equipmentType']),
          endDate: json['endDate'],
          quantity: json['quantity'],
          startDate: json['startDate'],
          shift: json['shift'],
          status: json['status'],
          approvedQuantity: json['approvedQuantity'],
          workToBeDone: json['workToBeDone'],
          tripsToBeMade: json['tripsToBeMade'],
          tripFrom: json['tripFrom'],
          tripTo: json['tripTo']);
}

class RequestSummary {
  final project;
  final EquipmentType equipmentType;
  final quantity;
  final date;

  const RequestSummary(
      {required this.project,
      required this.equipmentType,
      required this.quantity,
      required this.date});

  Map toJson() => {
        "project": project,
        "equipmentType": equipmentType,
        "quantity": quantity,
        "date": date,
      };

  static RequestSummary fromJson(Map<String, dynamic> json) => RequestSummary(
      project: json['_id']['project'],
      equipmentType: EquipmentType.fromJson(json['equipmentType']),
      quantity: json['total'],
      date: json['_id']['date']);
}
