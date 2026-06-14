import '/componants/app_bar/app_bar_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'plans_screen_widget.dart' show PlansScreenWidget;
import 'package:flutter/material.dart';

class PlansScreenModel extends FlutterFlowModel<PlansScreenWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for AppBar component.
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
