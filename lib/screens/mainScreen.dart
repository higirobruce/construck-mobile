// ignore_for_file: unnecessary_const, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'package:intl/intl.dart';
import 'package:mobile2/api/asset_avblty_analytics_api.dart';
import 'package:mobile2/api/downtime_analytics_api.dart';
import 'package:mobile2/api/equipments_api.dart';
import 'package:mobile2/api/projects_api.dart';
import 'package:mobile2/api/reasons_api.dart';
import 'package:mobile2/api/revenues_analytics_api.dart';
import 'package:mobile2/api/user_api.dart';
import 'package:mobile2/api/workData_api.dart';
import 'package:mobile2/api/workDone_api.dart';
import 'package:mobile2/screens/dailySummary.dart';
import 'package:mobile2/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile2/utils/functions.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MainScreen extends StatefulWidget {
  final String? _id;
  final String? userId;
  final String? name;
  final String? userType;
  final String? initials;
  final String? assignedProject;
  const MainScreen(this._id, this.name, this.userId, this.userType,
      this.initials, this.assignedProject,
      {Key? key})
      : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String finalDate = '';

  var formatter = NumberFormat('#,000.00');
  final _formKeyStart = GlobalKey<FormState>();
  final _formKeyEnd = GlobalKey<FormState>();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _fromProjectController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _lowbedController = TextEditingController();
  final TextEditingController _driverController = TextEditingController();
  final TextEditingController _lowbedDriverController = TextEditingController();
  final TextEditingController _workDoneController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _startIndex = TextEditingController();
  final TextEditingController _endIndex = TextEditingController();
  final TextEditingController? _duration = TextEditingController();
  final TextEditingController _tripsDone = TextEditingController();
  final TextEditingController _hours = TextEditingController();
  final TextEditingController _searchCustomerCntrl = TextEditingController();
  final TextEditingController _searchProjectCntrl = TextEditingController();

  final storage = const FlutterSecureStorage();

  Project project = const Project(prjDescription: '', prjId: '', customer: '');
  Equipment machineToMove = const Equipment(
      equipmentId: '', plateNumber: '', eqDescription: '', eqType: '');

  Equipment lowbed = const Equipment(
      equipmentId: '', plateNumber: '', eqDescription: '', eqType: '');
  WorkDone workDone = const WorkDone(jobDescription: '', jobId: '');
  User driver = const User(firstName: '', lastName: '', userId: '');
  User lowbedDriver = const User(firstName: '', lastName: '', userId: '');
  Reason reason =
      const Reason(description: '', reasonId: '', descriptionRw: '');
  int currentIndex = 0;

  bool submitting = false;
  bool loadingProjectedRev = true;
  bool loadingActualRev = true;
  bool loadingAvgDowntime = true;
  bool loadingAssetUtilization = true;
  bool loadingAssetAvailability = true;
  bool? dayShift = true;
  bool? machineDispatch = false;
  bool? siteWork = false;
  bool durationIsLess = false;
  bool tripsAreLess = false;
  bool showDateRange = false;
  bool showFilters = false;

  double avgFromWorkshop = 0.0;
  double avgToWorkshop = 0.0;
  double avgHours = 0.0;
  double assetUtilization = 0.0;
  double assetAvailability = 0.0;
  String projectedRevenue = '0.0';
  String actualRevenue = '0.0';
  List reasons = List.empty();
  List monthlyValidatedSummary = List.empty();
  List monthlyNonValidatedSummary = List.empty();
  List owners = [
    new Owner(value: 'All', text: 'All Equipment'),
    new Owner(value: 'Construck', text: 'Construck equipment'),
    new Owner(value: 'Hired', text: 'Hired equipment'),
  ];
  List<WorkData>? forms = List.empty();
  DateTimeRange movementDateRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  DateTimeRange workDateRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  Object? _mySelection;
  String loadingText = 'No data found!';

  String _selectedDate = '';
  String _dateCount = '';

  String _startDate = "2022-08-01";

  String _endDate = "2022-08-31";
  String _range = '01-Aug-2022 - 31-Aug-2022';
  String _rangeCount = '';
  String searchCustomer = '';
  String searchProject = '';

  String? _selectedOwner = 'All';

  getCurrentDate() {
    final now = DateTime.now();

    var firstDayOfMonth = DateTime(now.year, now.month, 1).toString();
    var today = DateTime(now.year, now.month, now.day).toString();

    var dateParse = DateTime.parse(firstDayOfMonth);
    var dateParseToday = DateTime.parse(today);

    var formattedFirstDate =
        "${dateParse.year}-${dateParse.month}-${dateParse.day}";
    var formattedToDay =
        "${dateParseToday.year}-${dateParseToday.month}-${dateParseToday.day}";

    setState(() {
      _startDate = formattedFirstDate.toString();
      _endDate = formattedToDay.toString();
      _range = _startDate + '-' + _endDate;
    });
  }

  /// The method for [DateRangePickerSelectionChanged] callback, which will be
  /// called whenever a selection changed on the date picker widget.
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('dd-MMM-yyyy').format(args.value.startDate)} -'
            // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd-MMM-yyyy').format(args.value.endDate ?? args.value.startDate)}';
        _startDate = '${DateFormat('yyyy-MM-dd').format(args.value.startDate)}';

        _endDate =
            '${DateFormat('yyyy-MM-dd').format(args.value.endDate ?? args.value.startDate)}';

        if (args.value.endDate != null) {
          loadDashboardData();
        }
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  void loadDashboardData() {
    showDateRange = false;
    loadingProjectedRev = true;
    loadingActualRev = true;
    loadingAvgDowntime = true;
    loadingAssetAvailability = true;
    loadingAssetUtilization = true;
    RevenueAnalyticsApi.getAnalytics(
            _startDate, _endDate, _selectedOwner, searchCustomer, searchProject)
        .then((value) => {
              setState(() {
                loadingProjectedRev = false;
                loadingActualRev = false;
                actualRevenue = formatter.format(value.totalRevenue);
                projectedRevenue = formatter.format(value.projectedRevenue);
              }),
            });

    DowntimeApi.getDowntimeAnalytics(
            _startDate, _endDate, _selectedOwner, searchCustomer, searchProject)
        .then(
      (value) => {
        setState(() {
          loadingAvgDowntime = false;
          avgFromWorkshop = value.avgFromWorkshop;
          avgToWorkshop = value.avgInWorkshop;
          avgHours = value.avgHours;
        })
      },
    );
    AssetAvbltyApi.getAssetAnalytics(
            _startDate, _endDate, _selectedOwner, searchCustomer, searchProject)
        .then((value) => {
              setState(() {
                loadingAssetAvailability = false;
                assetAvailability = value.assetAvailability;

                loadingAssetUtilization = false;
                assetUtilization = value.assetUtilization;
              })
            });
  }

  void _setDurationCheck() {
    print(_duration!.text);
    setState(() {
      _duration!.text.isNotEmpty
          ? double.parse(_duration!.text) < 5
              ? durationIsLess = true
              : durationIsLess = false
          : durationIsLess = false;
    });

    setState(() {});
    print(durationIsLess);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _duration!.addListener(_setDurationCheck);
    setState(() {
      loadingText = 'Loading data...';
    });

    // getCurrentDate();
    ReasonApi.getReasonSuggestion('').then((value) => setState(() {
          reasons = value;
          if (reasons.isEmpty) {
            loadingText = 'No data found!';
          }
          _mySelection = value[0].descriptionRw;
        }));

    WorkDatasApi.getWorkData(widget._id).then((value) => setState(() {
          forms = value;
          if (forms!.isEmpty) {
            loadingText = 'No data found!';
          }
        }));

    WorkDatasApi.getValidatedSummary(widget.assignedProject)
        .then((value) => setState(() {
              monthlyValidatedSummary = value;
              if (value.isEmpty) {
                loadingText = 'No data found!';
              }
            }));

    WorkDatasApi.getNonValidatedSummary(widget.assignedProject)
        .then((value) => setState(() {
              monthlyNonValidatedSummary = value;
              if (value.isEmpty) {
                loadingText = 'No data found!';
              }
            }));

    loadDashboardData();

    setState(() {
      _duration!.text = '0';
    });
  }

  @override
  void dispose() {
    _duration!.dispose();
    super.dispose();
  }

  Future<void> refresh() {
    setState(() {
      forms = List.empty();
      loadingText = 'Loading data...';
    });
    return WorkDatasApi.getWorkData(widget._id).then((value) => setState(() {
          forms = value;
          if (value.isEmpty) {
            loadingText = 'No data found!';
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
    final screens = (widget.userType == 'admin' ||
            widget.userType == 'workshop-admin' ||
            widget.userType == 'revenue-admin' ||
            widget.userType == 'admin' ||
            widget.userType == 'display')
        ? [
            buildDashboard(context),
            buildSettings(),
          ]
        : (widget.userType == 'customer-site-manager')
            ? [
                buildApprovals(context),
                buildSettings(),
              ]
            : ([
                buildJobList(context),
                buildSettings(),
              ]);

    const bottomNavigationBarItem = BottomNavigationBarItem(
      icon: Icon(Icons.pie_chart),
      label: 'Dashboard',
      backgroundColor: Colors.black87,
    );
    const bottomNavigationBarItem2 = BottomNavigationBarItem(
      icon: Icon(Icons.task),
      label: 'Forms',
      backgroundColor: Colors.black87,
    );

    const bottomNavigationBarItem3 = BottomNavigationBarItem(
      icon: const Icon(Icons.settings),
      label: 'Settings',
      backgroundColor: Colors.black87,
    );
    const bottomNavigationBarItem4 = BottomNavigationBarItem(
      icon: Icon(Icons.assignment_turned_in_outlined),
      label: 'Approvals',
      backgroundColor: Colors.black87,
    );

    return buildAppScaffold(
        screens,
        bottomNavigationBarItem,
        bottomNavigationBarItem3,
        bottomNavigationBarItem2,
        bottomNavigationBarItem4);
  }

  RefreshIndicator buildAppScaffold(
      List<Widget> screens,
      BottomNavigationBarItem bottomNavigationBarItem,
      BottomNavigationBarItem bottomNavigationBarItem3,
      BottomNavigationBarItem bottomNavigationBarItem2,
      BottomNavigationBarItem bottomNavigationBarItem4) {
    return RefreshIndicator(
      displacement: 100,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: refresh,
      child: Scaffold(
        // appBar: AppBar(title: Text('Shabika App')),
        // backgroundColor: Colors.amber[100],
        body: SafeArea(
          child: screens[currentIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            onTap: (index) => setState(() {
                  currentIndex = index;
                  _projectController.text = '';
                  _equipmentController.text = '';
                  _lowbedController.text = '';
                  _driverController.text = '';
                  _lowbedDriverController.text = '';
                  _workDoneController.text = '';
                  _reasonController.text = '';
                  _startIndex.text = '';
                  _endIndex.text = '';
                  _duration!.text = '';
                  _tripsDone.text = '';
                  project = const Project(
                      prjDescription: '', prjId: '', customer: '');
                  machineToMove = const Equipment(
                      equipmentId: '',
                      plateNumber: '',
                      eqDescription: '',
                      eqType: "");

                  lowbed = const Equipment(
                      equipmentId: '',
                      plateNumber: '',
                      eqDescription: '',
                      eqType: '');
                  workDone = const WorkDone(jobDescription: '', jobId: '');
                  driver = const User(firstName: '', lastName: '', userId: '');
                  lowbedDriver =
                      const User(firstName: '', lastName: '', userId: '');
                  reason = const Reason(
                      description: '', reasonId: '', descriptionRw: '');

                  submitting = false;
                  dayShift = true;
                  machineDispatch = false;
                  siteWork = false;

                  movementDateRange =
                      DateTimeRange(start: DateTime.now(), end: DateTime.now());

                  workDateRange =
                      DateTimeRange(start: DateTime.now(), end: DateTime.now());
                }),
            currentIndex: currentIndex,
            // ignore: prefer_const_literals_to_create_immutables
            items: (widget.userType == 'admin' ||
                    widget.userType == 'workshop-admin' ||
                    widget.userType == 'revenue-admin' ||
                    widget.userType == 'admin' ||
                    widget.userType == 'display')
                ? [
                    bottomNavigationBarItem,
                    // bottomNavigationBarItem2,
                    bottomNavigationBarItem3,
                  ]
                : (widget.userType == 'customer-site-manager')
                    ? [
                        bottomNavigationBarItem4,
                        // bottomNavigationBarItem2,
                        bottomNavigationBarItem3,
                      ]
                    : ([
                        bottomNavigationBarItem2,
                        bottomNavigationBarItem3,
                      ])),
      ),
    );
  }

  SingleChildScrollView buildDashboard(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildTopNav(context),
          buildFilters(showFilters),
          buildDateRange(showDateRange, _onSelectionChanged),
          widget.userType == 'revenue-admin' ||
                  widget.userType == 'admin' ||
                  widget.userType == 'display'
              ? buildInfoTile(
                  'Projected Revenues',
                  const Icon(Icons.account_balance_wallet_rounded),
                  '$projectedRevenue RWF',
                  loadingProjectedRev)
              : Container(
                  child: null,
                ),
          widget.userType == 'revenue-admin' ||
                  widget.userType == 'admin' ||
                  widget.userType == 'display'
              ? buildInfoTile(
                  'Actual Revenues',
                  const Icon(Icons.money, color: Colors.blue),
                  "$actualRevenue RWF",
                  loadingActualRev)
              : Container(
                  child: null,
                ),
          buildInfoTile(
              'Asset Utilization',
              const Icon(Icons.trending_up_outlined, color: Colors.green),
              '$assetUtilization %',
              loadingAssetUtilization),
          buildInfoTile(
              'Asset availability',
              const Icon(Icons.event_available, color: Colors.orange),
              '$assetAvailability %',
              loadingAssetAvailability),
          buildInfoTile(
              'Average downtime',
              const Icon(Icons.timer, color: Colors.red),
              "$avgHours Hours",
              loadingAvgDowntime),
        ],
      ),
    );
  }

  Column buildJobList(BuildContext context) {
    return Column(
      children: [
        buildTopNav(context),
        Expanded(
          child: forms!.isEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loadingText),
                    loadingText == 'No data found!'
                        ? IconButton(
                            icon: const Icon(Icons.refresh),
                            color: Colors.orange,
                            onPressed: refresh,
                          )
                        : const Text('')
                  ],
                ))
              : buildJobs(forms),
        ),
      ],
    );
  }

  Column buildApprovals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopNav(context),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, bottom: 8),
          child: Text(
            widget.assignedProject!,
            style: TextStyle(fontSize: 13),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Cost to be validated',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.more_horiz,
                size: 20,
                color: Theme.of(context).accentColor,
              )
            ],
          ),
        ),
        buildMonthlyData(monthlyNonValidatedSummary),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Validated Cost',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.more_horiz,
                size: 20,
                color: Theme.of(context).accentColor,
              )
            ],
          ),
        ),
        buildMonthlyData(monthlyValidatedSummary),
      ],
    );
  }

  Widget buildMonthlyData(List monthlySummary) => Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2.0,
                )
              ]),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: monthlySummary.isEmpty
              ? Center(
                  child: Text('Loading data...'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final monthlyData = monthlySummary[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: index == 0
                                ? const Border() // This will create no border for the first item
                                : Border(
                                    top: BorderSide(
                                        width: 1,
                                        color: Colors.grey[
                                            300]!)), // This will create top borders for the rest
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(monthlyData['monthYear'],
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700])),
                                    Text('RWF ' + monthlyData['totalRevenue'],
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[500])),
                                  ],
                                ),
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
                                        builder: (context) => DailySummary(
                                            monthlyData['id']['month'],
                                            monthlyData['id']['year'],
                                            widget.assignedProject),
                                      ),
                                    )
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: monthlySummary.length,
                ),
        ),
      );

  Widget buildJobs(List<WorkData>? jobs) => ListView.builder(
        itemBuilder: (context, index) {
          final job = jobs![index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: buildJobCard(job, context),
          );
        },
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: jobs!.length,
      );

  Card buildJobCard(WorkData job, BuildContext context) {
    return Card(
      child: ListTile(
          subtitle:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(job.dispatchDate + ' ' + job.shift,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              job.prj.prjDescription,
            ),
            addVerticalSpace(),
            if (job.siteWork == true)
              const Text(
                'sw',
                style: TextStyle(
                    color: Color.fromARGB(134, 158, 38, 38),
                    fontWeight: FontWeight.bold,
                    fontSize: 10.0),
              ),
            addVerticalSpace(),
            Text(
              job.equipment!.eqDescription + '-' + job.equipment!.plateNumber,
            ),
            addVerticalSpace(),
            Text(job.workDone!.jobDescription),
            addVerticalSpace(),
            if (job.equipment!.eqType == 'Truck')
              Text(
                'Target trips: ' + job.targetTrips,
                style: const TextStyle(
                  color: Color.fromARGB(135, 20, 20, 20),
                ),
              ),
            addVerticalSpace(),
          ]),
          trailing: job.status == 'in progress'
              ? IconButton(
                  onPressed: () => {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setState) => AlertDialog(
                                  title: const Text('Gusoza akazi'),
                                  content: Form(
                                    key: _formKeyEnd,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: _endIndex,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              hintText:
                                                  "Kilometraje nyuma y'akazi",
                                              prefixIcon: Icon(Icons.login),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Andika Kilometraje zisoza';
                                              }
                                              // else if (double.parse(
                                              //         value) <
                                              //     job.startIndex) {
                                              //   return 'Izisoza ni nto kuzo watangiranye akazi!';
                                              // }
                                              return null;
                                            },
                                          ),
                                          TextFormField(
                                            controller: _duration,
                                            inputFormatters: const [
                                              //only numeric keyboard.
                                              // LengthLimitingTextInputFormatter(
                                              //     3), //only 6 digit
                                              // WhitelistingTextInputFormatter.digitsOnly
                                            ],
                                            onChanged: (value) {
                                              if (value.isNotEmpty &&
                                                  double.parse(value) < 5) {
                                                setState(
                                                  () => {durationIsLess = true},
                                                );
                                              } else {
                                                setState(
                                                  () => {
                                                    durationIsLess = false,
                                                  },
                                                );
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              hintText: 'Amasaha akazi katwaye',
                                              prefixIcon: Icon(Icons.timelapse),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Andika amasaha akazi katwaye';
                                              }
                                              return null;
                                            },
                                          ),
                                          if (job.targetTrips != "N/A")
                                            TextFormField(
                                              controller: _tripsDone,
                                              onChanged: (value) {
                                                if (job.targetTrips != 'N/A') {
                                                  if (value.isNotEmpty &&
                                                      double.parse(value) <
                                                          double.parse(job
                                                              .targetTrips)) {
                                                    setState(
                                                      () =>
                                                          {tripsAreLess = true},
                                                    );
                                                  } else {
                                                    setState(
                                                      () => {
                                                        tripsAreLess = false,
                                                      },
                                                    );
                                                  }
                                                }
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                hintText:
                                                    "Umubare w'Ingendo wakoze",
                                                prefixIcon: Icon(
                                                    Icons.threesixty_sharp),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Andika umubare w'ingendo wakoze";
                                                }

                                                return null;
                                              },
                                            ),
                                          if (durationIsLess == true ||
                                              tripsAreLess)
                                            DropdownButtonFormField(
                                                items: reasons.map((item) {
                                                  return DropdownMenuItem(
                                                    child: Text(
                                                        item.descriptionRw),
                                                    value: item.descriptionRw,
                                                  );
                                                }).toList(),
                                                onChanged: (newVal) {
                                                  setState(() {
                                                    _mySelection = newVal;
                                                  });
                                                },
                                                value: _mySelection),
                                          // TypeAheadFormField(
                                          //   debounceDuration:
                                          //       const Duration(
                                          //           milliseconds: 500),
                                          //   // hideSuggestionsOnKeyboardHide: false,
                                          //   textFieldConfiguration:
                                          //       TextFieldConfiguration(
                                          //     controller:
                                          //         _reasonController,
                                          //     decoration:
                                          //         const InputDecoration(
                                          //       prefixIcon: Icon(
                                          //           Icons.question_mark),
                                          //       hintText: 'Impamvu',
                                          //     ),
                                          //   ),
                                          //   onSuggestionSelected:
                                          //       (Reason suggestion) {
                                          //     _reasonController.text =
                                          //         suggestion
                                          //             .descriptionRw;
                                          //     reason = suggestion;
                                          //   },
                                          //   itemBuilder: (context,
                                          //       Reason? suggestion) {
                                          //     final reason = suggestion!;

                                          //     return ListTile(
                                          //       title: Text(
                                          //           reason.descriptionRw),
                                          //     );
                                          //   },
                                          //   suggestionsCallback: ReasonApi
                                          //       .getReasonSuggestion,
                                          //   noItemsFoundBuilder:
                                          //       (context) => Container(
                                          //     height: 80,
                                          //     child: const Center(
                                          //       child: Text(
                                          //         'Nta mpamvu zibonetse.',
                                          //         style: TextStyle(
                                          //             fontSize: 14),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // )
                                        ]),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () => {
                                              Navigator.pop(context),
                                            },
                                        child: const Text('GUSUBIRA INYUMA')),
                                    TextButton(
                                      onPressed: () => {
                                        if (_formKeyEnd.currentState!
                                            .validate())
                                          {
                                            this.setState(() {
                                              forms = List.empty();
                                            }),
                                            Navigator.pop(context),
                                            WorkDatasApi.endJob(
                                                    job.jobId,
                                                    _endIndex.text,
                                                    _duration!.text,
                                                    _tripsDone.text,
                                                    durationIsLess ||
                                                            tripsAreLess
                                                        ? _mySelection
                                                            .toString()
                                                        : '',
                                                    widget.userId!,
                                                    job.dispatchDate)
                                                .then(
                                              (value) => {
                                                refresh(),
                                                this.setState(() {
                                                  _endIndex.text = '';
                                                  _startIndex.text = '';
                                                  _duration!.text = '';
                                                  _tripsDone.text = '';
                                                  _hours.text = '';
                                                })
                                              },
                                            ),
                                          },
                                      },
                                      child: const Text("OHEREZA"),
                                    )
                                  ],
                                ),
                              );
                            }),
                      },
                  // ignore: prefer_const_constructors
                  icon: Icon(
                    Icons.stop,
                    color: Colors.red,
                  ))
              : job.status == 'created' || job.status == 'on going'
                  ? IconButton(
                      onPressed: () => showDialog(
                          context: context,
                          builder: (
                            context,
                          ) =>
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: const Text('Gutangira akazi'),
                                    content: Form(
                                      key: _formKeyStart,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            controller: _startIndex,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              hintText:
                                                  'Kilometraje utangiranye',
                                              prefixIcon: Icon(Icons.login),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Andika kilometraje utangiranye';
                                              }
                                              // else if (double.parse(
                                              //         value) <
                                              //     job.millage) {
                                              //   return "Ni nke kuz'iheruka";
                                              // }
                                              return null;
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('GUSUBIRA INYUMA')),
                                      TextButton(
                                        onPressed: () => {
                                          if (_formKeyStart.currentState!
                                              .validate())
                                            {
                                              this.setState(() {
                                                forms = List.empty();
                                              }),
                                              Navigator.pop(context),
                                              WorkDatasApi.startJob(
                                                      job.jobId,
                                                      _startIndex.text,
                                                      widget.userId!,
                                                      job.dispatchDate)
                                                  .then(
                                                (value) => this.setState(
                                                  () => {
                                                    _duration!.text = '',
                                                    _tripsDone.text = '',
                                                    _endIndex.text = '',
                                                    _hours.text = '',
                                                    _startIndex.text = '',
                                                    refresh()
                                                  },
                                                ),
                                              ),
                                            }
                                        },
                                        child: const Text("OHEREZA"),
                                      )
                                    ],
                                  );
                                },
                              )),

                      // ignore: prefer_const_constructors
                      icon: Icon(
                        Icons.play_arrow,
                        color: Colors.green,
                      ))
                  : job.status == 'approved'
                      // ignore: prefer_const_constructors
                      ? Icon(
                          Icons.check,
                          color: Colors.blue,
                        )
                      // ignore: prefer_const_constructors
                      : job.status == 'stopped'
                          ? const Icon(
                              Icons.hourglass_bottom,
                            )
                          : const Icon(
                              Icons.close,
                              color: Colors.red,
                            )),
    );
  }

  SizedBox addVerticalSpace() {
    return const SizedBox(
      height: 5,
    );
  }

  Center buildSettings() {
    return const Center(
      child: Text('Settings'),
    );
  }

  Widget buildFilters(showFilters) {
    return showFilters == true
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showDateRange = !showDateRange;
                          });
                        },
                        icon: Icon(Icons.calendar_month_rounded,
                            color: Colors.blue),
                      ),
                      Text(_range),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.business_center_rounded,
                            color: Colors.orange),
                      ),
                      DropdownButton(
                        items: [
                          DropdownMenuItem(
                            child: Text('All equipment'),
                            value: 'All',
                          ),
                          DropdownMenuItem(
                            child: Text('Construck equipment'),
                            value: 'Construck',
                          ),
                          DropdownMenuItem(
                            child: Text('Hired equipment'),
                            value: 'Hired',
                          ),
                        ],
                        value: _selectedOwner,
                        onChanged: (String? selectedOwner) {
                          setState(() {
                            _selectedOwner = selectedOwner;
                            loadDashboardData();
                          });
                        },
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Text('Customer'),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchCustomerCntrl,
                          onChanged: (val) {
                            if (val.length >= 3 || val.isEmpty) {
                              setState(() {
                                searchCustomer = val;

                                loadDashboardData();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Text('Project'),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchProjectCntrl,
                          onChanged: (val) {
                            if (val.length >= 3 || val.isEmpty) {
                              setState(() {
                                searchProject = val;

                                loadDashboardData();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container(
            child: null,
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
            Row(
              children: [
                Text(
                  widget.initials!,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                (widget.userType == 'admin' ||
                        widget.userType == 'workshop-admin' ||
                        widget.userType == 'revenue-admin' ||
                        widget.userType == 'admin' ||
                        widget.userType == 'display')
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            showFilters = !showFilters;
                          });
                        },
                        icon: Icon(Icons.tune),
                      )
                    : Container(
                        child: null,
                      ),
                IconButton(
                    onPressed: () async {
                      await storage.deleteAll();
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, size: 20))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Owner {
  final String value;
  final String text;

  const Owner({required this.value, required this.text});
}
