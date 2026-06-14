// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:timer_count_down/timer_count_down.dart';

class StopwatchWidget extends StatefulWidget {
  final int durationInSecond;
  final int durationInMinute;
  final double width;
  final double height;

  StopwatchWidget(
      {required this.durationInSecond,
      required this.width,
      required this.height,
      required this.durationInMinute});

  @override
  _StopwatchWidgetState createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Countdown(
      build: (BuildContext context, double time) => Text(
        time.toString(),
        style: TextStyle(fontSize: 18),
      ),
      interval: Duration(seconds: 1),
      onFinished: () {
        print('Timer is done!');
      },
      seconds: widget.durationInSecond ~/ 60,
    );
  }
}
