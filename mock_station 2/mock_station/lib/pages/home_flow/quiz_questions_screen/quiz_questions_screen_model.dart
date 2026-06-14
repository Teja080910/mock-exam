import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'quiz_questions_screen_widget.dart' show QuizQuestionsScreenWidget;
import 'package:flutter/material.dart';

class QuizQuestionsScreenModel
    extends FlutterFlowModel<QuizQuestionsScreenWidget> {
  ///  Local state fields for this page.

  String? userAnswer;

  String? actualAnswer;

  bool isLoading = true;

  bool isTimerPlayed = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetquestionsbyquizidApi)] action in quiz_questions_screen widget.
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
  // Stores action output result for [Backend Call - API (GetpointssettingApi)] action in Button widget.
  ApiCallResponse? pointsSetting;
  // Stores action output result for [Backend Call - API (GetpointssettingApi)] action in Button widget.
  ApiCallResponse? pointsSetting1;
  // Stores action output result for [Backend Call - API (GetpointssettingApi)] action in Button widget.
  ApiCallResponse? pointsSetting2;
  // Stores action output result for [Backend Call - API (GetpointssettingApi)] action in Button widget.
  ApiCallResponse? pointsSetting3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    try {
      if (timerController != null) {
        timerController.dispose();
      }
    } catch (e) {
      print('QUIZ DEBUG: Error disposing timer controller: $e');
    }
  }
}
