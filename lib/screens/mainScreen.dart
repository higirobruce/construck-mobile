// ignore_for_file: unnecessary_const, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers

import 'dart:math';

import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mobile2/api/asset_avblty_analytics_api.dart';
import 'package:mobile2/api/downtime_analytics_api.dart';
import 'package:mobile2/api/equipmentTypes.dart';
import 'package:mobile2/api/equipments_api.dart';
import 'package:mobile2/api/projects_api.dart';
import 'package:mobile2/api/reasons_api.dart';
import 'package:mobile2/api/requests_api.dart';
import 'package:mobile2/api/revenues_analytics_api.dart';
import 'package:mobile2/api/user_api.dart';
import 'package:mobile2/api/workData_api.dart';
import 'package:mobile2/api/workDone_api.dart';
import 'package:mobile2/components/bottomSheetDataSelector.dart';
import 'package:mobile2/components/bottomSheetForm.dart';
import 'package:mobile2/components/customTextField.dart';
import 'package:mobile2/components/monthlyTile.dart';
import 'package:mobile2/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile2/theme/them_constants.dart';
import 'package:mobile2/utils/functions.dart';
import 'package:mobile2/utils/types.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

const double GLOBAL_PADDING = 15.0;

const List utlizedEqui = [1.0, 2.0, 6.0, 5.0, 8.0, 2.0, 1.0];
const List deployedEqui = [1.0, 3.0, 6.0, 7.0, 6.0, 5.0, 6.0];
const List benchmark = [5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0];

