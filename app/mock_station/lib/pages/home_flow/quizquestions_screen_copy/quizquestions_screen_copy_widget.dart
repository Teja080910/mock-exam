import '';
import '/backend/api_requests/api_calls.dart';
import '/componants/complete_quiz/complete_quiz_widget.dart';
import '/componants/quit_quiz/quit_quiz_widget.dart';
import '/componants/timeout_dialog/timeout_dialog_widget.dart';
import '/flutter_flow/flutter_flow_audio_player.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'quizquestions_screen_copy_model.dart';
import 'dart:convert';
export 'quizquestions_screen_copy_model.dart';

class QuizquestionsScreenCopyWidget extends StatefulWidget {
  const QuizquestionsScreenCopyWidget({
    super.key,
    this.title,
    this.catId,
    this.image,
    this.time,
    this.quizID,
    this.correctAnsReward,
    this.penaltyPerQuestion,
  });

  final String? title;
  final String? catId;
  final String? image;
  final String? time;
  final String? quizID;
  final double? correctAnsReward;
  final double? penaltyPerQuestion;

  static String routeName = 'quizquestions_screenCopy';
  static String routePath = '/quizquestionsScreenCopy';

  @override
  State<QuizquestionsScreenCopyWidget> createState() =>
      _QuizquestionsScreenCopyWidgetState();
}

