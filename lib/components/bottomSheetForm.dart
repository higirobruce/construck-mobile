// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:mobile2/api/equipmentTypes.dart';
import 'package:mobile2/api/requests_api.dart';
import 'package:mobile2/api/workDone_api.dart';
import 'package:mobile2/components/bottomSheetDataSelector.dart';
import 'package:mobile2/components/customTextField.dart';
import 'package:mobile2/screens/login.dart';
import 'package:mobile2/screens/mainScreen.dart';
import 'package:mobile2/theme/them_constants.dart';
import 'package:mobile2/utils/functions.dart';
import 'package:mobile2/utils/types.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:intl/intl.dart';

class BottomSheetForm extends StatefulWidget {
  final monitoredProject;
  final onSelectionChanged;
  final notifyProjectChange;
  final notifyEquipmentTypeChange;
  final notifyShiftChange;
  final notifyDateRangeChange;
  final List<dynamic>? projectList;
  final List<EquipmentType> equipmentList;
  final notifySavedRequest;
  final List<ShiftType> shiftList;
  final owner;
  final List<WorkDone> workList;

  const BottomSheetForm(
      {Key? key,
      required this.monitoredProject,
      required this.onSelectionChanged,
      required this.notifyProjectChange,
      required this.projectList,
      required this.equipmentList,
      required this.notifyEquipmentTypeChange,
      required this.shiftList,
      required this.notifyShiftChange,
      required this.notifyDateRangeChange,
      required this.notifySavedRequest,
      required this.owner,
      required this.workList})
      : super(key: key);

  @override
  State<BottomSheetForm> createState() => _BottomSheetFormState();
}

class _BottomSheetFormState extends State<BottomSheetForm> {
  final requestFormKey = GlobalKey<FormState>();
  TextEditingController quantityController = TextEditingController();
  TextEditingController tripsController = TextEditingController();
  TextEditingController nozaPRNumberController = TextEditingController();
  TextEditingController tripFrom = TextEditingController();
  TextEditingController tripTo = TextEditingController();
  dynamic selectedProject = {'description': '', 'id': ''};
  dynamic selectedEquipmentType = {'description': '', 'id': ''};
  dynamic selectedShift = {'description': '', 'id': ''};
  dynamic selectedWork = {'description': '', 'id': ''};

  var showDateRange = false;
  var submitting = false;
  String _startDate = "2022-08-01";

  String _endDate = "2022-08-31";
  String _range = '01-Aug-2022 - 31-Aug-2022';

  String _selectedDate = '';
  String _dateCount = '';
  String _rangeCount = '';

  void projectSelected(dynamic value) {
    setState(() {
      selectedProject = value;
      widget.notifyProjectChange(value);
    });
  }

  void equipmentTypeSelected(dynamic value) {
    setState(() {
      selectedEquipmentType = value;
      widget.notifyEquipmentTypeChange(value['id']);
    });
  }

  void shiftSelected(dynamic value) {
    setState(() {
      selectedShift = value;
      widget.notifyEquipmentTypeChange(value['id']);
    });
  }

