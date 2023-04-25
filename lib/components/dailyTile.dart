// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile2/api/workData_api.dart';

const GLOBAL_PADDING = 20.0;

class DailyTile extends StatefulWidget {
  const DailyTile(
      {Key? key,
      required this.dailyData,
      required this.category,
      status,
      required this.refresh})
      : super(key: key);

  final dailyData;
  final category;
  final VoidCallback refresh;

  @override
  State<DailyTile> createState() => _DailyTileState();
}

class _DailyTileState extends State<DailyTile> {
  bool approving = false;
  bool rejecting = false;
  bool released = false;
  final TextEditingController _reasonController = TextEditingController();

  void rejectModalBottomSheet(context, dailyData) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.grey[200],
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
                            decoration:
                                InputDecoration(border: InputBorder.none),
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
                          rejectDailyWork(dailyData, _reasonController.text);
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

  void approveModalBottomSheet(context, dailyData) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey[200],
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
                        approveDailyWork(dailyData);
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

  void approveDailyWork(dailyData) {
    if (dailyData['siteWork'] == true) {
      print(dailyData['dailyWork']['totalRevenue']);
      setState(() {
        approving = true;
      });
      WorkDatasApi.approveDailySiteWork(
              dailyData['_id'],
              dailyData['transactionDate'],
              dailyData['dailyWork']['totalRevenue'].toString(),
              dailyData['dailyWork']['duration'].toString(),
              dailyData['dailyWork']['totalExpenditure'].toString())
          .then((value) => {
                print(value),
                widget.refresh(),
                setState(() => {
                      widget.dailyData['status'] = 'approved',
                      approving = false
                    })
              });
    } else {
      setState(() {
        approving = true;
      });
      WorkDatasApi.approve(dailyData['_id']).then((value) => {
            widget.refresh(),
            setState(() =>
                {widget.dailyData['status'] = 'approved', approving = false})
          });
    }
  }

  void rejectDailyWork(dailyData, reason) {
    if (dailyData['siteWork'] == true) {
      print(dailyData['dailyWork']['totalRevenue']);
      setState(() {
        rejecting = true;
      });
      WorkDatasApi.rejectDailySiteWork(
              dailyData['_id'],
              dailyData['transactionDate'],
              dailyData['dailyWork']['totalRevenue'].toString(),
              dailyData['dailyWork']['duration'].toString(),
              dailyData['dailyWork']['totalExpenditure'].toString(),
              reason)
          .then((value) => {
                print(value),
                setState(() => {
                      widget.dailyData['status'] = 'approved',
                      rejecting = false
                    })
              });
    } else {
      setState(() {
        rejecting = true;
      });
      WorkDatasApi.reject(dailyData['_id'], reason).then((value) => {
            print(value.toString()),
            setState(() =>
                {widget.dailyData['status'] = 'approved', rejecting = false})
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    var strRevenue = widget.dailyData['strRevenue'];
    var transactionDate = widget.dailyData['transactionDate'];
    var plateNumber = widget.dailyData['equipment']['plateNumber'];
    var eqType = widget.dailyData['equipment']['eqDescription'];
    var shift = widget.dailyData['dispatch']['shift'];
    var uom = widget.dailyData['equipment']['uom'];
    var isSiteWork = widget.dailyData['siteWork'];
    var durationString = isSiteWork
        ? widget.dailyData['dailyWork']['duration'].toString()
        : widget.dailyData['duration'].toString() + ' ' + uom + 's';
    var duration = (isSiteWork
        ? widget.dailyData['dailyWork']['duration']
        : widget.dailyData['duration']);

    var status = widget.dailyData['status'];
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
                      .format(DateTime.parse(transactionDate)),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700])),
              Text('RWF ' + strRevenue,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500])),
              Text(plateNumber + '-' + eqType,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700])),
              Text(shift,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700])),
              uom == 'day'
                  ? Text(durationString,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]))
                  : Text(
                      (duration / (60 * 60 * 1000)).toString() +
                          ' ' +
                          uom +
                          's',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700])),
            ],
          ),
          status != 'approved'
              ? Row(
                  children: [
                    widget.category == 'not validated'
                        ? approving
                            ? Container(
                                // margin: EdgeInsets.all(10.0),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),

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
                                    approveModalBottomSheet(
                                        context, widget.dailyData)
                                  },
                                  child: Text(
                                    'Approve',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.green[400]),
                                  ),
                                ),
                              )
                        : Container(),
                    SizedBox(width: 5),
                    widget.category == 'not validated'
                        ? rejecting
                            ? Container(
                                // margin: EdgeInsets.all(10.0),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),

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
                                    // rejectDailyWork(widget.dailyData)
                                    rejectModalBottomSheet(
                                        context, widget.dailyData)
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
                  ],
                )
              : Text('Done'),
        ],
      ),
    );
  }
}
