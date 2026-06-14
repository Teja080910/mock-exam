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

import 'index.dart'; // Imports other custom actions

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

import 'dart:async';
import 'dart:convert';

import 'notification_init.dart';

import 'package:intl/intl.dart';

import 'dart:io' show Platform;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseInit() async {
  try {
    await Firebase.initializeApp();
    
    // Initialize Firebase Messaging
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

    // Handle background messages
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

    // Get FCM token
  FirebaseMessaging.instance.getToken().then((token) {
      debugPrint('FCM Token: $token');
  });

    // Handle foreground messages
  FirebaseMessaging.onMessage.listen((event) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${event.data}');
      if (event.notification != null) {
        debugPrint('Message also contained a notification: ${event.notification}');
      }
  });

    // Handle when app is opened from notification
  FirebaseMessaging.onMessageOpenedApp.listen((event) {});

    // Check if app was opened from notification
  FirebaseMessaging.instance.getInitialMessage().then((value) {});

    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }
}

Future<void> backgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title ?? 'New Notification',
    message.notification?.body ?? '',
    notificationDetails,
  );
}

void _configureDidReceiveLocalNotificationSubject(RemoteMessage message) {
  _showNotification(message);
}

Future<void> _configureSelectNotificationSubject(RemoteMessage message) async {
  await _showNotification(message);
}
