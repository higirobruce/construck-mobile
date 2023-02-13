import 'dart:convert';

import 'package:http/http.dart' as http;

class RevenueAnalyticsApi {
  DateTime currentTime = DateTime.now();

  static Future<RevenueAnalytics> getAnalytics(String startDate, String endDate,
      String? owner, String customer, String project) async {
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'https://construck-backend-live.herokuapp.com/works/getAnalytics');
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
      return RevenueAnalytics.fromJson(data);
    } else {
      throw Exception();
    }
  }
}

class RevenueAnalytics {
  final double totalRevenue;
  final double projectedRevenue;
  final double totalDays;

  const RevenueAnalytics(
      {required this.totalRevenue,
      required this.projectedRevenue,
      required this.totalDays});

  static RevenueAnalytics fromJson(Map<String, dynamic> json) =>
      RevenueAnalytics(
        totalRevenue: double.parse(json['totalRevenue']),
        projectedRevenue: double.parse(json['projectedRevenue']),
        totalDays: double.parse(json['totalDays']),
      );
}
