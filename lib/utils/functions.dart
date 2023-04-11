import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

String? token = '';

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

handleNotifications() async {
  // await Firebase.initializeApp();
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Got a message whilst in the foreground!');
  //   print('Message data: ${message.data}');

  //   if (message.notification != null) {
  //     print('Message also contained a notification: ${message.notification}');
  //   }
  // });

  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  // FirebaseMessaging messaging = FirebaseMessaging.instance;

  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );
  // print('User granted permission: ${settings.authorizationStatus}');
  // token = await messaging.getToken(
  //     vapidKey: "AIzaSyDUebe2JDnqvql7-D9lHcD-8rhgp6J1xVk");

  // print("Handling a background message: ${message.messageId}");
}

getToken() async {
  // await Firebase.initializeApp();
  // FirebaseMessaging messaging = FirebaseMessaging.instance;

  // return await messaging.getToken(
  //     vapidKey: "AIzaSyDUebe2JDnqvql7-D9lHcD-8rhgp6J1xVk");
}
