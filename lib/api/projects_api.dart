import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ProjectsApi {
  static FutureOr<Iterable<Project>> getUserSuggestions(String query) async {
    // final url = Uri.parse('http://localhost:9000/projects');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse('http://localhost:9000/projects/v2');
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List projects = json.decode(response.body);

      return projects.map((json) => Project.fromJson(json)).where((project) {
        final nameLower = project.prjDescription.toLowerCase();
        final queryLower = query.toLowerCase();

        return nameLower.contains(queryLower);
      }).toList();
    } else {
      throw Exception();
    }
  }
}

class Project {
  final String prjDescription;
  final String prjId;
  final String? customer;

  const Project({
    required this.prjDescription,
    required this.prjId,
    required this.customer,
  });

  Map toJson() =>
      {'prjDescription': prjDescription, '_id': prjId, 'customer': customer};

  static Project fromJson(Map<String, dynamic> json) => Project(
      prjDescription: json['prjDescription'],
      prjId: json['_id'],
      customer: json['customer']);
}
