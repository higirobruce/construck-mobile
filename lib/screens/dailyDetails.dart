// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mobile2/api/workData_api.dart';
import 'package:intl/intl.dart';
import 'package:mobile2/components/dailyTile.dart';

const double GLOBAL_PADDING = 15.0;

class DailyDetails extends StatefulWidget {
  final String? projectName;
  final String? category;
  final String? transactionDate;
  final VoidCallback refresh;
  const DailyDetails(
      this.transactionDate, this.projectName, this.category, this.refresh,
      {Key? key})
      : super(key: key);

  @override
  State<DailyDetails> createState() => _DailyDetailsState();
}

class _DailyDetailsState extends State<DailyDetails> {
  List dailydetailsList = List.empty();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.category == 'validated') {
      WorkDatasApi.getDailyListValidated(
              widget.projectName, widget.transactionDate)
          .then((value) => setState(() => {dailydetailsList = value}));
    } else if (widget.category == 'not validated') {
      WorkDatasApi.getDailyListNonValidated(
              widget.projectName, widget.transactionDate)
          .then((value) => setState(() => {dailydetailsList = value}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
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
            Expanded(child: buildDailyList(dailydetailsList))
          ],
        )),
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
              "Daily transactions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDailyList(List dailyDetailsList) => Padding(
        padding: const EdgeInsets.all(GLOBAL_PADDING),
        child: dailyDetailsList.isEmpty
            ? Center(
                child: SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                    strokeWidth: 1.5,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final dailyData = dailyDetailsList[index];
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
                    child: DailyTile(
                        dailyData: dailyData,
                        category: widget.category,
                        refresh: widget.refresh),
                  );
                },
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: dailyDetailsList.length,
              ),
      );
}
