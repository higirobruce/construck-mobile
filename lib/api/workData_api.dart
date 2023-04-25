import 'dart:convert';
import 'package:mobile2/api/equipments_api.dart';
import 'package:mobile2/api/projects_api.dart';
import 'package:mobile2/api/workDone_api.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
Codec<String, String> stringToBase64 = utf8.fuse(base64);
String encoded = stringToBase64.encode(credentials);

class WorkDatasApi {
  static Future<List<WorkData>> getWorkData(userId) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works');

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/v3/driver/' +
            userId);
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

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

  static Future getValidatedSummary(projectName) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works');
    String credentials = "sh4b1k4:@9T4Tr73%62l!iHqdhWv";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/monthlyValidatedRevenues/' +
            projectName);
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List monthlySummary = json.decode(response.body);

      return monthlySummary.map((json) => json).toList();
    } else {
      throw Exception();
    }
  }

  static Future getNonValidatedSummary(projectName) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works');

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/monthlyNonValidatedRevenues/' +
            projectName);
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List monthlySummary = json.decode(response.body);

      return monthlySummary.map((json) => json).toList();
    } else {
      throw Exception();
    }
  }

  static Future getDailyValidatedSummary(projectName, month, year) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works');

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/dailyValidatedRevenues/' +
            projectName +
            '?month=' +
            month.toString() +
            '&year=' +
            year.toString());
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List dailySummary = json.decode(response.body);

      return dailySummary.map((json) => json).toList();
    } else {
      throw Exception();
    }
  }

  static Future getDailyNonValidatedSummary(projectName, month, year) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works');

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/dailyNonValidatedRevenues/' +
            projectName +
            '?month=' +
            month.toString() +
            '&year=' +
            year.toString());
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List dailySummary = json.decode(response.body);

      return dailySummary.map((json) => json).toList();
    } else {
      throw Exception();
    }
  }

  static Future getDailyListValidated(projectName, transactionDate) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works');

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/validatedByDay/' +
            projectName +
            '?transactionDate=' +
            transactionDate);
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List dailySummary = json.decode(response.body);

      return dailySummary.map((json) => json).toList();
    } else {
      throw Exception();
    }
  }

  static Future getDailyListNonValidated(projectName, transactionDate) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works');

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/nonValidatedByDay/' +
            projectName +
            '?transactionDate=' +
            transactionDate);

    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List dailySummary = json.decode(response.body);

      return dailySummary.map((json) => json).toList();
    } else {
      throw Exception();
    }
  }

  static Future getMonthltReleased(projectName) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works');

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/projects/releasedRevenue/' +
            projectName);
    final response =
        await http.get(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 200) {
      final List monthlySummary = json.decode(response.body);

      return monthlySummary.map((json) => json).toList();
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

  static Future<bool> startJob(String jobId, String startIndex,
      String startedBy, String postingDate) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works/start/' + jobId);

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/start/' +
            jobId);
    final response = await http.put(url, body: {
      "startIndex": startIndex,
      "startedBy": startedBy,
      "postingDate": postingDate
    }, headers: {
      "Authorization": 'Basic ' + encoded
    });

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> endJob(
      String jobId,
      String endIndex,
      String duration,
      String tripsDone,
      String comment,
      String stoppedBy,
      String postingDate) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works/stop/' + jobId);
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/stop/' +
            jobId);
    final response = await http.put(url, body: {
      "endIndex": endIndex,
      "duration": duration == "" ? "5" : duration,
      "tripsDone": tripsDone == "" ? "0" : tripsDone,
      "comment": comment,
      "stoppedBy": stoppedBy,
      "postingDate": postingDate
    }, headers: {
      "Authorization": 'Basic ' + encoded
    });

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> releaseMonthlyCost(projectName, month, year) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works/stop/' + jobId);
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/releaseValidated/' +
            projectName +
            '?month=' +
            month.toString() +
            '&year=' +
            year.toString());
    final response =
        await http.put(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode != 404) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> rejectMonthlyCost(
      projectName, month, year, reason) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works/stop/' + jobId);
    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/releaseValidated/' +
            projectName +
            '?month=' +
            month.toString() +
            '&year=' +
            year.toString());
    final response = await http.put(url,
        headers: {"Authorization": 'Basic ' + encoded},
        body: {"reason": reason});

    if (response.statusCode != 404) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> approve(String jobId) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works/start/' + jobId);

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/approve/' +
            jobId);
    final response =
        await http.put(url, headers: {"Authorization": 'Basic ' + encoded});

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> reject(String jobId, reason) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works/start/' + jobId);

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/reject/' +
            jobId);
    final response = await http.put(url,
        headers: {"Authorization": 'Basic ' + encoded},
        body: {"reasonForRejection": reason});

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> approveDailySiteWork(
      String jobId,
      String postingDate,
      String approvedRevenue,
      String approvedDuration,
      String approvedExpenditure) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works/start/' + jobId);

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/approveDailyWork/' +
            jobId);
    final response = await http.put(url, headers: {
      "Authorization": 'Basic ' + encoded
    }, body: {
      "postingDate": postingDate,
      // "approvedBy":"",
      "approvedRevenue": approvedRevenue,
      "approvedDuration": approvedDuration,
      "approvedExpenditure": approvedExpenditure,
    });

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> rejectDailySiteWork(
      String jobId,
      String postingDate,
      String rejectedRevenue,
      String rejectedDuration,
      String rejectedExpenditure,
      String reason) async {
    // final url = Uri.parse('https://construck-backend-playgroud.herokuapp.com/works/start/' + jobId);

    final url = Uri.parse(
        'https://construck-backend-playgroud.herokuapp.com/works/rejectDailyWork/' +
            jobId);
    final response = await http.put(url, headers: {
      "Authorization": 'Basic ' + encoded
    }, body: {
      "postingDate": postingDate,
      // "approvedBy":"",
      "rejectedRevenue": rejectedRevenue,
      "rejectedDuration": rejectedDuration,
      "rejectedExpenditure": rejectedExpenditure,
      "reason": reason
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
  final double startIndex;
  final double millage;
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
      workDone: WorkDone.fromJson(json['workDone']),
      jobId: json['_id'],
      status: json['status'],
      targetTrips: json['targetTrips'],
      startIndex: double.parse(json['startIndex']),
      millage: double.parse(json['millage']),
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
