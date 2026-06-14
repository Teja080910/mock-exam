import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'quizquestions_screen_copy_widget.dart'
    show QuizquestionsScreenCopyWidget;
import 'package:flutter/material.dart';

class QuizquestionsScreenCopyModel
    extends FlutterFlowModel<QuizquestionsScreenCopyWidget> {
  ///  Local state fields for this page.

  String? userAnswer;

  String? actualAnswer;

  bool isLoading = true;

  bool isTimerPlayed = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetquestionsbyquizidApi)] action in quizquestions_screenCopy widget.
  ApiCallResponse? quizRes;
  // State field(s) for Timer widget.
  final timerInitialTimeMs = 0;
  int timerMilliseconds = 0;
  String timerValue = StopWatchTimer.getDisplayTime(
    0,
    hours: false,
    milliSecond: false,
  );
  FlutterFlowTimerController timerController =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    timerController.dispose();
  }
}
