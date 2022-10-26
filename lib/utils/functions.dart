import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

Padding buildInfoTile(title, icon, value, loading) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    child: Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                icon,
                loading
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black54,
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Container buildDateRange(showDateRange, _onSelectionChanged) {
  return showDateRange == true
      ? Container(
          child: SfDateRangePicker(
            view: DateRangePickerView.year,
            selectionMode: DateRangePickerSelectionMode.range,
            onSelectionChanged: _onSelectionChanged,
          ),
        )
      : Container(
          child: null,
        );
}