class MainScreen extends StatefulWidget {
  final String? _id;
  final String? userId;
  final String? name;
  final String? userType;
  final String? initials;
  final List<dynamic>? assignedProjects;
  const MainScreen(this._id, this.name, this.userId, this.userType,
      this.initials, this.assignedProjects,
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
  final TextEditingController? _durationMinutes = TextEditingController();
  final TextEditingController _tripsDone = TextEditingController();
  final TextEditingController _hours = TextEditingController();
  final TextEditingController _searchCustomerCntrl = TextEditingController();
  final TextEditingController _searchProjectCntrl = TextEditingController();
  final TextEditingController reqReferenceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final storage = const FlutterSecureStorage();

  Project project = const Project(prjDescription: '', prjId: '', customer: '');
  Equipment machineToMove = const Equipment(
      equipmentId: '', plateNumber: '', eqDescription: '', eqType: '');

  Equipment lowbed = const Equipment(
      equipmentId: '', plateNumber: '', eqDescription: '', eqType: '');
  WorkDone workDone =
      const WorkDone(jobDescription: '', jobId: '', id: '', description: '');
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
  bool loadingRequests = true;
  bool? dayShift = true;
  bool? machineDispatch = false;
  bool? siteWork = false;
  bool durationIsLess = false;
  bool durationMinutesIsLess = false;
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
  List monthlyReleased = List.empty();
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
  bool validatedFound = false;
  bool nonValidatedFound = false;
  bool releasedFound = false;

  bool loadingValidated = false;
  bool loadingNonValidated = false;
  bool loadingReleased = false;
  bool loadingWorkList = false;

  String _selectedDate = '';
  String _dateCount = '';

  String _startDate = "2022-08-01";

  String _endDate = "2022-08-31";
  String _range = '01-Aug-2022 - 31-Aug-2022';
  String _rangeCount = '';
  String searchCustomer = '';
  String searchProject = '';
  String monitoredProject = '';
  String selectedEquipmentType = '';
  String selectedShift = '';
  String selectedRequest = '';

  String? _selectedOwner = 'All';

  List<EquipmentRequest> requests = [];
  List<EquipmentRequest> approvedRequests = [];
  List<RequestSummary> aggregatedRequests = [];
  List<EquipmentType> equipmentTypes = [];
  List<ShiftType> shifts = [
    ShiftType(description: 'Day shift', id: 'dayShift'),
    ShiftType(description: 'Nigt shift', id: 'nightShift'),
  ].toList();

  List<WorkDone> workList = [];

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
    setState(() {
      _duration!.text.isNotEmpty
          ? double.parse(_duration!.text) < 5
              ? durationIsLess = true
              : durationIsLess = false
          : durationIsLess = false;
    });

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _duration!.addListener(_setDurationCheck);
    setState(() {
      loadingText = 'Loading data...';
      monitoredProject = widget.assignedProjects![0]['description'];
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

    fetchNonValidatedMonthly(monitoredProject);

    fetchValidatedMonthly(monitoredProject);

    fetchReleasedMonthly(monitoredProject);

    loadDashboardData();

    fetchRequests();

    fetchEquipmentTypes();

    fetchAggregatedRequests();

    fetchWorkList();
    // handleNotifications();

    setState(() {
      _duration!.text = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      buildJobList(context),
      buildSettings(),
    ];

    if (widget.userType == 'admin' ||
        widget.userType == 'workshop-admin' ||
        widget.userType == 'revenue-admin' ||
        widget.userType == 'admin' ||
        widget.userType == 'display')
      screens = [
        buildDashboard(context),
        buildApprovals(context),
        buildReports(context),
        buildSettings(),
      ];
    else if (widget.userType == 'customer-site-manager')
      screens = [
        buildRequestsScreen(context),
        buildApprovals(context),
        buildReports(context),
        // buildReports(context),
        buildSettings(),
      ];
    else if (widget.userType == 'customer-project-manager')
      screens = [
        buildApprovals(context),
        buildReports(context),
        buildSettings(),
      ];
    else if (widget.userType == 'logistic-officer')
      screens = [
        buildRequestsScreen(context),
        buildApprovals(context),
        buildReports(context),
        buildSettings(),
      ];
    else
      screens = [
        buildJobList(context),
        buildSettings(),
      ];

    const bottomNavDashboard = BottomNavigationBarItem(
      icon: Icon(Icons.pie_chart),
      label: 'Dashboard',
      // backgroundColor: Colors.black87,
    );
    const bottomNavDispatches = BottomNavigationBarItem(
      icon: Icon(Icons.task),
      label: 'Forms',
      // backgroundColor: Colors.black87,
    );
    const bottomNavSettings = BottomNavigationBarItem(
      icon: const Icon(Icons.settings),
      label: 'Settings',
      // backgroundColor: Colors.black87,
    );
    const bottomNavRevApprovals = BottomNavigationBarItem(
      icon: Icon(Icons.assignment_turned_in_outlined),
      label: 'Approvals',
      // backgroundColor: Colors.black87,
    );
    const bottomNavReports = BottomNavigationBarItem(
      icon: Icon(Icons.assessment),
      label: 'Reports',
      // backgroundColor: Colors.black87,
    );
    const bottomNavRequests = BottomNavigationBarItem(
      icon: Icon(Icons.task),
      label: 'Requests',
      // backgroundColor: Colors.black87,
    );

    return buildAppScaffold(
        screens,
        bottomNavDashboard,
        bottomNavSettings,
        bottomNavDispatches,
        bottomNavRevApprovals,
        bottomNavReports,
        bottomNavRequests);
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

    fetchNonValidatedMonthly(monitoredProject);

    fetchValidatedMonthly(monitoredProject);

    fetchReleasedMonthly(monitoredProject);
    return WorkDatasApi.getWorkData(widget._id).then((value) => setState(() {
          forms = value;
          if (value.isEmpty) {
            loadingText = 'No data found!';
          }
        }));
  }

  buildAppScaffold(
    List<Widget> screens,
    BottomNavigationBarItem bottomNavDashboard,
    BottomNavigationBarItem bottomNavSettings,
    BottomNavigationBarItem bottomNavDispatches,
    BottomNavigationBarItem bottomNavRevApprovals,
    BottomNavigationBarItem bottomNavReports,
    BottomNavigationBarItem bottomNavRequests,
  ) {
    List<BottomNavigationBarItem> items = [
      bottomNavDispatches,
      bottomNavSettings,
    ];
    if (widget.userType == 'admin' ||
        widget.userType == 'workshop-admin' ||
        widget.userType == 'revenue-admin' ||
        widget.userType == 'admin' ||
        widget.userType == 'display')
      items = [
        bottomNavDashboard,
        bottomNavRevApprovals,
        bottomNavReports,
        bottomNavSettings,
      ];
    else if (widget.userType == 'customer-site-manager')
      items = [
        bottomNavRequests,
        bottomNavRevApprovals,
        // bottomNavigationBarItem2,
        bottomNavReports,
        bottomNavSettings,
      ];
    else if (widget.userType == "customer-project-manager")
      items = [
        bottomNavRevApprovals,
        // bottomNavigationBarItem2,
        bottomNavReports,
        bottomNavSettings,
      ];
    else if (widget.userType == "logistic-officer")
      items = [
        bottomNavRequests,
        bottomNavRevApprovals,
        // bottomNavigationBarItem2,
        bottomNavReports,
        bottomNavSettings,
      ];
    else
      items = [
        bottomNavDispatches,
        bottomNavSettings,
      ];

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
          type: BottomNavigationBarType.fixed,
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
            project =
                const Project(prjDescription: '', prjId: '', customer: '');
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
            workDone = const WorkDone(
                jobDescription: '', jobId: '', id: '', description: '');
            driver = const User(firstName: '', lastName: '', userId: '');
            lowbedDriver = const User(firstName: '', lastName: '', userId: '');
            reason =
                const Reason(description: '', reasonId: '', descriptionRw: '');

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
          items: items,
        ),
      ),
    );
  }

