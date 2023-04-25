import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class EquipmentTypesApi {
  static Future<List<EquipmentType>> getEquipmentTypes() async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/projects');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/equipmentTypes');
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List equipmentTypes = json.decode(response.body);

      print(response.body.toString());

      return equipmentTypes
          .map((json) => EquipmentType.fromJson(json))
          .toList();
    } else {
      throw Exception();
    }
  }
}

class EquipmentType {
  final String description;
  final String id;

  const EquipmentType({
    required this.description,
    required this.id,
  });

  Map toJson() => {'description': description, 'id': id};

  static EquipmentType fromJson(Map<String, dynamic> json) =>
      EquipmentType(description: json['description'], id: json['_id']);
}
