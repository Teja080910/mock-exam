import '/componants/app_bar/app_bar_model.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'my_subscription_screen_widget.dart' show MySubscriptionScreenWidget;
import 'package:flutter/material.dart';

class MySubscriptionScreenModel extends FlutterFlowModel<MySubscriptionScreenWidget> {
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
