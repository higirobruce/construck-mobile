import 'dart:convert';

import 'package:http/http.dart' as http;

class EquipmentsApi {
  static Future<List<Equipment>> getEquipmentSuggestions(String query) async {
    // final url = Uri.parse('https://construck-backend.herokuapp.com/equipments');
    final url =
        Uri.parse('https://construck-backend.herokuapp.com/equipments/v2');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List equipments = json.decode(response.body);

      return equipments
          .map((json) => Equipment.fromJson(json))
          .where((equipment) {
        final plateLower = equipment.plateNumber.toLowerCase();
        final queryLower = query.toLowerCase();

        return plateLower.contains(queryLower);
      }).toList();
    } else {
      throw Exception();
    }
  }

  static Future<List<Equipment>> getLowbedSuggestions(String query) async {
    // final url = Uri.parse('https://construck-backend.herokuapp.com/equipments');
    final url =
        Uri.parse('https://construck-backend.herokuapp.com/equipments/v2');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List equipments = json.decode(response.body);

      return equipments
          .map((json) => Equipment.fromJson(json))
          .where((equipment) {
        final plateLower = equipment.plateNumber.toLowerCase();
        final queryLower = query.toLowerCase();
        final type = equipment.eqDescription;

        return plateLower.contains(queryLower) && type == "TRACTOR HEAD";
      }).toList();
    } else {
      throw Exception();
    }
  }
}

class Equipment {
  final String plateNumber;
  final String equipmentId;
  final String eqDescription;
  final String eqType;

  const Equipment(
      {required this.plateNumber,
      required this.equipmentId,
      required this.eqDescription,
      required this.eqType});

  Map toJson() => {'plateNumber': plateNumber, '_id': equipmentId};
  static Equipment fromJson(Map<String, dynamic> json) => Equipment(
      plateNumber: json['plateNumber'],
      equipmentId: json['_id'],
      eqDescription: json['eqDescription'],
      eqType: json['eqtype']);
}
