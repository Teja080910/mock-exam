import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'category_detail_page_widget.dart' show CategoryDetailPageWidget;
import 'dart:async';
import 'package:flutter/material.dart';

class CategoryDetailPageModel
    extends FlutterFlowModel<CategoryDetailPageWidget> {
  ///  State fields for stateful widgets in this page.

  bool apiRequestCompleted = false;
  String? apiRequestLastUniqueKey;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// Additional helper methods.
  Future waitForApiRequestCompleted({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = apiRequestCompleted;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
