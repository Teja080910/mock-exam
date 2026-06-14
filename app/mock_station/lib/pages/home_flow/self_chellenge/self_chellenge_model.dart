import '/backend/api_requests/api_calls.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'self_chellenge_widget.dart' show SelfChellengeWidget;
import 'package:flutter/material.dart';

class SelfChellengeModel extends FlutterFlowModel<SelfChellengeWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Model for appBar component.
  late AppBarModel appBarModel;
  // Stores action output result for [Backend Call - API (GetpointssettingApi)] action in Button widget.
  ApiCallResponse? getPointsRes;

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
  }

  @override
  void dispose() {
    appBarModel.dispose();
  }
}
