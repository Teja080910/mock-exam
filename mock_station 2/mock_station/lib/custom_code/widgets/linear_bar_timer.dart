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

import 'package:linear_timer/linear_timer.dart';

class LinearBarTimer extends StatefulWidget {
  const LinearBarTimer({super.key, this.width, this.height, this.time});

  final double? width;
  final double? height;
  final int? time;

  @override
  State<LinearBarTimer> createState() => _LinearBarTimerState();
}

class _LinearBarTimerState extends State<LinearBarTimer> {
  @override
  Widget build(BuildContext context) {
    return LinearTimer(
      forward: false,
      duration: Duration(milliseconds: widget.time!),
      color: FlutterFlowTheme.of(context).primary,
      backgroundColor: FlutterFlowTheme.of(context).alternate,
      onTimerEnd: () {
        print("timer ended");
      },
    );
  }
}
