import '/backend/api_requests/api_calls.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'payment_screen_widget.dart' show PaymentScreenWidget;
import 'package:flutter/material.dart';

class PaymentScreenModel extends FlutterFlowModel<PaymentScreenWidget> {
  ///  Local state fields for this page.

  int? selectPayment = 0;

  ///  State fields for stateful widgets in this page.

  // Model for appBar component.
  late AppBarModel appBarModel;
  // Stores action output result for [Backend Call - API (Buy Plan)] action in Button widget.
  ApiCallResponse? planResCopy;
  // Stores action output result for [Backend Call - API (AddPointsApi)] action in Button widget.
  ApiCallResponse? apiResultxs;
  // Stores action output result for [Backend Call - API (planHistoryAPI)] action in Button widget.
  ApiCallResponse? planHis;
  // Stores action output result for [Backend Call - API (Buy Plan)] action in Button widget.
  ApiCallResponse? planResCopy2;
  // Stores action output result for [Backend Call - API (AddPointsApi)] action in Button widget.
  ApiCallResponse? apiResultx;
  // Stores action output result for [Backend Call - API (planHistoryAPI)] action in Button widget.
  ApiCallResponse? his;

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
  }

  @override
  void dispose() {
    appBarModel.dispose();
  }
}