class _QuizquestionsScreenCopyWidgetState
    extends State<QuizquestionsScreenCopyWidget> {
  late QuizquestionsScreenCopyModel _model;
  bool _didParseParams = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => QuizquestionsScreenCopyModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      FFAppState().quesIndex = _model.pageViewCurrentIndex + 1;
      safeSetState(() {});
      _model.quizRes = await QuizGroup.getquestionsbyquizidApiCall.call(
        quizId: widget.quizID,
      );

      FFAppState().questionType = getJsonField(
        (_model.quizRes?.jsonBody ?? ''),
        r'''$.question_type''',
      ).toString().toString();
      safeSetState(() {});
      _model.isLoading = false;
      safeSetState(() {});
      await Future.delayed(const Duration(milliseconds: 1000));
      _model.timerController.onResetTimer();

      _model.timerController.onStartTimer();
      print('QUIZ COPY DEBUG: correctAnsReward: ' + (widget.correctAnsReward?.toString() ?? 'null'));
      print('QUIZ COPY DEBUG: penaltyPerQuestion: ' + (widget.penaltyPerQuestion?.toString() ?? 'null'));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didParseParams) {
      _didParseParams = true;
      double? _parseDouble(dynamic value) {
        if (value == null) return null;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value);
        return null;
      }
      if (widget.correctAnsReward == null && (ModalRoute.of(context)?.settings.arguments is Map)) {
        final args = ModalRoute.of(context)!.settings.arguments as Map;
        final parsed = _parseDouble(args['correctAnsReward']);
        if (parsed != null) {
          // ignore: invalid_use_of_protected_member
          (widget as dynamic).correctAnsReward = parsed;
        }
      }
      if (widget.penaltyPerQuestion == null && (ModalRoute.of(context)?.settings.arguments is Map)) {
        final args = ModalRoute.of(context)!.settings.arguments as Map;
        final parsed = _parseDouble(args['penaltyPerQuestion']);
        if (parsed != null) {
          // ignore: invalid_use_of_protected_member
          (widget as dynamic).penaltyPerQuestion = parsed;
        }
      }
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    // Extract correctAnsReward and penaltyPerQuestion from API response if available
    double correctAnsReward = 0.0;
    double penaltyPerQuestion = 0.0;
    final quizJson = _model.quizRes?.jsonBody;
    dynamic quizMap = quizJson;
    if (quizJson is String) {
      try {
        quizMap = jsonDecode(quizJson);
      } catch (e) {
        quizMap = {};
      }
    }
    // Extract from top-level data fields as per backend
    final apiCorrect = getJsonField(quizMap, r'$.data.correctAnsReward');
    final apiPenalty = getJsonField(quizMap, r'$.data.penaltyPerQuestion');
    if (apiCorrect != null) {
      if (apiCorrect is num) {
        correctAnsReward = apiCorrect.toDouble();
      } else if (apiCorrect is String) {
        correctAnsReward = double.tryParse(apiCorrect) ?? 0.0;
      }
    }
    if (apiPenalty != null) {
      if (apiPenalty is num) {
        penaltyPerQuestion = apiPenalty.toDouble();
      } else if (apiPenalty is String) {
        penaltyPerQuestion = double.tryParse(apiPenalty) ?? 0.0;
      }
    }
    // Questions and totalMark logic
    final questions = getJsonField(quizMap, r'$.data.questionsDetails');
    int totalQuestions = 0;
    if (questions is List) {
      totalQuestions = questions.length;
    }
    double totalMark = correctAnsReward * totalQuestions.toDouble();
    print('QUIZ COPY DEBUG (API): correctAnsReward: ' + correctAnsReward.toString());
    print('QUIZ COPY DEBUG (API): penaltyPerQuestion: ' + penaltyPerQuestion.toString());
    print('QUIZ COPY DEBUG (API): totalMark: ' + totalMark.toString());

    // Extract quiz duration and timer status from the first question's quizId
    int quizDurationMinutes = 0;
    int timerStatus = 0;
    if (questions is List && questions.isNotEmpty) {
      final quizIdObj = getJsonField(questions[0], r'$.quizId');
      final apiDuration = getJsonField(quizIdObj, r'$.minutes_per_quiz');
      final apiTimerStatus = getJsonField(quizIdObj, r'$.timer_status');
      if (apiDuration != null) {
        if (apiDuration is num) {
          quizDurationMinutes = apiDuration.toInt();
        } else if (apiDuration is String) {
          quizDurationMinutes = int.tryParse(apiDuration) ?? 0;
        }
      }
      if (apiTimerStatus != null) {
        if (apiTimerStatus is num) {
          timerStatus = apiTimerStatus.toInt();
        } else if (apiTimerStatus is String) {
          timerStatus = int.tryParse(apiTimerStatus) ?? 0;
        }
      }
    }
    print('QUIZ COPY DEBUG (API): quizDurationMinutes: ' + quizDurationMinutes.toString());
    print('QUIZ COPY DEBUG (API): timerStatus: ' + timerStatus.toString());
    if (timerStatus == 1) {
      print('QUIZ COPY DEBUG: Timer widget should be shown with duration: ' + quizDurationMinutes.toString() + ' minutes');
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: Builder(
          builder: (context) {
            if (_model.isLoading == false) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: double.infinity,
                    height: 126.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 18.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Builder(
                                builder: (context) => InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    if (_model.pageViewCurrentIndex == 0) {
                                    await showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return Dialog(
                                          elevation: 0,
                                          insetPadding: EdgeInsets.zero,
                                          backgroundColor: Colors.transparent,
                                            alignment: AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                          child: GestureDetector(
                                            onTap: () {
                                                FocusScope.of(dialogContext).unfocus();
                                                FocusManager.instance.primaryFocus?.unfocus();
                                            },
                                            child: Container(
                                              height: 352.0,
                                              child: QuitQuizWidget(),
                                            ),
                                          ),
                                        );
                                      },
                                    );

                                    FFAppState().quesIndex = 1;
                                    safeSetState(() {});
                                    FFAppState().correctQues = 0;
                                    safeSetState(() {});
                                    FFAppState().wrongQues = 0;
                                    safeSetState(() {});
                                    } else {
                                      await _model.pageViewController?.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                      FFAppState().quesIndex = _model.pageViewCurrentIndex;
                                      safeSetState(() {});
                                    }
                                  },
                                  child: Container(
                                    width: 40.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).lightGrey,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      _model.pageViewCurrentIndex == 0
                                        ? Icons.close_sharp
                                        : Icons.arrow_back_ios_new_rounded,
                                      color: FlutterFlowTheme.of(context).primaryText,
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                              ),
                              RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Quiz',
                                      style: TextStyle(),
                                    )
                                  ],
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Roboto',
                                        fontSize: 22.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        useGoogleFonts: false,
                                        lineHeight: 1.5,
                                      ),
                                ),
                              ),
                              Builder(
                                builder: (context) => InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    if (_model.userAnswer == null ||
                                        _model.userAnswer == '') {
                                      FFAppState().notAnswerQues =
                                          FFAppState().notAnswerQues + 1;
                                      FFAppState()
                                          .addToNotAnswerQuestion(<String,
                                              dynamic>{
                                        'question_title': getJsonField(
                                          QuizGroup.getquestionsbyquizidApiCall
                                              .questionDetailsList(
                                                (_model.quizRes?.jsonBody ??
                                                    ''),
                                              )
                                              ?.elementAtOrNull(
                                                  _model.pageViewCurrentIndex),
                                          r'''$.question_title''',
                                        ),
                                        'question_type': getJsonField(
                                          QuizGroup.getquestionsbyquizidApiCall
                                              .questionDetailsList(
                                                (_model.quizRes?.jsonBody ??
                                                    ''),
                                              )
                                              ?.elementAtOrNull(
                                                  _model.pageViewCurrentIndex),
                                          r'''$.question_type''',
                                        ),
                                        'answer': getJsonField(
                                          QuizGroup.getquestionsbyquizidApiCall
                                              .questionDetailsList(
                                                (_model.quizRes?.jsonBody ??
                                                    ''),
                                              )
                                              ?.elementAtOrNull(
                                                  _model.pageViewCurrentIndex),
                                          r'''$.answer''',
                                        ),
                                        'option': getJsonField(
                                          QuizGroup.getquestionsbyquizidApiCall
                                              .questionDetailsList(
                                                (_model.quizRes?.jsonBody ??
                                                    ''),
                                              )
                                              ?.elementAtOrNull(
                                                  _model.pageViewCurrentIndex),
                                          r'''$.option''',
                                        ),
                                        'user_answer': FFAppState().userAns,
                                      });
                                      FFAppState().quesIndex =
                                          _model.pageViewCurrentIndex + 1;
                                      safeSetState(() {});
                                      if (QuizGroup.getquestionsbyquizidApiCall
                                              .questionDetailsList(
                                                (_model.quizRes?.jsonBody ??
                                                    ''),
                                              )
                                              ?.length ==
                                          FFAppState().quesIndex) {
                                        await showDialog(
                                          context: context,
                                          builder: (dialogContext) {
                                            return Dialog(
                                              elevation: 0,
                                              insetPadding: EdgeInsets.zero,
                                              backgroundColor:
                                                  Colors.transparent,
                                              alignment:
                                                  AlignmentDirectional(0.0, 0.0)
                                                      .resolve(
                                                          Directionality.of(
                                                              context)),
                                              child: GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(dialogContext)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: CompleteQuizWidget(
                                                  completed: () async {
                                                    FFAppState().quesIndex = 0;
                                                    safeSetState(() {});

                                                    context.goNamed(
                                                      QuizResultWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'correctAnswer':
                                                            serializeParam(
                                                          FFAppState()
                                                              .correctQues,
                                                          ParamType.int,
                                                        ),
                                                        'wrongAnswer':
                                                            serializeParam(
                                                          FFAppState()
                                                              .wrongQues,
                                                          ParamType.int,
                                                        ),
                                                        'totalQuestion':
                                                            serializeParam(
                                                          QuizGroup
                                                              .getquestionsbyquizidApiCall
                                                              .questionDetailsList(
                                                                (_model.quizRes
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )
                                                              ?.length,
                                                          ParamType.int,
                                                        ),
                                                        'notAnswer':
                                                            serializeParam(
                                                          FFAppState()
                                                              .notAnswerQues,
                                                          ParamType.int,
                                                        ),
                                                        'quizID':
                                                            serializeParam(
                                                          widget.quizID,
                                                          ParamType.String,
                                                        ),
                                                        'title': serializeParam(
                                                          '${widget.title} Quiz',
                                                          ParamType.String,
                                                        ),
                                                        'image': serializeParam(
                                                          widget.image,
                                                          ParamType.String,
                                                        ),
                                                        'quizTime':
                                                            serializeParam(
                                                          widget.time,
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );

                                                    _model.timerController
                                                        .onResetTimer();
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        );

                                        await _model.pageViewController
                                            ?.animateToPage(
                                          0,
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      } else {
                                        FFAppState().quesIndex =
                                            _model.pageViewCurrentIndex + 1;
                                        safeSetState(() {});
                                        if (QuizGroup
                                                .getquestionsbyquizidApiCall
                                                .questionDetailsList(
                                                  (_model.quizRes?.jsonBody ??
                                                      ''),
                                                )
                                                ?.length !=
                                            FFAppState().quesIndex) {
                                          await _model.pageViewController
                                              ?.nextPage(
                                            duration:
                                                Duration(milliseconds: 300),
                                            curve: Curves.ease,
                                          );
                                        }
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Skip',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Roboto',
                                          fontSize: 18.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          useGoogleFonts: false,
                                          lineHeight: 1.5,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).black10,
                          ),
                        ),
                        // Add timer/progress bar if timerStatus == 1
                        if (timerStatus == 1)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 15.0, 0.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15.0),
                                      ),
                                      child: custom_widgets.LinearBarTimer(
                                        width: 309.0,
                                        height: 10.0,
                                        time: quizDurationMinutes * 60 * 1000,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100.0,
                                  height: 34.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: FlutterFlowTimer(
                                    initialTime: quizDurationMinutes * 60 * 1000,
                                    getDisplayTime: (value) => StopWatchTimer.getDisplayTime(
                                      value,
                                      hours: false,
                                      milliSecond: false,
                                    ),
                                    controller: _model.timerController,
                                    updateStateInterval: Duration(milliseconds: 1000),
                                    onChanged: (value, displayTime, shouldUpdate) {
                                      _model.timerMilliseconds = value;
                                      _model.timerValue = displayTime;
                                      if (shouldUpdate) safeSetState(() {});
                                    },
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Roboto',
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      useGoogleFonts: false,
                                    ),
                                    onEnded: () async {
                                      await showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (dialogContext) {
                                          return Dialog(
                                            elevation: 0,
                                            insetPadding: EdgeInsets.zero,
                                            backgroundColor: Colors.transparent,
                                            alignment: AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                            child: GestureDetector(
                                              onTap: () {
                                                FocusScope.of(dialogContext).unfocus();
                                                FocusManager.instance.primaryFocus?.unfocus();
                                              },
                                              child: TimeoutDialogWidget(
                                                istimeout: () async {
                                                  FFAppState().clearCoinsCache();
                                                  context.pushNamed(
                                                    QuizResultWidget.routeName,
                                                    queryParameters: {
                                                      'correctAnswer': serializeParam(FFAppState().correctQues, ParamType.int),
                                                      'wrongAnswer': serializeParam(FFAppState().wrongQues, ParamType.int),
                                                      'totalQuestion': serializeParam(questions is List ? questions.length : 0, ParamType.int),
                                                      'notAnswer': serializeParam(FFAppState().notAnswerQues, ParamType.int),
                                                      'quizID': serializeParam(widget.quizID, ParamType.String),
                                                      'title': serializeParam(widget.title, ParamType.String),
                                                      'correctAnsReward': serializeParam(correctAnsReward, ParamType.double),
                                                      'penaltyPerQuestion': serializeParam(penaltyPerQuestion, ParamType.double),
                                                    }.withoutNulls,
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ].divide(SizedBox(width: 16.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 24.0, 0.0, 12.0),
                                child: RichText(
                                  textScaler: MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Question ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Roboto',
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              useGoogleFonts: false,
                                              lineHeight: 1.5,
                                            ),
                                      ),
                                      TextSpan(
                                        text: (_model.pageViewCurrentIndex + 1)
                                            .toString(),
                                        style: TextStyle(),
                                      ),
                                      TextSpan(
                                        text: ' of ',
                                        style: TextStyle(),
                                      ),
                                      TextSpan(
                                        text: QuizGroup
                                            .getquestionsbyquizidApiCall
                                            .questionDetailsList(
                                              (_model.quizRes?.jsonBody ?? ''),
                                            )!
                                            .length
                                            .toString(),
                                        style: TextStyle(),
                                      )
                                    ],
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Roboto',
                                          fontSize: 20.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          useGoogleFonts: false,
                                          lineHeight: 1.5,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 15.0, 0.0, 0.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: Container(
                                          width: 309.0,
                                          height: 10.0,
                                          child: custom_widgets.LinearBarTimer(
                                            width: 309.0,
                                            height: 10.0,
                                            time: (int.tryParse(widget.time ?? '0') ?? 0) * 60 * 1000,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 100.0,
                                    height: 34.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Builder(
                                      builder: (context) => FlutterFlowTimer(
                                        initialTime: (int.tryParse(widget.time ?? '0') ?? 0) * 60 * 1000,
                                        getDisplayTime: (value) =>
                                            StopWatchTimer.getDisplayTime(
                                          value,
                                          hours: false,
                                          milliSecond: false,
                                        ),
                                        controller: _model.timerController,
                                        updateStateInterval:
                                            Duration(milliseconds: 1000),
                                        onChanged:
                                            (value, displayTime, shouldUpdate) {
                                          _model.timerMilliseconds = value;
                                          _model.timerValue = displayTime;
                                          if (shouldUpdate) safeSetState(() {});
                                        },
                                        onEnded: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (dialogContext) {
                                              return Dialog(
                                                elevation: 0,
                                                insetPadding: EdgeInsets.zero,
                                                backgroundColor:
                                                    Colors.transparent,
                                                alignment: AlignmentDirectional(
                                                        0.0, 0.0)
                                                    .resolve(Directionality.of(
                                                        context)),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    FocusScope.of(dialogContext)
                                                        .unfocus();
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                  },
                                                  child: TimeoutDialogWidget(
                                                    istimeout: () async {
                                                      context.pushNamed(
                                                        QuizResultWidget
                                                            .routeName,
                                                        queryParameters: {
                                                          'correctAnswer': serializeParam(FFAppState().correctQues, ParamType.int),
                                                          'wrongAnswer': serializeParam(FFAppState().wrongQues, ParamType.int),
                                                          'totalQuestion': serializeParam(questions is List ? questions.length : 0, ParamType.int),
                                                          'notAnswer': serializeParam(FFAppState().notAnswerQues, ParamType.int),
                                                          'quizID': serializeParam(widget.quizID, ParamType.String),
                                                          'title': serializeParam(widget.title, ParamType.String),
                                                          'correctAnsReward': serializeParam(correctAnsReward, ParamType.double),
                                                          'penaltyPerQuestion': serializeParam(penaltyPerQuestion, ParamType.double),
                                                        }.withoutNulls,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        textAlign: TextAlign.start,
                                        style: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .override(
                                              fontFamily: 'Roboto',
                                              fontSize: 18.0,
                                              letterSpacing: 0.0,
                                              useGoogleFonts: false,
                                            ),
                                      ),
                                    ),
                                  ),
                                ].divide(SizedBox(width: 16.0)),
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                primary: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 625.0,
                                      decoration: BoxDecoration(),
                                      child: Builder(
                                        builder: (context) {
                                          final categorywisequiz = QuizGroup
                                                  .getquestionsbyquizidApiCall
                                                  .questionDetailsList(
                                                    (_model.quizRes?.jsonBody ??
                                                        ''),
                                                  )
                                                  ?.toList() ??
                                              [];

                                          return Container(
                                            width: double.infinity,
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 40.0),
                                              child: PageView.builder(
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    controller: _model.pageViewController ??= PageController(
                                                      initialPage: max(0, min(0, categorywisequiz.length - 1))
                                                    ),
                                                onPageChanged: (_) async {
                                                      FFAppState().questionType = getJsonField(
                                                        categorywisequiz.elementAtOrNull(_model.pageViewCurrentIndex),
                                                    r'''$.question_type''',
                                                  ).toString();
                                                  safeSetState(() {});
                                                },
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: categorywisequiz.length,
                                                    itemBuilder: (context, categorywisequizIndex) {
                                                      final categorywisequizItem = categorywisequiz[categorywisequizIndex];
                                                  return Builder(
                                                    builder: (context) {
                                                          if (FFAppState().questionType == 'text_only') {
                                                        return Padding(
                                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 50.0, 16.0, 20.0),
                                                          child: Container(
                                                                width: double.infinity,
                                                            height: 50.0,
                                                                decoration: BoxDecoration(
                                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                  borderRadius: BorderRadius.circular(16.0),
                                                            ),
                                                                alignment: AlignmentDirectional(0.0, -1.0),
                                                            child: ListView(
                                                                  padding: EdgeInsets.fromLTRB(0, 24.0, 0, 24.0),
                                                              shrinkWrap: true,
                                                                  scrollDirection: Axis.vertical,
                                                              children: [
                                                                Align(
                                                                      alignment: AlignmentDirectional(-1.0, 0.0),
                                                                      child: Padding(
                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                                                                    child: Text(
                                                                      getJsonField(
                                                                        categorywisequizItem,
                                                                        r'''$.question_title''',
                                                                      ).toString(),
                                                                          textAlign: TextAlign.start,
                                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                            fontFamily: 'Roboto',
                                                                            fontSize: 18.0,
                                                                            letterSpacing: 0.0,
                                                                            fontWeight: FontWeight.w600,
                                                                            useGoogleFonts: false,
                                                                            lineHeight: 1.2,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          16.0),
                                                                  child:
                                                                      InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap:
                                                                        () async {
                                                                      _model.userAnswer =
                                                                          getJsonField(
                                                                        categorywisequizItem,
                                                                        r'''$.option.a''',
                                                                      ).toString();
                                                                      _model.actualAnswer =
                                                                          getJsonField(
                                                                        categorywisequizItem,
                                                                        r'''$.answer''',
                                                                      ).toString();
                                                                      safeSetState(
                                                                          () {});
                                                                      FFAppState()
                                                                          .buttonColor = FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary;
                                                                      FFAppState()
                                                                          .buttonColor1 = FlutterFlowTheme.of(
                                                                              context)
                                                                          .grey;
                                                                      FFAppState()
                                                                          .buttonColor2 = FlutterFlowTheme.of(
                                                                              context)
                                                                          .grey;
                                                                      FFAppState()
                                                                          .buttonColor3 = FlutterFlowTheme.of(
                                                                              context)
                                                                          .grey;
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          369.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          FFAppState()
                                                                              .buttonColor,
                                                                          FlutterFlowTheme.of(context)
                                                                              .grey,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(12.0),
                                                                      ),
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.all(16.0),
                                                                          child:
                                                                              Text(
                                                                            getJsonField(
                                                                              categorywisequizItem,
                                                                              r'''$.option.a''',
                                                                            ).toString(),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: 'Roboto',
                                                                                  fontSize: 18.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.normal,
                                                                                  useGoogleFonts: false,
                                                                                  lineHeight: 1.5,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          16.0),
                                                                  child:
                                                                      InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap:
                                                                        () async {
                                                                      _model.userAnswer =
                                                                          getJsonField(
                                                                        categorywisequizItem,
                                                                        r'''$.option.b''',
                                                                      ).toString();
                                                                      _model.actualAnswer =
                                                                          getJsonField(
                                                                        categorywisequizItem,
                                                                        r'''$.answer''',
                                                                      ).toString();
                                                                      safeSetState(
                                                                          () {});
                                                                      FFAppState()
                                                                          .buttonColor = FlutterFlowTheme.of(
                                                                              context)
                                                                          .grey;
                                                                      FFAppState()
                                                                          .buttonColor1 = FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary;
                                                                      FFAppState()
                                                                          .buttonColor2 = FlutterFlowTheme.of(
                                                                              context)
                                                                          .grey;
                                                                      FFAppState()
                                                                          .buttonColor3 = FlutterFlowTheme.of(
                                                                              context)
                                                                          .grey;
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          369.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          FFAppState()
                                                                              .buttonColor1,
                                                                          FlutterFlowTheme.of(context)
                                                                              .grey,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(12.0),
                                                                      ),
                                                                      child:
                                                                          Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.all(16.0),
                                                                          child:
                                                                              Text(
                                                                            getJsonField(
                                                                              categorywisequizItem,
                                                                              r'''$.option.b''',
                                                                            ).toString(),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: 'Roboto',
                                                                                  fontSize: 18.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.normal,
                                                                                  useGoogleFonts: false,
                                                                                  lineHeight: 1.5,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          16.0),
                                                                  child:
                                                                      InkWell(
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    focusColor:
                                                                        Colors
                                                                            .transparent,
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap:
                                                                        () async {
                                                                      _model.userAnswer =
                                                                          getJsonField(
                                                                        categorywisequizItem,
                                                                        r'''$.option.c''',
                                                                      ).toString();
                                                                      _model.actualAnswer =
                                                                          getJsonField(
                                                                        categorywisequizItem,
                                                                        r'''$.answer''',
                                                                      ).toString();
                                                                      safeSetState(
                                                                          () {});
                                                                      FFAppState()
                                                                          .buttonColor = FlutterFlowTheme.of(
                                                                              context)
                                                                          .grey;
                                                                      FFAppState()
                                                                          .buttonColor1 = FlutterFlowTheme.of(
                                                                              context)
                                                                          .grey;
                                                                      FFAppState()
                                                                          .buttonColor2 = FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary;
                                                                      FFAppState()
                                                                          .buttonColor3 = FlutterFlowTheme.of(
                                                                              context)
                                                                          .grey;
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          369.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: valueOrDefault<
                                                                            Color>(
                                                                          FFAppState()
                                                                              .buttonColor2,
                                                                          FlutterFlowTheme.of(context)
                                                                              .grey,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(12.0),
                                                                      ),
                                                                      child:
                                                                          Align(
                                                                        alignment: AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              EdgeInsets.all(16.0),
                                                                          child:
                                                                              Text(
                                                                            getJsonField(
                                                                              categorywisequizItem,
                                                                              r'''$.option.c''',
                                                                            ).toString(),
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: 'Roboto',
                                                                                  fontSize: 18.0,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.normal,
                                                                                  useGoogleFonts: false,
                                                                                  lineHeight: 1.5,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  focusColor: Colors
                                                                      .transparent,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap:
                                                                      () async {
                                                                    _model.userAnswer =
                                                                        getJsonField(
                                                                      categorywisequizItem,
                                                                      r'''$.option.d''',
                                                                    ).toString();
                                                                    _model.actualAnswer =
                                                                        getJsonField(
                                                                      categorywisequizItem,
                                                                      r'''$.answer''',
                                                                    ).toString();
                                                                    safeSetState(
                                                                        () {});
                                                                    FFAppState()
                                                                        .buttonColor = FlutterFlowTheme.of(
                                                                            context)
                                                                        .grey;
                                                                    FFAppState()
                                                                        .buttonColor1 = FlutterFlowTheme.of(
                                                                            context)
                                                                        .grey;
                                                                    FFAppState()
                                                                        .buttonColor2 = FlutterFlowTheme.of(
                                                                            context)
                                                                        .grey;
                                                                    FFAppState()
                                                                        .buttonColor3 = FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary;
                                                                    FFAppState()
                                                                        .update(
                                                                            () {});
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width:
                                                                        369.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: valueOrDefault<
                                                                          Color>(
                                                                        FFAppState()
                                                                            .buttonColor3,
                                                                        FlutterFlowTheme.of(context)
                                                                            .grey,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12.0),
                                                                    ),
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              0.0),
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.all(16.0),
                                                                        child:
                                                                            Text(
                                                                          getJsonField(
                                                                            categorywisequizItem,
                                                                            r'''$.option.d''',
                                                                          ).toString(),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: 'Roboto',
                                                                                fontSize: 18.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.normal,
                                                                                useGoogleFonts: false,
                                                                                lineHeight: 1.5,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                          }
                                                          return Container();
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                                if (_model.pageViewCurrentIndex > 0)
                                                  Positioned(
                                                    left: 16,
                                                    top: 16,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        await _model.pageViewController?.previousPage(
                                                          duration: Duration(milliseconds: 300),
                                                          curve: Curves.ease,
                                                        );
                                                        FFAppState().quesIndex = _model.pageViewCurrentIndex;
                                                                            safeSetState(() {});
                                                                          },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                                          shape: BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 4,
                                                              color: Color(0x33000000),
                                                              offset: Offset(0, 2),
                                                            )
                                                          ],
                                                                      ),
                                                        child: Icon(
                                                          Icons.arrow_back_ios_new_rounded,
                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                          size: 20,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 24.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: Builder(
                                          builder: (context) => Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 0.0, 16.0, 0.0),
                                            child: FFButtonWidget(
                                              onPressed: () async {
                                                if (_model.userAnswer == null ||
                                                    _model.userAnswer == '') {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Please select any one option ',
                                                        style: TextStyle(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                        ),
                                                      ),
                                                      duration: Duration(
                                                          milliseconds: 4000),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary,
                                                    ),
                                                  );
                                                }
                                                FFAppState().userAns =
                                                    _model.userAnswer!;
                                                safeSetState(() {});
                                                if (FFAppState().questionType ==
                                                    'text_only') {
                                                  FFAppState()
                                                      .addToQuesList(<String,
                                                          dynamic>{
                                                    'question_title':
                                                        getJsonField(
                                                      QuizGroup
                                                          .getquestionsbyquizidApiCall
                                                          .questionDetailsList(
                                                            (_model.quizRes
                                                                    ?.jsonBody ??
                                                                ''),
                                                          )
                                                          ?.elementAtOrNull(_model
                                                              .pageViewCurrentIndex),
                                                      r'''$.question_title''',
                                                    ),
                                                    'question_type':
                                                        getJsonField(
                                                      QuizGroup
                                                          .getquestionsbyquizidApiCall
                                                          .questionDetailsList(
                                                            (_model.quizRes
                                                                    ?.jsonBody ??
                                                                ''),
                                                          )
                                                          ?.elementAtOrNull(_model
                                                              .pageViewCurrentIndex),
                                                      r'''$.question_type''',
                                                    ),
                                                    'answer': getJsonField(
                                                      QuizGroup
                                                          .getquestionsbyquizidApiCall
                                                          .questionDetailsList(
                                                            (_model.quizRes
                                                                    ?.jsonBody ??
                                                                ''),
                                                          )
                                                          ?.elementAtOrNull(_model
                                                              .pageViewCurrentIndex),
                                                      r'''$.answer''',
                                                    ),
                                                    'option': getJsonField(
                                                      QuizGroup
                                                          .getquestionsbyquizidApiCall
                                                          .questionDetailsList(
                                                            (_model.quizRes
                                                                    ?.jsonBody ??
                                                                ''),
                                                          )
                                                          ?.elementAtOrNull(_model
                                                              .pageViewCurrentIndex),
                                                      r'''$.option''',
                                                    ),
                                                    'user_answer':
                                                        FFAppState().userAns,
                                                  });
                                                  safeSetState(() {});
                                                  if (_model.userAnswer ==
                                                      _model.actualAnswer) {
                                                    FFAppState().correctQues =
                                                        FFAppState()
                                                                .correctQues +
                                                            1;
                                                    safeSetState(() {});
                                                  } else {
                                                    FFAppState().wrongQues =
                                                        FFAppState().wrongQues +
                                                            -1;
                                                    safeSetState(() {});
                                                  }

                                                  FFAppState().buttonColor =
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .grey;
                                                  FFAppState().buttonColor1 =
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .grey;
                                                  FFAppState().buttonColor2 =
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .grey;
                                                  FFAppState().buttonColor3 =
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .grey;
                                                  FFAppState().noOfQues = QuizGroup
                                                      .getquestionsbyquizidApiCall
                                                      .questionDetailsList(
                                                        (_model.quizRes
                                                                ?.jsonBody ??
                                                            ''),
                                                      )!
                                                      .length;
                                                  safeSetState(() {});
                                                  if (FFAppState().noOfQues ==
                                                      (_model.pageViewCurrentIndex +
                                                          1)) {
                                                    FFAppState()
                                                        .selectedColorIndex = -1;
                                                    safeSetState(() {});
                                                    _model.timerController
                                                        .onStopTimer();
                                                    await showDialog(
                                                      context: context,
                                                      builder: (dialogContext) {
                                                        return Dialog(
                                                          elevation: 0,
                                                          insetPadding:
                                                              EdgeInsets.zero,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          alignment: AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              FocusScope.of(
                                                                      dialogContext)
                                                                  .unfocus();
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                            },
                                                            child:
                                                                CompleteQuizWidget(
                                                              completed:
                                                                  () async {
                                                                FFAppState()
                                                                    .quesIndex = 0;
                                                                safeSetState(
                                                                    () {});

                                                                context.goNamed(
                                                                  QuizResultWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
                                                                    'correctAnswer':
                                                                        serializeParam(
                                                                      FFAppState()
                                                                          .correctQues,
                                                                      ParamType
                                                                          .int,
                                                                    ),
                                                                    'wrongAnswer':
                                                                        serializeParam(
                                                                      FFAppState()
                                                                          .wrongQues,
                                                                      ParamType
                                                                          .int,
                                                                    ),
                                                                    'totalQuestion':
                                                                        serializeParam(
                                                                      QuizGroup
                                                                          .getquestionsbyquizidApiCall
                                                                          .questionDetailsList(
                                                                            (_model.quizRes?.jsonBody ?? ''),
                                                                          )
                                                                          ?.length,
                                                                      ParamType
                                                                          .int,
                                                                    ),
                                                                    'notAnswer':
                                                                        serializeParam(
                                                                      FFAppState()
                                                                          .notAnswerQues,
                                                                      ParamType
                                                                          .int,
                                                                    ),
                                                                    'quizID':
                                                                        serializeParam(
                                                                      widget
                                                                          .quizID,
                                                                      ParamType
                                                                          .String,
                                                                    ),
                                                                    'title':
                                                                        serializeParam(
                                                                      '${widget.title} Quiz',
                                                                      ParamType
                                                                          .String,
                                                                    ),
                                                                    'image':
                                                                        serializeParam(
                                                                      widget
                                                                          .image,
                                                                      ParamType
                                                                          .String,
                                                                    ),
                                                                    'quizTime':
                                                                        serializeParam(
                                                                      widget
                                                                          .time,
                                                                      ParamType
                                                                          .String,
                                                                    ),
                                                                    'catID':
                                                                        serializeParam(
                                                                      widget
                                                                          .catId,
                                                                      ParamType
                                                                          .String,
                                                                    ),
                                                                  }.withoutNulls,
                                                                );

                                                                _model
                                                                    .timerController
                                                                    .onResetTimer();
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );

                                                    await _model
                                                        .pageViewController
                                                        ?.animateToPage(
                                                      0,
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.ease,
                                                    );
                                                  } else {
                                                    FFAppState()
                                                        .quesIndex = _model
                                                            .pageViewCurrentIndex +
                                                        1;
                                                    safeSetState(() {});
                                                    FFAppState()
                                                        .selectedColorIndex = -1;
                                                    safeSetState(() {});
                                                    await _model
                                                        .pageViewController
                                                        ?.nextPage(
                                                      duration: Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.ease,
                                                    );
                                                  }

                                                  FFAppState().addToQuesType((QuizGroup
                                                      .getquestionsbyquizidApiCall
                                                      .questionTypeList(
                                                        (_model.quizRes
                                                                ?.jsonBody ??
                                                            ''),
                                                      )!
                                                      .elementAtOrNull(
                                                          _model.pageViewCurrentIndex +
                                                          1))!);
                                                  safeSetState(() {});
                                                  _model.userAnswer = null;
                                                  _model.actualAnswer = null;
                                                  safeSetState(() {});
                                                } else {
                                                  if (FFAppState()
                                                          .questionType ==
                                                      'true_false') {
                                                    FFAppState()
                                                        .addToQuesList(<String,
                                                            dynamic>{
                                                      'question_title':
                                                          getJsonField(
                                                        QuizGroup
                                                            .getquestionsbyquizidApiCall
                                                            .questionDetailsList(
                                                              (_model.quizRes
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )
                                                            ?.elementAtOrNull(_model
                                                                .pageViewCurrentIndex),
                                                        r'''$.question_title''',
                                                      ),
                                                      'question_type':
                                                          getJsonField(
                                                        QuizGroup
                                                            .getquestionsbyquizidApiCall
                                                            .questionDetailsList(
                                                              (_model.quizRes
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )
                                                            ?.elementAtOrNull(_model
                                                                .pageViewCurrentIndex),
                                                        r'''$.question_type''',
                                                      ),
                                                      'answer': getJsonField(
                                                        QuizGroup
                                                            .getquestionsbyquizidApiCall
                                                            .questionDetailsList(
                                                              (_model.quizRes
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )
                                                            ?.elementAtOrNull(_model
                                                                .pageViewCurrentIndex),
                                                        r'''$.answer''',
                                                      ),
                                                      'user_answer':
                                                          FFAppState().userAns,
                                                    });
                                                    safeSetState(() {});
                                                    if (_model.userAnswer ==
                                                        _model.actualAnswer) {
                                                      FFAppState().correctQues =
                                                          FFAppState()
                                                                  .correctQues +
                                                              1;
                                                      safeSetState(() {});
                                                    } else {
                                                      FFAppState().wrongQues =
                                                          FFAppState()
                                                                  .wrongQues +
                                                              -1;
                                                      safeSetState(() {});
                                                    }

                                                    FFAppState().buttonColor =
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .grey;
                                                    FFAppState().buttonColor1 =
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .grey;
                                                    FFAppState().buttonColor2 =
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .grey;
                                                    FFAppState().buttonColor3 =
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .grey;
                                                    FFAppState().noOfQues = QuizGroup
                                                        .getquestionsbyquizidApiCall
                                                        .questionDetailsList(
                                                          (_model.quizRes
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )!
                                                        .length;
                                                    safeSetState(() {});
                                                    if (FFAppState().noOfQues ==
                                                        (_model.pageViewCurrentIndex +
                                                            1)) {
                                                      FFAppState()
                                                          .selectedColorIndex = -1;
                                                      safeSetState(() {});
                                                      _model.timerController
                                                          .onStopTimer();
                                                      await showDialog(
                                                        context: context,
                                                        builder:
                                                            (dialogContext) {
                                                          return Dialog(
                                                            elevation: 0,
                                                            insetPadding:
                                                                EdgeInsets.zero,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            alignment: AlignmentDirectional(
                                                                    0.0, 0.0)
                                                                .resolve(
                                                                    Directionality.of(
                                                                        context)),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                FocusScope.of(
                                                                        dialogContext)
                                                                    .unfocus();
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                              },
                                                              child:
                                                                  CompleteQuizWidget(
                                                                completed:
                                                                    () async {
                                                                  FFAppState()
                                                                      .quesIndex = 0;
                                                                  safeSetState(
                                                                      () {});

                                                                  context
                                                                      .goNamed(
                                                                    QuizResultWidget
                                                                        .routeName,
                                                                    queryParameters:
                                                                        {
                                                                      'correctAnswer':
                                                                          serializeParam(
                                                                        FFAppState()
                                                                            .correctQues,
                                                                        ParamType
                                                                            .int,
                                                                      ),
                                                                      'wrongAnswer':
                                                                          serializeParam(
                                                                        FFAppState()
                                                                            .wrongQues,
                                                                        ParamType
                                                                            .int,
                                                                      ),
                                                                      'totalQuestion':
                                                                          serializeParam(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList(
                                                                              (_model.quizRes?.jsonBody ?? ''),
                                                                            )
                                                                            ?.length,
                                                                        ParamType
                                                                            .int,
                                                                      ),
                                                                      'notAnswer':
                                                                          serializeParam(
                                                                        FFAppState()
                                                                            .notAnswerQues,
                                                                        ParamType
                                                                            .int,
                                                                      ),
                                                                      'quizID':
                                                                          serializeParam(
                                                                        widget
                                                                            .quizID,
                                                                        ParamType
                                                                            .String,
                                                                      ),
                                                                      'title':
                                                                          serializeParam(
                                                                        '${widget.title} Quiz',
                                                                        ParamType
                                                                            .String,
                                                                      ),
                                                                      'image':
                                                                          serializeParam(
                                                                        widget
                                                                            .image,
                                                                        ParamType
                                                                            .String,
                                                                      ),
                                                                      'quizTime':
                                                                          serializeParam(
                                                                        widget
                                                                            .time,
                                                                        ParamType
                                                                            .String,
                                                                      ),
                                                                      'catID':
                                                                          serializeParam(
                                                                        widget
                                                                            .catId,
                                                                        ParamType
                                                                            .String,
                                                                      ),
                                                                    }.withoutNulls,
                                                                  );

                                                                  _model
                                                                      .timerController
                                                                      .onResetTimer();
                                                                },
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );

                                                      await _model
                                                          .pageViewController
                                                          ?.animateToPage(
                                                        0,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                        curve: Curves.ease,
                                                      );
                                                    } else {
                                                      FFAppState()
                                                          .quesIndex = _model
                                                              .pageViewCurrentIndex +
                                                          1;
                                                      safeSetState(() {});
                                                      FFAppState()
                                                          .selectedColorIndex = -1;
                                                      safeSetState(() {});
                                                      await _model
                                                          .pageViewController
                                                          ?.nextPage(
                                                        duration: Duration(
                                                            milliseconds:
                                                                300),
                                                        curve: Curves.ease,
                                                      );
                                                    }

                                                    FFAppState().addToQuesType((QuizGroup
                                                        .getquestionsbyquizidApiCall
                                                        .questionTypeList(
                                                          (_model.quizRes
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )!
                                                        .elementAtOrNull(
                                                            _model.pageViewCurrentIndex +
                                                            1))!);
                                                    safeSetState(() {});
                                                    _model.userAnswer = null;
                                                    _model.actualAnswer = null;
                                                    safeSetState(() {});
                                                  } else {
                                                    if (FFAppState()
                                                            .questionType ==
                                                        'images') {
                                                      FFAppState()
                                                          .addToQuesList(<String,
                                                              dynamic>{
                                                        'question_title':
                                                            getJsonField(
                                                          QuizGroup
                                                              .getquestionsbyquizidApiCall
                                                              .questionDetailsList(
                                                                (_model.quizRes
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )
                                                              ?.elementAtOrNull(
                                                                  _model
                                                                      .pageViewCurrentIndex),
                                                          r'''$.question_title''',
                                                        ),
                                                        'question_type':
                                                            getJsonField(
                                                          QuizGroup
                                                              .getquestionsbyquizidApiCall
                                                              .questionDetailsList(
                                                                (_model.quizRes
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )
                                                              ?.elementAtOrNull(
                                                                  _model
                                                                      .pageViewCurrentIndex),
                                                          r'''$.question_type''',
                                                        ),
                                                        'answer': getJsonField(
                                                          QuizGroup
                                                              .getquestionsbyquizidApiCall
                                                              .questionDetailsList(
                                                                (_model.quizRes
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )
                                                              ?.elementAtOrNull(
                                                                  _model
                                                                      .pageViewCurrentIndex),
                                                          r'''$.answer''',
                                                        ),
                                                        'option': getJsonField(
                                                          QuizGroup
                                                              .getquestionsbyquizidApiCall
                                                              .questionDetailsList(
                                                                (_model.quizRes
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )
                                                              ?.elementAtOrNull(
                                                                  _model
                                                                      .pageViewCurrentIndex),
                                                          r'''$.option''',
                                                        ),
                                                        'user_answer':
                                                            FFAppState()
                                                                .userAns,
                                                      });
                                                      safeSetState(() {});
                                                      if (_model.userAnswer ==
                                                          _model.actualAnswer) {
                                                        FFAppState()
                                                                .correctQues =
                                                            FFAppState()
                                                                    .correctQues +
                                                                1;
                                                        safeSetState(() {});
                                                      } else {
                                                        FFAppState().wrongQues =
                                                            FFAppState()
                                                                    .wrongQues +
                                                                -1;
                                                        safeSetState(() {});
                                                      }

                                                      FFAppState().buttonColor =
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .grey;
                                                      FFAppState()
                                                              .buttonColor1 =
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .grey;
                                                      FFAppState()
                                                              .buttonColor2 =
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .grey;
                                                      FFAppState()
                                                              .buttonColor3 =
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .grey;
                                                      FFAppState().noOfQues = QuizGroup
                                                          .getquestionsbyquizidApiCall
                                                          .questionDetailsList(
                                                            (_model.quizRes
                                                                    ?.jsonBody ??
                                                                ''),
                                                          )!
                                                          .length;
                                                      safeSetState(() {});
                                                      if (FFAppState()
                                                              .noOfQues ==
                                                          (_model.pageViewCurrentIndex +
                                                              1)) {
                                                        FFAppState()
                                                            .selectedColorIndex = -1;
                                                        safeSetState(() {});
                                                        _model.timerController
                                                            .onStopTimer();
                                                        await showDialog(
                                                          context: context,
                                                          builder:
                                                              (dialogContext) {
                                                            return Dialog(
                                                              elevation: 0,
                                                              insetPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              alignment: AlignmentDirectional(
                                                                      0.0, 0.0)
                                                                  .resolve(
                                                                      Directionality.of(
                                                                          context)),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  FocusScope.of(
                                                                          dialogContext)
                                                                      .unfocus();
                                                                  FocusManager
                                                                      .instance
                                                                      .primaryFocus
                                                                      ?.unfocus();
                                                                },
                                                                child:
                                                                    CompleteQuizWidget(
                                                                  completed:
                                                                      () async {
                                                                    FFAppState()
                                                                        .quesIndex = 0;
                                                                    safeSetState(
                                                                        () {});

                                                                    context
                                                                        .goNamed(
                                                                      QuizResultWidget
                                                                          .routeName,
                                                                      queryParameters:
                                                                          {
                                                                        'correctAnswer':
                                                                            serializeParam(
                                                                          FFAppState()
                                                                              .correctQues,
                                                                          ParamType
                                                                              .int,
                                                                        ),
                                                                        'wrongAnswer':
                                                                            serializeParam(
                                                                          FFAppState()
                                                                              .wrongQues,
                                                                          ParamType
                                                                              .int,
                                                                        ),
                                                                        'totalQuestion':
                                                                            serializeParam(
                                                                          QuizGroup
                                                                              .getquestionsbyquizidApiCall
                                                                              .questionDetailsList(
                                                                                (_model.quizRes?.jsonBody ?? ''),
                                                                              )
                                                                              ?.length,
                                                                            ParamType
                                                                              .int,
                                                                        ),
                                                                        'notAnswer':
                                                                            serializeParam(
                                                                          FFAppState()
                                                                              .notAnswerQues,
                                                                          ParamType
                                                                              .int,
                                                                        ),
                                                                        'quizID':
                                                                            serializeParam(
                                                                          widget
                                                                              .quizID,
                                                                          ParamType
                                                                              .String,
                                                                        ),
                                                                        'title':
                                                                            serializeParam(
                                                                          '${widget.title} Quiz',
                                                                          ParamType
                                                                              .String,
                                                                        ),
                                                                        'image':
                                                                            serializeParam(
                                                                          widget
                                                                              .image,
                                                                          ParamType
                                                                              .String,
                                                                        ),
                                                                        'quizTime':
                                                                            serializeParam(
                                                                          widget
                                                                              .time,
                                                                          ParamType
                                                                              .String,
                                                                        ),
                                                                        'catID':
                                                                            serializeParam(
                                                                          widget
                                                                              .catId,
                                                                          ParamType
                                                                              .String,
                                                                        ),
                                                                      }.withoutNulls,
                                                                    );

                                                                    _model
                                                                        .timerController
                                                                        .onResetTimer();
                                                                  },
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );

                                                        await _model
                                                            .pageViewController
                                                            ?.animateToPage(
                                                          0,
                                                          duration: Duration(
                                                              milliseconds:
                                                                  500),
                                                          curve: Curves.ease,
                                                        );
                                                      } else {
                                                        FFAppState()
                                                            .quesIndex = _model
                                                                .pageViewCurrentIndex +
                                                            1;
                                                        safeSetState(() {});
                                                        FFAppState()
                                                            .selectedColorIndex = -1;
                                                        safeSetState(() {});
                                                        await _model
                                                            .pageViewController
                                                            ?.nextPage(
                                                          duration: Duration(
                                                              milliseconds:
                                                                  300),
                                                          curve: Curves.ease,
                                                        );
                                                      }

                                                      FFAppState().addToQuesType(
                                                          (QuizGroup
                                                              .getquestionsbyquizidApiCall
                                                              .questionTypeList(
                                                                (_model.quizRes
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )!
                                                              .elementAtOrNull(
                                                                  _model.pageViewCurrentIndex +
                                                                      1))!);
                                                      safeSetState(() {});
                                                      _model.userAnswer =
                                                          null;
                                                      _model.actualAnswer =
                                                          null;
                                                      safeSetState(() {});
                                                    } else {
                                                      if (FFAppState()
                                                              .questionType ==
                                                          'audio') {
                                                        FFAppState()
                                                            .addToQuesList(<String,
                                                                dynamic>{
                                                          'question_title':
                                                              getJsonField(
                                                            QuizGroup
                                                                .getquestionsbyquizidApiCall
                                                                .questionDetailsList(
                                                                  (_model.quizRes
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                )
                                                                ?.elementAtOrNull(
                                                                    _model
                                                                        .pageViewCurrentIndex),
                                                            r'''$.question_title''',
                                                          ),
                                                          'question_type':
                                                              getJsonField(
                                                            QuizGroup
                                                                .getquestionsbyquizidApiCall
                                                                .questionDetailsList(
                                                                  (_model.quizRes
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                )
                                                                ?.elementAtOrNull(
                                                                    _model
                                                                        .pageViewCurrentIndex),
                                                            r'''$.question_type''',
                                                          ),
                                                          'answer':
                                                              getJsonField(
                                                            QuizGroup
                                                                .getquestionsbyquizidApiCall
                                                                .questionDetailsList(
                                                                  (_model.quizRes
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                )
                                                                ?.elementAtOrNull(
                                                                    _model
                                                                        .pageViewCurrentIndex),
                                                            r'''$.answer''',
                                                          ),
                                                          'option':
                                                              getJsonField(
                                                            QuizGroup
                                                                .getquestionsbyquizidApiCall
                                                                .questionDetailsList(
                                                                  (_model.quizRes
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                )
                                                                ?.elementAtOrNull(
                                                                    _model
                                                                        .pageViewCurrentIndex),
                                                            r'''$.option''',
                                                          ),
                                                          'user_answer':
                                                              FFAppState()
                                                                  .userAns,
                                                        });
                                                        safeSetState(() {});
                                                        if (_model.userAnswer ==
                                                            _model
                                                                .actualAnswer) {
                                                          FFAppState()
                                                                  .correctQues =
                                                              FFAppState()
                                                                      .correctQues +
                                                                  1;
                                                          safeSetState(() {});
                                                        } else {
                                                          FFAppState()
                                                                  .wrongQues =
                                                              FFAppState()
                                                                      .wrongQues +
                                                                  -1;
                                                          safeSetState(() {});
                                                        }

                                                        FFAppState()
                                                                .buttonColor =
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .grey;
                                                        FFAppState()
                                                                .buttonColor1 =
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .grey;
                                                        FFAppState()
                                                                .buttonColor2 =
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .grey;
                                                        FFAppState()
                                                                .buttonColor3 =
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .grey;
                                                        FFAppState().noOfQues =
                                                            QuizGroup
                                                                .getquestionsbyquizidApiCall
                                                                .questionDetailsList(
                                                                  (_model.quizRes
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                )!
                                                                .length;
                                                        safeSetState(() {});
                                                        if (FFAppState()
                                                                .noOfQues ==
                                                            (_model.pageViewCurrentIndex +
                                                                1)) {
                                                          FFAppState()
                                                              .selectedColorIndex = -1;
                                                          safeSetState(() {});
                                                          _model.timerController
                                                              .onStopTimer();
                                                          await showDialog(
                                                            context: context,
                                                            builder:
                                                                (dialogContext) {
                                                              return Dialog(
                                                                elevation: 0,
                                                                insetPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                alignment: AlignmentDirectional(
                                                                        0.0,
                                                                        0.0)
                                                                    .resolve(
                                                                        Directionality.of(
                                                                            context)),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    FocusScope.of(
                                                                            dialogContext)
                                                                        .unfocus();
                                                                    FocusManager
                                                                        .instance
                                                                        .primaryFocus
                                                                        ?.unfocus();
                                                                  },
                                                                  child:
                                                                      CompleteQuizWidget(
                                                                    completed:
                                                                        () async {
                                                                      FFAppState()
                                                                          .quesIndex = 0;
                                                                      safeSetState(
                                                                          () {});

                                                                      context
                                                                          .goNamed(
                                                                        QuizResultWidget
                                                                            .routeName,
                                                                        queryParameters:
                                                                            {
                                                                          'correctAnswer':
                                                                              serializeParam(
                                                                            FFAppState().correctQues,
                                                                            ParamType.int,
                                                                          ),
                                                                          'wrongAnswer':
                                                                              serializeParam(
                                                                            FFAppState().wrongQues,
                                                                            ParamType.int,
                                                                          ),
                                                                          'totalQuestion':
                                                                              serializeParam(
                                                                            QuizGroup.getquestionsbyquizidApiCall
                                                                                .questionDetailsList(
                                                                                  (_model.quizRes?.jsonBody ?? ''),
                                                                                )
                                                                                ?.length,
                                                                            ParamType.int,
                                                                          ),
                                                                          'notAnswer':
                                                                              serializeParam(
                                                                            FFAppState().notAnswerQues,
                                                                            ParamType.int,
                                                                          ),
                                                                          'quizID':
                                                                              serializeParam(
                                                                            widget.quizID,
                                                                            ParamType.String,
                                                                          ),
                                                                          'title':
                                                                              serializeParam(
                                                                            '${widget.title} Quiz',
                                                                            ParamType.String,
                                                                          ),
                                                                          'image':
                                                                              serializeParam(
                                                                            widget.image,
                                                                            ParamType.String,
                                                                          ),
                                                                          'quizTime':
                                                                              serializeParam(
                                                                            widget.time,
                                                                            ParamType.String,
                                                                          ),
                                                                          'catID':
                                                                              serializeParam(
                                                                            widget.catId,
                                                                            ParamType.String,
                                                                          ),
                                                                        }.withoutNulls,
                                                                      );

                                                                      _model
                                                                          .timerController
                                                                          .onResetTimer();
                                                                    },
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );

                                                          await _model
                                                              .pageViewController
                                                              ?.animateToPage(
                                                            0,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    500),
                                                            curve: Curves.ease,
                                                          );
                                                        } else {
                                                          FFAppState()
                                                              .quesIndex = _model
                                                                  .pageViewCurrentIndex +
                                                              1;
                                                          safeSetState(() {});
                                                          FFAppState()
                                                              .selectedColorIndex = -1;
                                                          safeSetState(() {});
                                                          await _model
                                                              .pageViewController
                                                              ?.nextPage(
                                                            duration: Duration(
                                                                milliseconds:
                                                                    300),
                                                            curve: Curves.ease,
                                                          );
                                                        }

                                                        FFAppState().addToQuesType((QuizGroup
                                                            .getquestionsbyquizidApiCall
                                                            .questionTypeList(
                                                              (_model.quizRes
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )!
                                                            .elementAtOrNull(
                                                                _model.pageViewCurrentIndex +
                                                                    1))!);
                                                        safeSetState(() {});
                                                        _model.userAnswer =
                                                            null;
                                                        _model.actualAnswer =
                                                            null;
                                                        safeSetState(() {});
                                                      }
                                                    }
                                                  }
                                                }
                                              },
                                              text: FFAppState().quesIndex ==
                                                      QuizGroup
                                                          .getquestionsbyquizidApiCall
                                                          .questionDetailsList(
                                                            (_model.quizRes
                                                                    ?.jsonBody ??
                                                                ''),
                                                          )
                                                          ?.length
                                                  ? 'Submit'
                                                  : 'Next',
                                              options: FFButtonOptions(
                                                height: 56.0,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        24.0, 0.0, 24.0, 0.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily: 'Roboto',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .black,
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          useGoogleFonts: false,
                                                          lineHeight: 1.2,
                                                        ),
                                                elevation: 0.0,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              showLoadingIndicator: false,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150.0,
                      height: 70.0,
                      child: custom_widgets.ProgressIndicator(
                        width: 150.0,
                        height: 70.0,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
