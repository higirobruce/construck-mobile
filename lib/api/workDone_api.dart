import 'dart:convert';

import 'package:http/http.dart' as http;

class WorkDoneApi {
  static Future<List<WorkDone>> getWorkDoneSuggestion(String query) async {
    // final url = Uri.parse('https://construck-backend.herokuapp.com/jobTypes');
    final url = Uri.parse('https://construck-backend.herokuapp.com/jobTypes');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List workList = json.decode(response.body);

      return workList.map((json) => WorkDone.fromJson(json)).where((work) {
        final descLower = work.jobDescription.toLowerCase();
        final queryLower = query.toLowerCase();

        return descLower.contains(queryLower);
      }).toList();
    } else {
      throw Exception();
    }
  }
}

class WorkDone {
  final String jobDescription;
  final String jobId;

  const WorkDone({
    required this.jobDescription,
    required this.jobId,
  });

  static WorkDone fromJson(Map<String, dynamic> json) =>
      WorkDone(jobDescription: json['jobDescription'], jobId: json['_id']);
}
