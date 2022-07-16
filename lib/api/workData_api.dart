import 'dart:convert';
import 'package:mobile2/api/equipments_api.dart';
import 'package:mobile2/api/projects_api.dart';
import 'package:mobile2/api/user_api.dart';
import 'package:mobile2/api/workDone_api.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class WorkDatasApi {
  static Future<List<WorkData>> getWorkData(userId) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works');
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/v3/driver/' +
            userId);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List works = json.decode(response.body);
      return works
          .map((json) => WorkData.fromJson(json))
          // .where(
          //   (job) {
          //   //   return (job.driver?.userId == userId &&
          //   //       (job.status == 'created' || job.status == 'in progress'));
          //   // }).toList();

          //   return ((job.status == 'created' ||
          //       job.status == 'in progress' ||
          //       job.status == 'on going'));
          // }
          // )
          .toList();
    } else {
      throw Exception();
    }
  }

  static Future<bool> saveWorkData(
      Project project,
      Equipment equipment,
      String workDone,
      String startIndex,
      String endIndex,
      String hours,
      String comment,
      String driver,
      DateTime start,
      DateTime end,
      String sitework) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works');

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/mobileData');
    final response = await http.post(url, body: {
      "project": jsonEncode(project),
      "equipment": jsonEncode(equipment),
      "workDone": workDone,
      "startIndex": startIndex,
      "endIndex": endIndex,
      "startTime": start.toString(),
      "endTime": end.toString(),
      "rate": "500",
      "driver": driver,
      "status": "created",
      "duration": hours,
      "comment": comment,
      "siteWork": sitework
    });

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> startJob(String jobId, String startIndex) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works/start/' + jobId);
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/start/' +
            jobId);
    final response = await http.put(url, body: {"startIndex": startIndex});

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> endJob(String jobId, String endIndex, String duration,
      String tripsDone, String comment) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works/stop/' + jobId);
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/stop/' +
            jobId);
    final response = await http.put(url, body: {
      "endIndex": endIndex,
      "duration": duration == "" ? "5" : duration,
      "tripsDone": tripsDone == "" ? "0" : tripsDone,
      "comment": comment,
    });

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}

class WorkData {
  final WorkDone? workDone;
  final String jobId;
  final String status;
  final String targetTrips;
  final int startIndex;
  final int millage;
  final Project prj;
  final String createdOn;
  // final User? driver;
  final Equipment? equipment;
  final bool siteWork;
  final String dispatchDate;
  final String shift;

  const WorkData(
      {required this.workDone,
      required this.jobId,
      required this.status,
      required this.targetTrips,
      required this.startIndex,
      required this.millage,
      required this.prj,
      required this.createdOn,
      // required this.driver,
      required this.equipment,
      required this.siteWork,
      required this.dispatchDate,
      required this.shift});

  static WorkData fromJson(Map<String, dynamic> json) => WorkData(
      workDone: WorkDone?.fromJson(json['workDone']),
      jobId: json['_id'],
      status: json['status'],
      targetTrips: json['targetTrips'],
      startIndex: json['startIndex'],
      millage: json['millage'],
      prj: Project.fromJson(
        json['project'],
      ),
      createdOn: DateFormat('d.MM.y')
          .format(DateTime.parse(json['createdOn']).toLocal())
          .toString(),
      equipment: Equipment.fromJson(json['equipment']),
      siteWork: json['siteWork'],
      dispatchDate: DateFormat('d.MM.y')
          .format(DateTime.parse(json['dispatchDate']).toLocal())
          .toString(),
      shift: json['shift']
      // driver: User?.fromJson(json['driver']),
      );
}