  void workSelected(dynamic value) {
    setState(() {
      selectedWork = value;
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
            child: ListSelector(
              notifyParent: shiftSelected,
              context: context,
              selectedItem: selectedShift,
              itemList: widget.shiftList
                  .map((e) => {'description': e.description, 'id': e.id})
                  .toList(),
            ),
          );
        });
  }

  buildWorkSelector(context) {
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
              notifyParent: workSelected,
              context: context,
              selectedItem: selectedWork,
              itemList: widget.workList
                  .map((e) => {'description': e.description, 'id': e.id})
                  .toList(),
            ),
          );
        });
  }

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
              selectedItem: widget.monitoredProject,
              itemList: widget.projectList
                  ?.map((p) =>
                      {'description': p['description'], 'id': p['description']})
                  .toList(),
            ),
          );
        });
  }

  buildEquipmentTypeSelector(context) {
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
                child: ListSelector(
                  context: context,
                  itemList: widget.equipmentList
                      .map((e) => {'description': e.description, 'id': e.id})
                      .toList(),
                  notifyParent: equipmentTypeSelected,
                  selectedItem: selectedEquipmentType,
                )),
          );
        });
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('dd-MMM-yyyy').format(args.value.startDate)} -'
            // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd-MMM-yyyy').format(args.value.endDate ?? args.value.startDate)}';
        _startDate = '${DateFormat('yyyy-MM-dd').format(args.value.startDate)}';

        _endDate =
            '${DateFormat('yyyy-MM-dd').format(args.value.endDate ?? args.value.startDate)}';

        if (args.value.endDate != null) {
          showDateRange = false;
          widget.notifyDateRangeChange(_startDate, _endDate);
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

  void submitRequest(context) {
    // print(selectedEquipmentType['id']);
    setState(() {
      submitting = true;
      RequestsApi.saveRequest(
              nozaPRNumberController.text,
              selectedEquipmentType['id'],
              quantityController.text,
              _startDate,
              _endDate,
              selectedShift['id'],
              selectedProject['id'],
              widget.owner,
              selectedWork['id'],
              tripsController.text,
              tripFrom.text,
              tripTo.text)
          .then((value) => {
                Navigator.pop(context),
                widget.notifySavedRequest(),
                submitting = false
              });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.94,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GLOBAL_PADDING),
        child: Padding(
          padding: const EdgeInsets.only(top: GLOBAL_PADDING),
          child: SizedBox(
            height: 2500.0,
            child: SingleChildScrollView(
              child: Form(
                key: requestFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: GLOBAL_PADDING, bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextLabel(
                              lable: 'Noza Purchase Reference Number'),
                          CustomTextField(
                            valueController: nozaPRNumberController,
                            iconData: Icons.file_copy,
                            inputType: TextInputType.text,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          SECONDARY_COLOR)),
                              onPressed: () =>
                                  {buildEquipmentTypeSelector(context)},
                              child: selectedEquipmentType['description']
                                      .isNotEmpty
                                  ? Text(selectedEquipmentType['description'])
                                  : Text('Select type of equipment')),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextLabel(lable: 'Quantity'),
                          CustomTextField(
                            valueController: quantityController,
                            iconData: Icons.production_quantity_limits,
                            inputType: TextInputType.number,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        SECONDARY_COLOR)),
                            onPressed: () => {buildWorkSelector(context)},
                            child: selectedWork['description'].isNotEmpty
                                ? Text(selectedWork['description'])
                                : Text('Select work to be done'),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextLabel(lable: 'Trips to be made'),
                          CustomTextField(
                            valueController: tripsController,
                            iconData: Icons.production_quantity_limits,
                            inputType: TextInputType.number,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextLabel(lable: 'From'),
                          CustomTextField(
                            valueController: tripFrom,
                            iconData: Icons.location_city_rounded,
                            inputType: TextInputType.text,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextLabel(lable: 'To'),
                          CustomTextField(
                            valueController: tripTo,
                            iconData: Icons.location_city_rounded,
                            inputType: TextInputType.text,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            SECONDARY_COLOR)),
                                onPressed: () =>
                                    {buildProjectSelector(context)},
                                child: selectedProject['description'].isNotEmpty
                                    ? Text(selectedProject['description'])
                                    : Text('Select project'),
                              ),
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              SECONDARY_COLOR)),
                                  onPressed: () =>
                                      {buildShiftSelector(context)},
                                  child: selectedShift['description'].isNotEmpty
                                      ? Text(selectedShift['description'])
                                      : Text('Select shift')),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CustomTextLabel(lable: 'Dispatch date'),
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
                          buildDateRange(showDateRange, _onSelectionChanged),
                        ],
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 1,
                      child: ElevatedButton(
                          onPressed: () => {
                                if (requestFormKey.currentState!.validate())
                                  {submitRequest(context)},
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
                              : Text('Send request')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
