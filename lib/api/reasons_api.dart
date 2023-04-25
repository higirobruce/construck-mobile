import 'dart:convert';

import 'package:http/http.dart' as http;

class ReasonApi {
  static Future<List<Reason>> getReasonSuggestion(String query) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/reasons/');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url =
        Uri.parse('https://construck-backend-playgroud.herokuapp.com/reasons/');
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List reasonList = json.decode(response.body);

      return reasonList
          .map((json) => Reason.fromJson(json))
          // .where((work) {
          //   final descLower = work.description.toLowerCase();
          //   final queryLower = query.toLowerCase();

          //   return descLower.contains(queryLower);
          // })
          .toList();
    } else {
      throw Exception();
    }
  }
}

class Reason {
  final String description;
  final String descriptionRw;
  final String reasonId;

  const Reason({
    required this.description,
    required this.descriptionRw,
    required this.reasonId,
  });

  static Reason fromJson(Map<String, dynamic> json) => Reason(
      description: json['description'],
      reasonId: json['_id'],
      descriptionRw: json['descriptionRw']);
}
