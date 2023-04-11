// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mobile2/api/workData_api.dart';
import 'package:intl/intl.dart';
import 'package:mobile2/screens/dailyDetails.dart';

const double GLOBAL_PADDING = 15.0;

class DailySummary extends StatefulWidget {
  final int? month;
  final int? year;
  final String? projectName;
  final String? category;
  final VoidCallback refreshMonthlSummary;
  const DailySummary(this.month, this.year, this.projectName, this.category,
      this.refreshMonthlSummary,
      {Key? key})
      : super(key: key);

  @override
  State<DailySummary> createState() => _DailySummaryState();
}

class _DailySummaryState extends State<DailySummary> {
  List dailySummary = List.empty();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.category == 'validated') {
      getValidatedSummary();
    } else if (widget.category == 'not validated') {
      getNonValidatedSummary();
    }
  }

  void getNonValidatedSummary() {
    WorkDatasApi.getDailyNonValidatedSummary(
            widget.projectName, widget.month, widget.year)
        .then((value) => setState(() => {dailySummary = value}));
  }

  void getValidatedSummary() {
    WorkDatasApi.getDailyValidatedSummary(
            widget.projectName, widget.month, widget.year)
        .then((value) => setState(() => {dailySummary = value}));
  }

  void refresh() {
    getValidatedSummary();
    getNonValidatedSummary();
    widget.refreshMonthlSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () => {Navigator.pop(context)},
                  ),
                ),
                buildTopNav(context),
              ],
            ),
            Expanded(child: buildDailyData(dailySummary))
          ],
        ),
      ),
    );
  }

  buildTopNav(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Daily Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDailyData(List dailySummary) => Padding(
        padding: const EdgeInsets.all(GLOBAL_PADDING),
        child: dailySummary.isEmpty
            ? Center(
                child: SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).accentColor,
                    strokeWidth: 1.5,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final dailyData = dailySummary[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: index == 0
                          ? const Border() // This will create no border for the first item
                          : Border(
                              top: BorderSide(
                                  width: 1,
                                  color: Colors.grey[
                                      300]!)), // This will create top borders for the rest
                    ),
                    child: DailySummaryTile(
                      dailyData: dailyData,
                      category: widget.category,
                      month: widget.month,
                      year: widget.year,
                      projectName: widget.projectName,
                      refresh: refresh,
                    ),
                  );
                },
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: dailySummary.length,
              ),
      );
}

class DailySummaryTile extends StatelessWidget {
  const DailySummaryTile({
    Key? key,
    required this.dailyData,
    required this.category,
    required this.month,
    required this.year,
    required this.projectName,
    required this.refresh,
  }) : super(key: key);

  final dailyData;
  final category;
  final month;
  final year;
  final projectName;
  final VoidCallback refresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GLOBAL_PADDING / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  DateFormat('yyyy-MMM-dd')
                      .format(DateTime.parse(dailyData['id']['date'])),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700])),
              Text('RWF ' + dailyData['totalRevenue'],
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500])),
            ],
          ),
          Row(
            children: [
              // category == 'not validated'
              //     ? Container(
              //         // margin: EdgeInsets.all(10.0),
              //         padding: EdgeInsets.all(5.0),
              //         decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(5),
              //             color: Colors.white,
              //             border: Border.all(color: Colors.grey[300]!)),
              //         child: GestureDetector(
              //           onTap: () => {},
              //           child: Text(
              //             'Approve',
              //             style:
              //                 TextStyle(fontSize: 12, color: Colors.green[400]),
              //           ),
              //         ),
              //       )
              //     : Container(),
              // SizedBox(width: 5),
              // category == 'not validated'
              //     ? Container(
              //         // margin: EdgeInsets.all(10.0),
              //         padding: EdgeInsets.all(5.0),
              //         decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(5),
              //             color: Colors.white,
              //             border: Border.all(color: Colors.grey[300]!)),
              //         child: GestureDetector(
              //           onTap: () => {},
              //           child: Text(
              //             'Reject',
              //             style: TextStyle(
              //                 fontSize: 12,
              //                 color: Theme.of(context).accentColor),
              //           ),
              //         ),
              //       )
              //     : Container(),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.grey[400],
                  size: 15,
                ),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyDetails(
                          dailyData['id']['date'],
                          projectName,
                          category,
                          refresh),
                    ),
                  ),
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
