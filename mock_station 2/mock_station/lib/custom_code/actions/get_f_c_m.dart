// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> getFCM() async {
  // try {
  //  String? token = await FirebaseMessaging.instance.getToken();
  //  if (token != null) {
  //   FFAppState().tokenFcm = token;
  //    print("FCM Token retrieved: $token");
  //   log("FCM Token stored in FFAppState: ${FFAppState().tokenFcm}");
  //   } else {
  //    print("FCM token is null");
  //  }
  // } catch (e) {
  //  print("Error retrieving FCM token: $e");
  // }
  try {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    String token = await fcm.getToken() ?? "";
    print("FCM Token: $token");

    FFAppState().tokenFcm = token!;
    return token;
  } catch (e) {
    print("Error getting FCM token: $e");
    return null;
  }
  // final FirebaseMessaging fcm = FirebaseMessaging.instance;
//  String token = await fcm.getToken() ?? "";
//  print("FCM Token: $token");

//  FFAppState().tokenFcm = token;
  // return token;
}
