import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'quiz_review_screen_widget.dart' show QuizReviewScreenWidget;
import 'package:flutter/material.dart';

class QuizReviewScreenModel extends FlutterFlowModel<QuizReviewScreenWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for appBar component.
  late AppBarModel appBarModel;
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
  }

  @override
  void dispose() {
    appBarModel.dispose();
    tabBarController?.dispose();
  }
}
