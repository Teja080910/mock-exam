import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'completedquizzes_screen_detail_widget.dart'
    show CompletedquizzesScreenDetailWidget;
import 'package:flutter/material.dart';

class CompletedquizzesScreenDetailModel
    extends FlutterFlowModel<CompletedquizzesScreenDetailWidget> {
  ///  Local state fields for this page.

  bool isLoading = true;

  ///  State fields for stateful widgets in this page.

  // Model for appBar component.
  late AppBarModel appBarModel;

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
  }

  @override
  void dispose() {
    appBarModel.dispose();
  }
}
