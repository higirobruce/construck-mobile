// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class DailySummary extends StatefulWidget {
  final int? month;
  final int? year;
  final String? projectName;
  const DailySummary(this.month, this.year, this.projectName, {Key? key})
      : super(key: key);

  @override
  State<DailySummary> createState() => _DailySummaryState();
}

class _DailySummaryState extends State<DailySummary> {
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
            Text(widget.month.toString()),
            Text(widget.year.toString()),
            Text(widget.projectName!)
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
              "Shabika App.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
