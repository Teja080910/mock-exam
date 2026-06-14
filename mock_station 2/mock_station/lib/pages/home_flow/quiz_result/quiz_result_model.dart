import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'quiz_result_widget.dart' show QuizResultWidget;
import 'package:flutter/material.dart';

class QuizResultModel extends FlutterFlowModel<QuizResultWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (StartquizApi)] action in quiz_result widget.
  ApiCallResponse? startquizres;
  // Stores action output result for [Backend Call - API (AddPointsApi)] action in Button widget.
  ApiCallResponse? addPointsRes;
  // Stores action output result for [Backend Call - API (planHistoryAPI)] action in Button widget.
  ApiCallResponse? planRes;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
