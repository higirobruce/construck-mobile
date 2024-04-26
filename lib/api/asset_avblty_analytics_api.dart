import 'dart:convert';

import 'package:http/http.dart' as http;

class AssetAvbltyApi {
  static Future<AssetAvblty> getAssetAnalytics(String startDate, String endDate,
      String? owner, String customer, String project) async {
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded =
        stringToBase64.encode(credentials); // dXNlcm5hbWU6cGFzc3dvcmQ=

    final url = Uri.parse(
        'http://localhost:9000/assetAvailability/getAnalytics');
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
      return AssetAvblty.fromJson(data);
    } else {
      throw Exception();
    }
  }
}

class AssetAvblty {
  final double assetAvailability;
  final double assetUtilization;

  const AssetAvblty(
      {required this.assetAvailability, required this.assetUtilization});

  static AssetAvblty fromJson(Map<String, dynamic> json) => AssetAvblty(
        assetAvailability: double.parse(json['assetAvailability']),
        assetUtilization: double.parse(json['assetUtilization']),
      );
}