  buildReports(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          buildTopNav(context),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, bottom: 8),
            child: Text(
              widget.assignedProjects![0]['description'],
              style: TextStyle(fontSize: 13),
            ),
          ),
          buildChart(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Released Costs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        fetchReleasedMonthly(monitoredProject);
                      });
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: Colors.grey[600],
                    ))
              ],
            ),
          ),
          buildMonthlyData(
              monthlyReleased, 'released', loadingReleased, releasedFound),
        ],
      ),
    );
  }

  buildChart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GLOBAL_PADDING),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Column(
          children: [
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GLOBAL_PADDING),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Equipment utilization (past 7 days)',
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            SizedBox(
              height: 150,
              // width: 300,
              child: Chart(
                  padding: EdgeInsets.symmetric(horizontal: GLOBAL_PADDING),
                  layers: [
                    ChartAxisLayer(
                      settings: ChartAxisSettings(
                        x: ChartAxisSettingsAxis(
                          frequency: 1.0,
                          max: 13.0,
                          min: 7.0,
                          textStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10.0,
                          ),
                        ),
                        y: ChartAxisSettingsAxis(
                          frequency: 100.0,
                          max: [
                            utlizedEqui.reduce(
                                (curr, next) => curr > next ? curr : next),
                          ].reduce((curr, next) => curr > next ? curr : next),
                          min: 0.0,
                          textStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10.0,
                          ),
                        ),
                      ),
                      labelX: (value) => value.toInt().toString(),
                      labelY: (value) => value.toInt().toString(),
                    ),
                    // ChartBarLayer(
                    // items: List.generate(
                    //   13 - 7 + 1,
                    //   (index) => ChartBarDataItem(
                    //     color: const Color(0xFF8043F9),
                    //     value: Random().nextInt(280) + 20,
                    //     x: index.toDouble() + 7,
                    //   ),
                    // ),
                    // settings: const ChartBarSettings(
                    //   thickness: 8.0,
                    //   radius: BorderRadius.all(Radius.circular(4.0)),
                    //   ),
                    // ),

                    ChartLineLayer(
                        items: List.generate(
                          utlizedEqui.length,
                          (index) => ChartLineDataItem(
                            value: utlizedEqui[index],
                            x: index.toDouble() + 7,
                          ),
                        ),
                        settings: const ChartLineSettings(
                            thickness: 2.0, color: Colors.blue)),

                    ChartLineLayer(
                        items: List.generate(
                          utlizedEqui.length,
                          (index) => ChartLineDataItem(
                            value: benchmark[index],
                            x: index.toDouble() + 7,
                          ),
                        ),
                        settings: const ChartLineSettings(
                            thickness: 1.0, color: Colors.orange))
                  ]),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GLOBAL_PADDING),
              child: Row(
                children: [
                  Container(
                    // child: Text('z'),
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Equipment Utilization',
                    style: TextStyle(fontSize: 12.0),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GLOBAL_PADDING),
              child: Row(
                children: [
                  Container(
                    // child: Text('z'),
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Benchmark',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  buildMonthlyData(List monthlySummary, String category, bool loadingState,
          bool dataFound) =>
      Padding(
        padding: const EdgeInsets.all(GLOBAL_PADDING),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black12,
            //     blurRadius: 2.0,
            //   )
            // ],
          ),
          padding: EdgeInsets.symmetric(
              horizontal: GLOBAL_PADDING, vertical: GLOBAL_PADDING - 5),
          child: loadingState == true
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
              : monthlySummary.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final monthlyData = monthlySummary[index];
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
                          child: MonthlyTile(
                              monthlyData: monthlyData,
                              widget: widget,
                              category: category,
                              refreshMonthlySummary: refreshMontlySummaries,
                              refreshValidated: fetchValidatedMonthly,
                              refreshNonValidated: fetchNonValidatedMonthly,
                              project: monitoredProject),
                        );
                      },
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: monthlySummary.length,
                    )
                  : Text('Nothing to show'),
        ),
      );

  buildJobs(List<WorkData>? jobs) => ListView.builder(
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

  buildJobCard(WorkData job, BuildContext context) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Target trips: ' + job.targetTrips,
                    style: const TextStyle(
                      color: Color.fromARGB(135, 20, 20, 20),
                    ),
                  ),
                  Text(
                    'Trips done: ' + job.tripsDone.toString(),
                    style: const TextStyle(
                      color: Color.fromARGB(135, 20, 20, 20),
                    ),
                  ),
                ],
              ),
            if (job.status == 'stopped') Text(job.duration.toString()),
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
                                          TextFormField(
                                            controller: _durationMinutes,
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
                                                  () => {
                                                    durationMinutesIsLess = true
                                                  },
                                                );
                                              } else {
                                                setState(
                                                  () => {
                                                    durationMinutesIsLess =
                                                        false,
                                                  },
                                                );
                                              }
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              hintText:
                                                  'Iminota irenga ku masaha',
                                              prefixIcon: Icon(Icons.timelapse),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Andika iminota irenga ku masaha';
                                              }
                                              if (double.parse(value) > 59.0) {
                                                return 'Iminota ntiyarenga 59';
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
                                                    (double.parse(_duration!
                                                                .text) +
                                                            double.parse(
                                                                    _durationMinutes!
                                                                        .text) /
                                                                60)
                                                        .toStringAsFixed(2),
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

  addVerticalSpace() {
    return const SizedBox(
      height: 5,
    );
  }

  buildFilters(showFilters) {
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
                  widget.name!,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
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
                      // await UserApi.updateToken(widget.userId!, "");
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

  buildRequests() {
    return requests.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              var requestCardProperties = [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat.yMMMMd()
                              .format(DateTime.parse(requests[index].startDate))
                              .toString() +
                          '-' +
                          DateFormat.yMMMMd()
                              .format(DateTime.parse(requests[index].endDate))
                              .toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ],
                ),

                // Text(
                //   requests[index].referenceNumber,
                //   style: TextStyle(fontWeight: FontWeight.bold),
                // ),

                Text(
                  requests[index].project,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                Text(
                  'For: ' + requests[index].workToBeDone['jobDescription'],
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                buildRequestTrips(index, requests),
                SizedBox(
                  height: 10.0,
                ),

                buildRequestFromTo(index, requests),
                Text(
                  'Equipment requested: ' +
                      requests[index].equipmentType.description,
                ),
                Text(
                  'Quantity requested: ' + requests[index].quantity.toString(),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Chip(
                  // avatar: CircleAvatar(
                  //   backgroundColor: Colors.grey.shade800,
                  //   child: const Text('1'),
                  // ),
                  backgroundColor: Colors.orange,

                  label: const Text(
                    'pending',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ];
              return Card(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 200),
                  child: Padding(
                    padding: const EdgeInsets.all(GLOBAL_PADDING),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: requestCardProperties,
                    ),
                  ),
                ),
              );
            },
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: requests.length,
          )
        : loadingRequests
            ? Center(
                child: CircularProgressIndicator(
                strokeWidth: 2.0,
              ))
            : Container();
  }

  Widget buildRequestFromTo(int index, List requests) {
    if ((requests[index].tripFrom.toString().isNotEmpty &&
            requests[index].tripFrom.toString() != 'null') ||
        ((requests[index].tripTo.toString().isNotEmpty &&
            requests[index].tripTo.toString() != 'null'))) {
      return Text(
        requests[index].tripFrom + ' to ' + requests[index].tripTo,
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    } else {
      return Container();
    }
  }

  Widget buildRequestTrips(int index, List requests) {
    if (requests[index].tripsToBeMade.toString().isNotEmpty &&
        requests[index].tripsToBeMade.toString() != 'null') {
      return Text(
        'Trips be made: ' + requests[index].tripsToBeMade.toString(),
        style: TextStyle(fontWeight: FontWeight.w600),
      );
    } else {
      return Container();
    }
  }

  buildApprovedRequests() {
    return approvedRequests.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Card(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 200),
                  child: Padding(
                    padding: const EdgeInsets.all(GLOBAL_PADDING),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat.yMMMMd()
                                      .format(DateTime.parse(
                                          approvedRequests[index].startDate))
                                      .toString() +
                                  '-' +
                                  DateFormat.yMMMMd()
                                      .format(DateTime.parse(
                                          approvedRequests[index].endDate))
                                      .toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                          ],
                        ),

                        // Text(
                        //   requests[index].referenceNumber,
                        //   style: TextStyle(fontWeight: FontWeight.bold),
                        // ),

                        Text(
                          approvedRequests[index].project,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        Text(
                          'For: ' +
                              approvedRequests[index]
                                  .workToBeDone['jobDescription'],
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        buildRequestTrips(index, approvedRequests),
                        SizedBox(
                          height: 10.0,
                        ),

                        buildRequestFromTo(index, approvedRequests),

                        Text(
                          'Equipment requested: ' +
                              approvedRequests[index].equipmentType.description,
                        ),
                        Text(
                          'Quantity requested: ' +
                              approvedRequests[index].quantity.toString(),
                        ),

                        SizedBox(
                          height: 10.0,
                        ),
                        // Text(
                        //   approvedRequests[index].status,
                        //   style: TextStyle(color: Colors.black54),
                        // ),
                        Expanded(
                          child: Chip(
                            avatar: CircleAvatar(
                              backgroundColor: Colors.grey.shade100,
                              child: Text(approvedRequests[index]
                                  .approvedQuantity
                                  .toString()),
                            ),
                            backgroundColor: Colors.lightBlue,
                            label: const Text(
                              'approved',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: approvedRequests.length,
          )
        : loadingRequests
            ? Center(
                child: CircularProgressIndicator(
                strokeWidth: 2.0,
              ))
            : Container();
  }

  buildAggregatedRequests() {
    return requests.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(GLOBAL_PADDING),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),

                      // Text(
                      //   requests[index].referenceNumber,
                      //   style: TextStyle(fontWeight: FontWeight.bold),
                      // ),

                      Text(
                        requests[index].project,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Equipment requested: ' +
                            requests[index].equipmentType.description,
                      ),
                      Text(
                        'Quantity requested: ' +
                            requests[index].quantity.toString(),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),

                      Text(
                        DateFormat.yMMMMd()
                            .format(DateTime.parse(requests[index].startDate))
                            .toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),

                      SizedBox(
                        height: 10.0,
                      ),
                      requests[index].status == 'pending'
                          ? ElevatedButton(
                              onPressed: () => {
                                    setState(() {
                                      selectedRequest = requests[index].id;
                                    }),
                                    buildRequestApprovalForm(context)
                                  },
                              child: Text('Assign quantity and approve'))
                          : Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Colors.grey.shade100,
                                child: Text(requests[index]
                                    .approvedQuantity
                                    .toString()),
                              ),
                              backgroundColor: Colors.lightBlue,
                              label: const Text(
                                'approved',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: requests.length,
          )
        : loadingRequests
            ? Center(
                child: CircularProgressIndicator(
                strokeWidth: 2.0,
              ))
            : Container();
  }

  //Selectors
  buildProjectSelector(context) {
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
            child: ListSelector(
              notifyParent: projectSelected,
              context: context,
              selectedItem: monitoredProject,
              itemList: widget.assignedProjects
                  ?.map((e) =>
                      {'description': e['description'], 'id': e['description']})
                  .toList(),
            ),
          );
        });
  }

  buildShiftSelector(context) {
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
            child: Padding(
              padding: const EdgeInsets.only(top: GLOBAL_PADDING),
              child: Container(
                // height: 1000.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
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
                        child: Padding(
                          padding: const EdgeInsets.all(GLOBAL_PADDING),
                          child: GestureDetector(
                              onTap: () => {
                                    this.setState(() {
                                      monitoredProject = shifts[index].id;
                                    }),
                                    refreshMontlySummaries(),
                                    Navigator.pop(context)
                                  },
                              child: Text(shifts[index].description)),
                        ));
                  },
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: shifts.length,
                ),
              ),
            ),
          );
        });
  }

  // Screens
  buildDashboard(BuildContext context) {
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

  buildJobList(BuildContext context) {
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

  buildApprovals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopNav(context),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, bottom: 8),
          child: GestureDetector(
            onTap: () => buildProjectSelector(context),
            child: Text(
              monitoredProject,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Heading1(heading1: 'Cost to be validated'),
              IconButton(
                  onPressed: () {
                    setState(() {
                      fetchNonValidatedMonthly(monitoredProject);
                    });
                  },
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 20,
                    color: Colors.grey[600],
                  ))
            ],
          ),
        ),
        buildMonthlyData(monthlyNonValidatedSummary, 'not validated',
            loadingNonValidated, nonValidatedFound),
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
              IconButton(
                  onPressed: () {
                    setState(() {
                      fetchValidatedMonthly(monitoredProject);
                    });
                  },
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 20,
                    color: Colors.grey[600],
                  ))
            ],
          ),
        ),
        buildMonthlyData(monthlyValidatedSummary, 'validated', loadingValidated,
            validatedFound),
      ],
    );
  }

  buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopNav(context),
        const Center(
          child: Text('Settings'),
        ),
      ],
    );
  }

  buildRequestsScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GLOBAL_PADDING),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTopNav(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.userType != 'logistic-officer'
                    ? [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                                onPressed: () => {buildRequestForm(context)},
                                child: Text('New Request')),
                            IconButton(
                              icon: Icon(Icons.loop),
                              onPressed: () => fetchRequests(),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        // My requests
                        Heading1(
                          heading1: 'My requests',
                        ),
                        SizedBox(
                          height: 250,
                          child: buildRequests(),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Heading1(
                          heading1: 'Approved requests',
                        ),
                        SizedBox(
                          height: 250,
                          child: buildApprovedRequests(),
                        )
                        // SizedBox(
                        //   child:
                        //   height: 550,
                        // )
                      ]
                    : [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(),
                            IconButton(
                              icon: Icon(Icons.loop),
                              onPressed: () => fetchRequests(),
                            )
                          ],
                        ),
                        // My requests
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Heading1(
                            heading1: 'Pending Requests',
                          ),
                        ),

                        SizedBox(
                          height: 200,
                          child: buildAggregatedRequests(),
                        ),

                        SizedBox(
                          height: GLOBAL_PADDING * 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Heading1(
                            heading1: 'Approved Requests',
                          ),
                        ),

                        SizedBox(
                          height: 250,
                          child: buildApprovedRequests(),
                        )

                        // SizedBox(
                        //   child:
                        //   height: 550,
                        // )
                      ],
              ),
            ),
          )
        ],
      ),
    );
  }

  buildRequestForm(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (BuildContext bc) {
          var monitoredProject = '';
          var selectedEquipmentType = '';
          return BottomSheetForm(
              monitoredProject: monitoredProject,
              onSelectionChanged: _onSelectionChanged,
              notifyProjectChange: projectSelected,
              projectList: widget.assignedProjects,
              equipmentList: equipmentTypes,
              notifyEquipmentTypeChange: equipmentTypeSelected,
              shiftList: shifts,
              notifyShiftChange: shiftSelected,
              notifyDateRangeChange: dateRangeChange,
              notifySavedRequest: fetchRequests,
              owner: widget._id,
              workList: workList);
        });
  }

  buildRequestApprovalForm(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (BuildContext bc) {
          return FractionallySizedBox(
            heightFactor: 0.6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GLOBAL_PADDING),
              child: Padding(
                padding: const EdgeInsets.only(top: GLOBAL_PADDING),
                child: Container(
                  height: 2000.0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextLabel(lable: 'Quantity'),
                        CustomTextField(
                          valueController: quantityController,
                          iconData: Icons.file_copy,
                          inputType: TextInputType.number,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FractionallySizedBox(
                          widthFactor: 1,
                          child: ElevatedButton(
                              onPressed: () => {
                                    Navigator.pop(context),
                                    loadingRequests = true,
                                    RequestsApi.assignQuantity(selectedRequest,
                                            quantityController.text)
                                        .then((value) => {
                                              fetchRequests(),
                                              quantityController.text = ''
                                            })
                                  },
                              child: submitting
                                  ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        color: COLOR_WHITE,
                                      ),
                                    )
                                  : Text('Assign and approve quantity')),
                        ),
                      ]),
                ),
              ),
            ),
          );
        });
  }

  //Utils
  void refreshMontlySummaries() {
    fetchNonValidatedMonthly(monitoredProject);

    fetchValidatedMonthly(monitoredProject);
  }

  void fetchNonValidatedMonthly(project) {
    setState(() {
      loadingText = 'Loading data...';
      monthlyNonValidatedSummary = [];
      loadingNonValidated = true;
    });
    WorkDatasApi.getNonValidatedSummary(project).then((value) => setState(() {
          monthlyNonValidatedSummary = value;
          loadingNonValidated = false;
          if (value.isEmpty) {
            loadingText = 'No data found!';
            nonValidatedFound = false;
          } else {
            nonValidatedFound = true;
          }
        }));
  }

  void fetchReleasedMonthly(project) {
    setState(() {
      loadingText = 'Loading data...';
      monthlyReleased = [];
      loadingReleased = true;
    });
    WorkDatasApi.getMonthltReleased(project).then((value) => setState(() {
          monthlyReleased = value;
          loadingReleased = false;
          if (value.isEmpty) {
            loadingText = 'No data found!';
            releasedFound = false;
          } else {
            releasedFound = true;
          }
        }));
  }

  void fetchValidatedMonthly(project) {
    setState(() {
      loadingText = 'Loading data...';
      monthlyValidatedSummary = [];
      loadingValidated = true;
    });
    WorkDatasApi.getValidatedSummary(project).then((value) => setState(() {
          monthlyValidatedSummary = value;
          loadingValidated = false;
          if (value.isEmpty) {
            loadingText = 'No data found!';
            validatedFound = false;
          } else {
            validatedFound = true;
          }
        }));
  }

  void fetchRequests() {
    setState(() {
      loadingText = 'Loading data...';
      loadingRequests = true;
      requests = [];
      approvedRequests = [];
      loadingValidated = true;
    });

    if (widget.userType == 'customer-site-manager' ||
        widget.userType == 'customer-project-manager') {
      RequestsApi.getMyRequests(widget._id).then((value) => setState(() {
            requests =
                value.where((element) => element.status == 'pending').toList();
            loadingRequests = false;
            approvedRequests =
                value.where((element) => element.status == 'approved').toList();
          }));
    } else {
      RequestsApi.getRequestsSuggestions().then((value) => setState(() {
            requests =
                value.where((element) => element.status == 'pending').toList();
            loadingRequests = false;
            approvedRequests =
                value.where((element) => element.status == 'approved').toList();
          }));
    }
  }

  void fetchWorkList() {
    setState(() {
      loadingText = 'Loading data...';
      loadingWorkList = true;
      workList = [];
    });

    WorkDoneApi.getWorkTypeList().then((value) => setState(() {
          workList = value.toList();
          loadingWorkList = false;
        }));
  }

  void fetchAggregatedRequests() {
    setState(() {
      loadingText = 'Loading data...';
      loadingRequests = true;
      requests = [];
      approvedRequests = [];
      loadingValidated = true;
    });

    RequestsApi.getAggregatedRequests('pending').then((value) => setState(() {
          loadingRequests = false;
          aggregatedRequests = value.toList();
        }));
  }

  void projectSelected(value) {
    setState(() {
      monitoredProject = value['description'];
      refresh();
    });
  }

  void equipmentTypeSelected(value) {
    setState(() {
      selectedEquipmentType = value;
    });
  }

  void shiftSelected(value) {
    setState(() {
      selectedShift = value;
    });
  }

  void dateRangeChange(startDate, endDate) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
    });
  }

  void fetchEquipmentTypes() {
    setState(() {
      loadingText = 'Loading data...';
      requests = [];
      loadingValidated = true;
    });

    EquipmentTypesApi.getEquipmentTypes().then((value) => setState(() {
          equipmentTypes = value;
        }));
  }
}

class Heading1 extends StatelessWidget {
  const Heading1({
    Key? key,
    required this.heading1,
  }) : super(key: key);

  final String heading1;

  @override
  Widget build(BuildContext context) {
    return Text(
      heading1,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class Owner {
  final String value;
  final String text;

  const Owner({required this.value, required this.text});
}
