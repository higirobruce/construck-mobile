// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:mobile2/api/workData_api.dart';
import 'package:mobile2/screens/dailySummary.dart';
import 'package:mobile2/screens/mainScreen.dart';

const GLOBAL_PADDING = 15.0;

class MonthlyTile extends StatefulWidget {
  MonthlyTile({
    Key? key,
    required this.monthlyData,
    required this.widget,
    required this.category,
    required this.refreshMonthlySummary,
    required this.refreshValidated,
    required this.refreshNonValidated,
    required this.project,
  }) : super(key: key);

  final monthlyData;
  final category;
  final project;
  final Function refreshMonthlySummary;
  final Function refreshValidated;
  final Function refreshNonValidated;
  final MainScreen widget;

  @override
  State<MonthlyTile> createState() => _MonthlyTileState();
}

class _MonthlyTileState extends State<MonthlyTile> {
  bool approving = false;
  bool rejecting = false;
  bool done = false;
  final TextEditingController _reasonController = TextEditingController();

  void rejectModalBottomSheet(context, projectName, month, year) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: GLOBAL_PADDING),
            child: new Wrap(
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reason for rejection'),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.only(left: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: TextFormField(
                            autofocus: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            controller: _reasonController,
                          ),
                        )
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                      onPressed: () {
                        if (_reasonController.text.isNotEmpty &&
                            _reasonController.text != 'No reason was given!') {
                          rejectMonthlyCost(
                              projectName, month, year, _reasonController.text);
                          Navigator.pop(context);
                        } else {
                          _reasonController.text = 'No reason was given!';
                          print('You cn not');
                        }
                      },
                      child: Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50), // NEW
                      )),
                ),
              ],
            ),
          );
        });
  }

  void releaseModalBottomSheet(context, projectName, month, year) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey[200],
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (BuildContext bc) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: GLOBAL_PADDING),
            child: new Wrap(
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: ElevatedButton(
                      onPressed: () {
                        releaseCost(projectName, month, year);

                        Navigator.pop(context);
                      },
                      child: Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50), // NEW
                      )),
                ),
              ],
            ),
          );
        });
  }

  void releaseCost(projectName, month, year) {
    return setState(() => {
          approving = true,
          WorkDatasApi.releaseMonthlyCost(projectName, month, year)
              .then((value) => {
                    widget.refreshValidated(),
                    setState(() {
                      approving = false;
                      done = true;
                    })
                  })
        });
  }

  void rejectMonthlyCost(projectName, month, year, String reason) {
    return setState(() => {
          rejecting = true,
          WorkDatasApi.rejectMonthlyCost(projectName, month, year, reason)
              .then((value) => {
                    widget.refreshValidated(),
                    setState(() {
                      rejecting = false;
                      done = true;
                    })
                  })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(GLOBAL_PADDING / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.monthlyData['monthYear'],
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700])),
              Text('RWF ' + widget.monthlyData['totalRevenue'],
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500])),
            ],
          ),
          done
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Done',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                )
              : Row(
                  children: [
                    widget.category == 'validated'
                        ? approving
                            ? Container(
                                // margin: EdgeInsets.all(10.0),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                ),
                                // border: Border.all(color: Colors.grey[300]!)),
                                child: GestureDetector(
                                  onTap: () => {},
                                  child: SizedBox(
                                    height: 10,
                                    width: 10,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).accentColor,
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                // margin: EdgeInsets.all(10.0),
                                padding: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.grey[300]!)),
                                child: GestureDetector(
                                  onTap: () => {
                                    releaseModalBottomSheet(
                                      context,
                                      widget.project,
                                      widget.monthlyData['id']['month'],
                                      widget.monthlyData['id']['year'],
                                    )
                                  },
                                  child: Text(
                                    'Release',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.green[400]),
                                  ),
                                ),
                              )
                        : Container(),
                    SizedBox(width: 5),
                    widget.category == 'validated'
                        ? rejecting
                            ? Container(
                                // margin: EdgeInsets.all(10.0),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                ),
                                // border: Border.all(color: Colors.grey[300]!)),
                                child: GestureDetector(
                                  onTap: () => {},
                                  child: SizedBox(
                                    height: 10,
                                    width: 10,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).accentColor,
                                      strokeWidth: 1.5,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                // margin: EdgeInsets.all(10.0),
                                padding: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.grey[300]!)),
                                child: GestureDetector(
                                  onTap: () => {
                                    rejectModalBottomSheet(
                                      context,
                                      widget.project,
                                      widget.monthlyData['id']['month'],
                                      widget.monthlyData['id']['year'],
                                    )
                                  },
                                  child: Text(
                                    'Reject',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).accentColor),
                                  ),
                                ),
                              )
                        : Container(),
                    widget.category != 'released'
                        ? IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.grey[400],
                              size: 15,
                            ),
                            onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DailySummary(
                                      widget.monthlyData['id']['month'],
                                      widget.monthlyData['id']['year'],
                                      widget.project,
                                      widget.category,
                                      () => widget.refreshMonthlySummary()),
                                ),
                              ),
                            },
                          )
                        : Container(),
                  ],
                )
        ],
      ),
    );
  }
}
