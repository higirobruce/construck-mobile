// ignore_for_file: unnecessary_const

import 'package:mobile2/api/equipments_api.dart';
import 'package:mobile2/api/projects_api.dart';
import 'package:mobile2/api/reasons_api.dart';
import 'package:mobile2/api/user_api.dart';
import 'package:mobile2/api/workData_api.dart';
import 'package:mobile2/api/workDone_api.dart';
import 'package:mobile2/screens/login.dart';
import 'package:mobile2/screens/success.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:date_range_form_field/date_range_form_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainScreen extends StatefulWidget {
  final String? userId;
  final String? name;
  const MainScreen(this.userId, this.name, {Key? key}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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

  final storage = new FlutterSecureStorage();

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
  bool? dayShift = true;
  bool? machineDispatch = false;
  bool? siteWork = false;
  bool durationIsLess = false;
  bool tripsAreLess = false;

  List reasons = List.empty();
  List<WorkData>? forms = List.empty();

  DateTimeRange movementDateRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  DateTimeRange workDateRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  Object? _mySelection;

  String loadingText = 'Loading data...';

  void _setDurationCheck() {
    print(_duration!.text);
    setState(() {
      _duration!.text.isNotEmpty
          ? int.parse(_duration!.text) < 5
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

    ReasonApi.getReasonSuggestion('').then((value) => setState(() {
          reasons = value;
          if (reasons.isEmpty) {
            loadingText = 'No data found!';
          }
          _mySelection = value[0].descriptionRw;
        }));
    WorkDatasApi.getWorkData(widget.userId).then((value) => setState(() {
          forms = value;
        }));

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
    });
    return WorkDatasApi.getWorkData(widget.userId).then((value) => setState(() {
          forms = value;
          if (value.isEmpty) {
            loadingText = 'No data found!';
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      // SingleChildScrollView(
      //   child: Padding(
      //     padding: const EdgeInsets.only(bottom: 16.0),
      //     child: Form(
      //       child: Padding(
      //         padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      //         child: Column(
      //           children: [
      //             //Shift
      //             CheckboxListTile(
      //                 title: Text('Day shift'),
      //                 value: dayShift,
      //                 onChanged: (bool? newval) => {
      //                       setState(() {
      //                         dayShift = newval;
      //                       })
      //                     }),
      //             //Machine Dispatch
      //             // CheckboxListTile(
      //             //     title: Text('Machine dispatch'),
      //             //     value: machineDispatch,
      //             //     onChanged: (bool? newval) => {
      //             //           setState(() {
      //             //             machineDispatch = newval;
      //             //           })
      //             //         }),
      //             //Site work
      //             // CheckboxListTile(
      //             //     title: Text('Site work'),
      //             //     value: siteWork,
      //             //     onChanged: (bool? newval) => {
      //             //           setState(() {
      //             //             siteWork = newval;
      //             //           })
      //             //         }),

      //             //Lowbed
      //             _buildLowbed(),

      //             //lowbed Dricer
      //             _buildLowbedDriver(),

      //             //Project
      //             _buildProject(),

      //             //Date
      //             _buildMovementDate(),

      //             //Machine to move
      //             _buildMachineToMove(),

      //             //Driver
      //             _buildOperator(),

      //             //Job type
      //             _buildJobType(),

      //             //Workdates
      //             _buildWorkDates(),

      //             //Start Index
      //             Padding(
      //               padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      //               child: TextFormField(
      //                 controller: _startIndex,
      //                 decoration: const InputDecoration(
      //                     // prefixIcon: Icon(Icons.question_mark),
      //                     labelText: 'Start Index'),
      //               ),
      //             ),

      //             //Submit Button
      //             submitting
      //                 ? CircularProgressIndicator()
      //                 : ElevatedButton(
      //                     onPressed: () {
      //                       // print(workDateRange.start);

      //                       //Machine work
      //                       setState(() {
      //                         submitting = true;
      //                       });
      //                       WorkDatasApi.saveWorkData(
      //                         project,
      //                         machineToMove,
      //                         workDone.jobId,
      //                         _startIndex.text,
      //                         '0',
      //                         '0',
      //                         ' ',
      //                         driver.userId,
      //                         workDateRange.start,
      //                         workDateRange.end,
      //                         'yes',
      //                       ).then((value) => {
      //                             WorkDatasApi.saveWorkData(
      //                               project,
      //                               lowbed,
      //                               "62690b97cf45ad62aa6144e2",
      //                               '0',
      //                               '0',
      //                               '0',
      //                               ' ',
      //                               lowbedDriver.userId,
      //                               movementDateRange.start,
      //                               movementDateRange.end,
      //                               'no',
      //                             ).then(
      //                               (value) => setState(() {
      //                                 currentIndex = 1;
      //                                 submitting = false;
      //                               }),
      //                             ),
      //                           });
      //                     },
      //                     child: Text('Submit'),
      //                   )
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      Column(
        children: [
          SizedBox(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shabika App.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.name!,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () async {
                            await storage.deleteAll();
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Login(),
                              ),
                            );
                          },
                          icon: Icon(Icons.logout, size: 20))
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            // child: FutureBuilder<List<WorkData>>(
            //   future: WorkDatasApi.getWorkData(widget.userId),
            //   builder: (context, jobSnap) {
            //     final jobs = jobSnap.data;
            //     switch (jobSnap.connectionState) {
            //       case ConnectionState.waiting:
            //         return (Center(
            //           child: CircularProgressIndicator(),
            //         ));
            //       default:
            //         if (jobSnap.hasError) {
            //           return Center(
            //             child: Text(jobSnap.error.toString()),
            //           );
            //         } else {
            //           return buildJobs(jobs);
            //         }
            //     }
            //   },
            // ),
            child: forms!.length == 0
                ? Center(child: Text(loadingText))
                : buildJobs(forms),
          ),
        ],
      ),
      const Center(
        child: Text('Settings'),
      ),
    ];

    const bottomNavigationBarItem = BottomNavigationBarItem(
      icon: Icon(Icons.file_copy),
      label: 'Data',
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

    return Scaffold(
      // appBar: AppBar(title: Text('Shabika App')),
      // backgroundColor: Colors.amber[100],
      body: RefreshIndicator(
          onRefresh: refresh, child: SafeArea(child: screens[currentIndex])),
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
          items: [
            // bottomNavigationBarItem,
            bottomNavigationBarItem2,
            bottomNavigationBarItem3,
          ]),
    );
  }

  Padding _buildProject() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: TypeAheadFormField(
        debounceDuration: const Duration(milliseconds: 500),
        hideSuggestionsOnKeyboardHide: false,
        textFieldConfiguration: TextFieldConfiguration(
          controller: _projectController,
          decoration: const InputDecoration(
              // prefixIcon: Icon(Icons.question_mark),
              labelText: 'To Project'),
        ),
        onSuggestionSelected: (Project suggestion) {
          _projectController.text = suggestion.prjDescription;
          project = suggestion;
        },
        itemBuilder: (context, Project? suggestion) {
          final project = suggestion!;

          return ListTile(
            title: Text(project.prjDescription),
          );
        },
        suggestionsCallback: ProjectsApi.getUserSuggestions,
        noItemsFoundBuilder: (context) => Container(
          height: 80,
          child: const Center(
            child: Text(
              'Nta project ibonetse.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  DateRangeField _buildMovementDate() {
    return DateRangeField(
        firstDate: DateTime(1990),
        enabled: true,
        initialValue: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
        decoration: InputDecoration(
          labelText: "Movement Date",
          prefixIcon: Icon(Icons.date_range),
          hintText: 'Please select start and end dates.',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value!.start.isBefore(DateTime.now())) {
            return 'Please select start date.';
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            movementDateRange = value!;
          });
        });
  }

  DateRangeField _buildWorkDates() {
    return DateRangeField(
        firstDate: DateTime(1990),
        enabled: true,
        initialValue: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
        decoration: InputDecoration(
          labelText: "Work Dates",
          prefixIcon: Icon(Icons.date_range),
          hintText: 'Please select start and end dates.',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value!.start.isBefore(DateTime.now())) {
            return 'Please select start date.';
          }
          return null;
        },
        onChanged: (value) {
          print(value);
          setState(() {
            workDateRange = value!;
          });
        },
        onSaved: (value) {});
  }

  Padding _buildMachineToMove() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
      ),
      child: TypeAheadFormField(
        // direction: AxisDirection.down,
        debounceDuration: const Duration(milliseconds: 500),
        hideSuggestionsOnKeyboardHide: false,
        textFieldConfiguration: TextFieldConfiguration(
          controller: _equipmentController,
          decoration: const InputDecoration(
              // prefixIcon: Icon(Icons.question_mark),
              labelText: 'Machine to Move'),
        ),
        onSuggestionSelected: (Equipment suggestion) {
          _equipmentController.text = suggestion.plateNumber;
          machineToMove = suggestion;
        },
        itemBuilder: (context, Equipment? suggestion) {
          final equipment = suggestion!;

          return ListTile(
            title: Text(equipment.plateNumber),
          );
        },
        suggestionsCallback: EquipmentsApi.getEquipmentSuggestions,
        noItemsFoundBuilder: (context) => Container(
          height: 80,
          child: const Center(
            child: Text(
              'No equipment found!',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildLowbed() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
      ),
      child: TypeAheadFormField(
        // direction: AxisDirection.down,
        debounceDuration: const Duration(milliseconds: 500),
        hideSuggestionsOnKeyboardHide: false,
        textFieldConfiguration: TextFieldConfiguration(
          controller: _lowbedController,
          decoration: const InputDecoration(
              // prefixIcon: Icon(Icons.question_mark),
              labelText: 'Lowbed'),
        ),
        onSuggestionSelected: (Equipment suggestion) {
          _lowbedController.text = suggestion.plateNumber;
          lowbed = suggestion;
        },
        itemBuilder: (context, Equipment? suggestion) {
          final equipment = suggestion!;

          return ListTile(
            title: Text(equipment.plateNumber),
          );
        },
        suggestionsCallback: EquipmentsApi.getLowbedSuggestions,
        noItemsFoundBuilder: (context) => Container(
          height: 80,
          child: const Center(
            child: Text(
              'No lowbed found!',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildJobType() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: TypeAheadFormField(
        // direction: AxisDirection.down,
        debounceDuration: const Duration(milliseconds: 500),
        hideSuggestionsOnKeyboardHide: false,
        textFieldConfiguration: TextFieldConfiguration(
          controller: _workDoneController,
          decoration: const InputDecoration(
              // prefixIcon: Icon(Icons.question_mark),
              labelText: 'Job type'),
        ),
        onSuggestionSelected: (WorkDone suggestion) {
          _workDoneController.text = suggestion.jobDescription;
          workDone = suggestion;
        },
        itemBuilder: (context, WorkDone? suggestion) {
          final workDone = suggestion!;

          return ListTile(
            title: Text(workDone.jobDescription),
          );
        },
        suggestionsCallback: WorkDoneApi.getWorkDoneSuggestion,
        noItemsFoundBuilder: (context) => Container(
          height: 80,
          child: const Center(
            child: Text(
              'No options found!',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildLowbedDriver() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
      ),
      child: TypeAheadFormField(
        // direction: AxisDirection.down,
        debounceDuration: const Duration(milliseconds: 500),
        hideSuggestionsOnKeyboardHide: false,
        textFieldConfiguration: TextFieldConfiguration(
          controller: _lowbedDriverController,
          decoration: const InputDecoration(
              // prefixIcon: Icon(Icons.question_mark),
              labelText: 'Lowbed Driver'),
        ),
        onSuggestionSelected: (User suggestion) {
          _lowbedDriverController.text =
              suggestion.firstName + ' ' + suggestion.lastName;
          lowbedDriver = suggestion;
        },
        itemBuilder: (context, User? suggestion) {
          final driver = suggestion!;

          return ListTile(
            title: Text(driver.firstName + " " + driver.lastName),
          );
        },
        suggestionsCallback: UserApi.getUsers,
        noItemsFoundBuilder: (context) => Container(
          height: 80,
          child: const Center(
            child: Text(
              'No driver found!',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildOperator() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
      ),
      child: TypeAheadFormField(
        // direction: AxisDirection.down,
        debounceDuration: const Duration(milliseconds: 500),
        hideSuggestionsOnKeyboardHide: false,
        textFieldConfiguration: TextFieldConfiguration(
          controller: _driverController,
          decoration: const InputDecoration(
              // prefixIcon: Icon(Icons.question_mark),
              labelText: 'Machine Operator'),
        ),
        onSuggestionSelected: (User suggestion) {
          _driverController.text =
              suggestion.firstName + ' ' + suggestion.lastName;
          driver = suggestion;
        },
        itemBuilder: (context, User? suggestion) {
          final driver = suggestion!;

          return ListTile(
            title: Text(driver.firstName + " " + driver.lastName),
          );
        },
        suggestionsCallback: UserApi.getUsers,
        noItemsFoundBuilder: (context) => Container(
          height: 80,
          child: const Center(
            child: Text(
              'No driver found!',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildJobs(List<WorkData>? jobs) => ListView.builder(
        itemBuilder: (context, index) {
          final job = jobs![index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Card(
              // color: Colors.amber[50],
              child: ListTile(
                  // title: Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [],
                  // ),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.dispatchDate +
                            ' ' +
                            job.shift +
                            ' ' +
                            job.prj.prjDescription),
                        SizedBox(
                          height: 5,
                        ),
                        if (job.siteWork == true)
                          Text(
                            'sw',
                            style: TextStyle(
                                color: Color.fromARGB(134, 158, 38, 38),
                                fontWeight: FontWeight.bold,
                                fontSize: 10.0),
                          ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          job.equipment!.eqDescription +
                              '-' +
                              job.equipment!.plateNumber,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(job.workDone!.jobDescription),
                        SizedBox(
                          height: 5,
                        ),
                        if (job.equipment!.eqType == 'Truck')
                          Text(
                            'Target trips: ' + job.targetTrips,
                            style: TextStyle(
                              color: Color.fromARGB(135, 20, 20, 20),
                            ),
                          ),
                        SizedBox(
                          height: 5,
                        ),
                      ]),
                  trailing: job.status == 'in progress'
                      ? IconButton(
                          onPressed: () => {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                        builder: (context, setState) =>
                                            AlertDialog(
                                          title: Text('Gusoza akazi'),
                                          content: Form(
                                            key: _formKeyEnd,
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextFormField(
                                                    controller: _endIndex,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          "Kilometraje nyuma y'akazi",
                                                      prefixIcon:
                                                          Icon(Icons.login),
                                                    ),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Andika Kilometraje zisoza';
                                                      } else if (int.parse(
                                                              value) <
                                                          job.startIndex) {
                                                        return 'Izisoza ni nto kuzo watangiranye akazi!';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  TextFormField(
                                                    controller: _duration,
                                                    onChanged: (value) {
                                                      if (value.isNotEmpty &&
                                                          int.parse(value) <
                                                              5) {
                                                        setState(
                                                          () => {
                                                            durationIsLess =
                                                                true
                                                          },
                                                        );
                                                      } else {
                                                        setState(
                                                          () => {
                                                            durationIsLess =
                                                                false,
                                                          },
                                                        );
                                                      }
                                                    },
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          'Amasaha akazi katwaye',
                                                      prefixIcon:
                                                          Icon(Icons.timelapse),
                                                    ),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Andika amasaha akazi katwaye';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  if (job.equipment!.eqType ==
                                                      'Truck')
                                                    TextFormField(
                                                      controller: _tripsDone,
                                                      onChanged: (value) {
                                                        if (value.isNotEmpty &&
                                                            int.parse(value) <
                                                                int.parse(job
                                                                    .targetTrips)) {
                                                          setState(
                                                            () => {
                                                              tripsAreLess =
                                                                  true
                                                            },
                                                          );
                                                        } else {
                                                          setState(
                                                            () => {
                                                              tripsAreLess =
                                                                  false,
                                                            },
                                                          );
                                                        }
                                                      },
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText:
                                                            "Umubare w'Ingendo wakoze",
                                                        prefixIcon: Icon(Icons
                                                            .threesixty_sharp),
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
                                                        items:
                                                            reasons.map((item) {
                                                          return new DropdownMenuItem(
                                                            child: new Text(item
                                                                .descriptionRw),
                                                            value: item
                                                                .descriptionRw,
                                                          );
                                                        }).toList(),
                                                        onChanged: (newVal) {
                                                          setState(() {
                                                            _mySelection =
                                                                newVal;
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
                                                child: Text('GUSUBIRA INYUMA')),
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
                                                                : '')
                                                        .then(
                                                      (value) => refresh(),
                                                    ),
                                                  },
                                              },
                                              child: Text("OHEREZA"),
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
                                            title: Text('Gutangira akazi'),
                                            content: Form(
                                              key: _formKeyStart,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextFormField(
                                                    controller: _startIndex,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          'Kilometraje utangiranye',
                                                      prefixIcon:
                                                          Icon(Icons.login),
                                                    ),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Andika kilometraje utangiranye';
                                                      } else if (int.parse(
                                                              value) <
                                                          job.millage) {
                                                        return "Ni nke kuz'iheruka";
                                                      }
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
                                                  child:
                                                      Text('GUSUBIRA INYUMA')),
                                              TextButton(
                                                onPressed: () => {
                                                  if (_formKeyStart
                                                      .currentState!
                                                      .validate())
                                                    {
                                                      this.setState(() {
                                                        forms = List.empty();
                                                      }),
                                                      Navigator.pop(context),
                                                      WorkDatasApi.startJob(
                                                              job.jobId,
                                                              _startIndex.text)
                                                          .then(
                                                        (value) =>
                                                            this.setState(
                                                          () => {
                                                            _duration!.text =
                                                                '',
                                                            refresh()
                                                          },
                                                        ),
                                                      ),
                                                    }
                                                },
                                                child: Text("OHEREZA"),
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
                                  ? Icon(
                                      Icons.hourglass_bottom,
                                    )
                                  : Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    )),
            ),
          );
        },
        physics: BouncingScrollPhysics(),
        itemCount: jobs!.length,
      );
}
