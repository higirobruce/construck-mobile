import 'dart:convert';

import 'package:http/http.dart' as http;

class DowntimeApi {
  static Future<Downtime> getDowntimeAnalytics(String startDate, String endDate,
      String? owner, String customer, String project) async {
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/downtimes/getAnalytics');
    final response = await http.post(url, body: {
      "startDate": startDate,
      "endDate": endDate,
      "owner": owner,
      "customer": customer,
      "project": project
    }, headers: {
      "Authorization": 'Basic ' + encoded
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Downtime.fromJson(data);
    } else {
      throw Exception();
    }
  }
}

class Downtime {
  final double avgInWorkshop;
  final double avgFromWorkshop;
  final double avgHours;

  const Downtime({
    required this.avgFromWorkshop,
    required this.avgInWorkshop,
    required this.avgHours,
  });

  static Downtime fromJson(Map<String, dynamic> json) => Downtime(
        avgFromWorkshop: double.parse(json['avgFromWorkshop']),
        avgInWorkshop: double.parse(json['avgInWorkshop']),
        avgHours: double.parse(json['avgHours']),
      );
}
