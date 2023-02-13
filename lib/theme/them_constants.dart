// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

const COLOR_PRIMARY = Colors.black;
const COLOR_ACCENT = Color.fromARGB(255, 252, 164, 32);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.grey[100],
  primaryColor: COLOR_PRIMARY,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: COLOR_ACCENT,
      backgroundColor: Colors.grey[100],
      elevation: 0.0),
  accentColor: COLOR_ACCENT,
  fontFamily: 'Nunito',
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(COLOR_ACCENT),
      shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
    ),
  ),
);

ThemeData darkTheme = ThemeData(brightness: Brightness.dark);
