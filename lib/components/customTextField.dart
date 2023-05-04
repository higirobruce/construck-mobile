import 'package:mobile2/api/user_api.dart';
import 'package:mobile2/screens/mainScreen.dart';
import 'package:mobile2/screens/success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile2/utils/functions.dart';
import 'dart:convert';

const double HORIZONTAL_PADDING = 15.0;
const double BORDER_SIZE = 12;

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {Key? key,
      required this.valueController,
      required this.iconData,
      required this.inputType})
      : super(key: key);

  final TextEditingController valueController;
  final IconData iconData;
  final TextInputType inputType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(BORDER_SIZE)),
      child: Padding(
        padding: const EdgeInsets.only(left: HORIZONTAL_PADDING),
        child: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: Icon(
              iconData,
              size: 18,
              // color: Theme.of(context).accentColor,
            ),
          ),
          controller: valueController,
          keyboardType: inputType,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Can not be empty';
            }
            return null;
          },
        ),
      ),
    );
  }
}
