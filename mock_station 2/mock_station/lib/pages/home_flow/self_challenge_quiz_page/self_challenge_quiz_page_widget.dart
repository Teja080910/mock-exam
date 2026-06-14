import '';
import '/backend/api_requests/api_calls.dart';
import '/componants/complete_quiz/complete_quiz_widget.dart';
import '/componants/option_dialog/option_dialog_widget.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'self_challenge_quiz_page_model.dart';
export 'self_challenge_quiz_page_model.dart';

class SelfChallengeQuizPageWidget extends StatefulWidget {
  const SelfChallengeQuizPageWidget({
    super.key,
    this.quizID,
    this.totalQues,
    this.timer,
    this.questime,
    this.title,
  });

  final String? quizID;
  final String? totalQues;
  final int? timer;
  final String? questime;
  final String? title;

  static String routeName = 'self_challenge_quizPage';
  static String routePath = '/selfChallengeQuizPage';

  @override
  State<SelfChallengeQuizPageWidget> createState() =>
      _SelfChallengeQuizPageWidgetState();
}

class _SelfChallengeQuizPageWidgetState
    extends State<SelfChallengeQuizPageWidget> {
  late SelfChallengeQuizPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SelfChallengeQuizPageModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      FFAppState().quesIndex = _model.pageViewCurrentIndex + 1;
      safeSetState(() {});
      _model.selfRes = await QuizGroup.selfchallangequizApiCall.call(
        quizId: widget.quizID,
        totalQuestions: widget.totalQues,
        timer: widget.timer?.toString(),
        token: FFAppState().loginToken,
      );

      _model.isLoading = false;
      safeSetState(() {});
      await Future.delayed(const Duration(milliseconds: 1000));
      _model.timerController.onResetTimer();

      _model.timerController.onStartTimer();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
            if (FFAppState().connected == true) {
              return Builder(
                builder: (context) {
                  if (QuizGroup.selfchallangequizApiCall.success(
                        (_model.selfRes?.jsonBody ?? ''),
                      ) ==
                      2) {
                    return Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Text(
                        valueOrDefault<String>(
                          QuizGroup.selfchallangequizApiCall.message(
                            (_model.selfRes?.jsonBody ?? ''),
                          ),
                          'Message',
                        ),
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Roboto',
                              fontSize: 18.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              useGoogleFonts: false,
                              lineHeight: 1.5,
                            ),
                      ),
                    );
                  } else {
                    return Builder(
                      builder: (context) {
                        if (_model.isLoading == false) {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 126.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Builder(
                                            builder: (context) => InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showDialog(
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return Dialog(
                                                      elevation: 0,
                                                      insetPadding:
                                                          EdgeInsets.zero,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      alignment:
                                                          AlignmentDirectional(
                                                                  0.0, 0.0)
                                                              .resolve(
                                                                  Directionality.of(
                                                                      context)),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(
                                                                  dialogContext)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child: Container(
                                                          height: 352.0,
                                                          child:
                                                              QuitQuizWidget(),
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
                                              },
                                              child: Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .lightGrey,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: SvgPicture.asset(
                                                    'assets/images/close.svg',
                                                    width: 24.0,
                                                    height: 24.0,
                                                    fit: BoxFit.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          RichText(
                                            textScaler: MediaQuery.of(context)
                                                .textScaler,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: 'Self Mode Quiz',
                                                  style: TextStyle(),
                                                )
                                              ],
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 22.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        useGoogleFonts: false,
                                                        lineHeight: 1.5,
                                                      ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional(0.0, 0.0),
                                            child: Builder(
                                              builder: (context) => InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  if (_model.userAnswer ==
                                                          null ||
                                                      _model.userAnswer == '') {
                                                    FFAppState().notAnswerQues =
                                                        FFAppState()
                                                                .notAnswerQues +
                                                            1;
                                                    FFAppState()
                                                        .addToNotAnswerQuestion(<String,
                                                            dynamic>{
                                                      'question_title':
                                                          getJsonField(
                                                        QuizGroup
                                                            .selfchallangequizApiCall
                                                            .quizdetailsList(
                                                              (_model.selfRes
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
                                                            .selfchallangequizApiCall
                                                            .quizdetailsList(
                                                              (_model.selfRes
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )
                                                            ?.elementAtOrNull(_model
                                                                .pageViewCurrentIndex),
                                                        r'''$.question_type''',
                                                      ),
                                                      'answer': getJsonField(
                                                        QuizGroup
                                                            .selfchallangequizApiCall
                                                            .quizdetailsList(
                                                              (_model.selfRes
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )
                                                            ?.elementAtOrNull(_model
                                                                .pageViewCurrentIndex),
                                                        r'''$.answer''',
                                                      ),
                                                      'option': getJsonField(
                                                        QuizGroup
                                                            .selfchallangequizApiCall
                                                            .quizdetailsList(
                                                              (_model.selfRes
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
                                                    FFAppState()
                                                        .quesIndex = _model
                                                            .pageViewCurrentIndex +
                                                        1;
                                                    FFAppState().update(() {});
                                                    if (QuizGroup
                                                            .selfchallangequizApiCall
                                                            .quizdetailsList(
                                                              (_model.selfRes
                                                                      ?.jsonBody ??
                                                                  ''),
                                                            )
                                                            ?.length ==
                                                        (_model.pageViewCurrentIndex +
                                                            1)) {
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
                                                                    SelfQuizResultWidget
                                                                        .routeName,
                                                                    queryParameters:
                                                                        {
                                                                      'correctAnswer':
                                                                          serializeParam(
                                                                        FFAppState()
                                                                            .correctSelfQues,
                                                                        ParamType
                                                                            .int,
                                                                      ),
                                                                      'wrongAnswer':
                                                                          serializeParam(
                                                                        FFAppState()
                                                                            .wrongSelfques,
                                                                        ParamType
                                                                            .int,
                                                                      ),
                                                                      'totalQuestion':
                                                                          serializeParam(
                                                                        QuizGroup
                                                                            .selfchallangequizApiCall
                                                                            .quizdetailsList(
                                                                              (_model.selfRes?.jsonBody ?? ''),
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
                                                                        QuizGroup
                                                                            .selfchallangequizApiCall
                                                                            .quizIdList(
                                                                              (_model.selfRes?.jsonBody ?? ''),
                                                                            )
                                                                            ?.firstOrNull,
                                                                        ParamType
                                                                            .String,
                                                                      ),
                                                                      'title':
                                                                          serializeParam(
                                                                        '',
                                                                        ParamType
                                                                            .String,
                                                                      ),
                                                                      'image':
                                                                          serializeParam(
                                                                        '',
                                                                        ParamType
                                                                            .String,
                                                                      ),
                                                                      'quizTime':
                                                                          serializeParam(
                                                                        '',
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
                                                      FFAppState()
                                                          .update(() {});
                                                      if (QuizGroup
                                                              .selfchallangequizApiCall
                                                              .quizdetailsList(
                                                                (_model.selfRes
                                                                        ?.jsonBody ??
                                                                    ''),
                                                              )
                                                              ?.length !=
                                                          FFAppState()
                                                              .quesIndex) {
                                                        await _model
                                                            .pageViewController
                                                            ?.nextPage(
                                                          duration: Duration(
                                                              milliseconds:
                                                                  300),
                                                          curve: Curves.ease,
                                                        );
                                                      }
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  width: 70.0,
                                                  height: 50.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: Text(
                                                    'Skip',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Roboto',
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                          alignment:
                                              AlignmentDirectional(-1.0, 0.0),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    20.0, 24.0, 0.0, 12.0),
                                            child: RichText(
                                              textScaler: MediaQuery.of(context)
                                                  .textScaler,
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Question ',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Roboto',
                                                          fontSize: 20.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          useGoogleFonts: false,
                                                          lineHeight: 1.5,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        (_model.pageViewCurrentIndex +
                                                                1)
                                                            .toString(),
                                                    style: TextStyle(),
                                                  ),
                                                  TextSpan(
                                                    text: ' of ',
                                                    style: TextStyle(),
                                                  ),
                                                  TextSpan(
                                                    text: QuizGroup
                                                        .selfchallangequizApiCall
                                                        .quizdetailsList(
                                                          (_model.selfRes
                                                                  ?.jsonBody ??
                                                              ''),
                                                        )!
                                                        .length
                                                        .toString(),
                                                    style: TextStyle(),
                                                  )
                                                ],
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Roboto',
                                                          fontSize: 20.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          useGoogleFonts: false,
                                                          lineHeight: 1.5,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView(
                                            padding: EdgeInsets.zero,
                                            primary: false,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            children: [
                                              Container(
                                                height: 625.0,
                                                decoration: BoxDecoration(),
                                                child: Builder(
                                                  builder: (context) {
                                                    final selfchallengeQuiz =
                                                        QuizGroup
                                                                .selfchallangequizApiCall
                                                                .quizdetailsList(
                                                                  (_model.selfRes
                                                                          ?.jsonBody ??
                                                                      ''),
                                                                )
                                                                ?.toList() ??
                                                            [];

                                                    return Container(
                                                      width: double.infinity,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    0.0,
                                                                    40.0),
                                                        child: PageView.builder(
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          controller: _model
                                                                  .pageViewController ??=
                                                              PageController(
                                                                  initialPage: max(
                                                                      0,
                                                                      min(
                                                                          0,
                                                                          selfchallengeQuiz.length -
                                                                              1))),
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              selfchallengeQuiz
                                                                  .length,
                                                          itemBuilder: (context,
                                                              selfchallengeQuizIndex) {
                                                            final selfchallengeQuizItem =
                                                                selfchallengeQuiz[
                                                                    selfchallengeQuizIndex];
                                                            return Builder(
                                                              builder:
                                                                  (context) {
                                                                if ('${getJsonField(
                                                                      selfchallengeQuizItem,
                                                                      r'''$.question_type''',
                                                                    ).toString()}' ==
                                                                    'text_only') {
                                                                  return Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            50.0,
                                                                            16.0,
                                                                            20.0),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        borderRadius:
                                                                            BorderRadius.circular(16.0),
                                                                      ),
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              -1.0),
                                                                      child:
                                                                          ListView(
                                                                        padding:
                                                                            EdgeInsets.fromLTRB(
                                                                          0,
                                                                          24.0,
                                                                          0,
                                                                          0,
                                                                        ),
                                                                        shrinkWrap:
                                                                            true,
                                                                        scrollDirection:
                                                                            Axis.vertical,
                                                                        children: [
                                                                          Align(
                                                                            alignment:
                                                                                AlignmentDirectional(-1.0, 0.0),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                                                                              child: Text(
                                                                                getJsonField(
                                                                                  selfchallengeQuizItem,
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
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                16.0),
                                                                            child:
                                                                                InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                _model.userAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.option.a''',
                                                                                ).toString();
                                                                                _model.actualAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.answer''',
                                                                                ).toString();
                                                                                safeSetState(() {});
                                                                                FFAppState().selectedColorIndex = 0;
                                                                                FFAppState().update(() {});
                                                                              },
                                                                              child: Container(
                                                                                width: 369.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FFAppState().selectedColorIndex == 0 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                child: Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(16.0),
                                                                                    child: Text(
                                                                                      getJsonField(
                                                                                        selfchallengeQuizItem,
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
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                16.0),
                                                                            child:
                                                                                InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                _model.userAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.option.b''',
                                                                                ).toString();
                                                                                _model.actualAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.answer''',
                                                                                ).toString();
                                                                                safeSetState(() {});
                                                                                FFAppState().selectedColorIndex = 1;
                                                                                FFAppState().update(() {});
                                                                              },
                                                                              child: Container(
                                                                                width: 369.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FFAppState().selectedColorIndex == 1 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                child: Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(16.0),
                                                                                    child: Text(
                                                                                      getJsonField(
                                                                                        selfchallengeQuizItem,
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
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                16.0),
                                                                            child:
                                                                                InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                _model.userAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.option.c''',
                                                                                ).toString();
                                                                                _model.actualAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.answer''',
                                                                                ).toString();
                                                                                safeSetState(() {});
                                                                                FFAppState().selectedColorIndex = 2;
                                                                                FFAppState().update(() {});
                                                                              },
                                                                              child: Container(
                                                                                width: 369.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FFAppState().selectedColorIndex == 2 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                child: Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(16.0),
                                                                                    child: Text(
                                                                                      getJsonField(
                                                                                        selfchallengeQuizItem,
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
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
                                                                              _model.userAnswer = getJsonField(
                                                                                selfchallengeQuizItem,
                                                                                r'''$.option.d''',
                                                                              ).toString();
                                                                              _model.actualAnswer = getJsonField(
                                                                                selfchallengeQuizItem,
                                                                                r'''$.answer''',
                                                                              ).toString();
                                                                              safeSetState(() {});
                                                                              FFAppState().selectedColorIndex = 3;
                                                                              FFAppState().update(() {});
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              width: 369.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FFAppState().selectedColorIndex == 3 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                borderRadius: BorderRadius.circular(12.0),
                                                                              ),
                                                                              child: Align(
                                                                                alignment: AlignmentDirectional(0.0, 0.0),
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.all(16.0),
                                                                                  child: Text(
                                                                                    getJsonField(
                                                                                      selfchallengeQuizItem,
                                                                                      r'''$.option.d''',
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
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else if ('${getJsonField(
                                                                      selfchallengeQuizItem,
                                                                      r'''$.question_type''',
                                                                    ).toString()}' ==
                                                                    'true_false') {
                                                                  return Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            50.0,
                                                                            16.0,
                                                                            20.0),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          50.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        borderRadius:
                                                                            BorderRadius.circular(16.0),
                                                                      ),
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              -1.0),
                                                                      child:
                                                                          ListView(
                                                                        padding:
                                                                            EdgeInsets.fromLTRB(
                                                                          0,
                                                                          24.0,
                                                                          0,
                                                                          24.0,
                                                                        ),
                                                                        primary:
                                                                            false,
                                                                        scrollDirection:
                                                                            Axis.vertical,
                                                                        children: [
                                                                          Align(
                                                                            alignment:
                                                                                AlignmentDirectional(-1.0, 0.0),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                                                                              child: Text(
                                                                                getJsonField(
                                                                                  selfchallengeQuizItem,
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
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                16.0),
                                                                            child:
                                                                                InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                _model.userAnswer = 'True';
                                                                                _model.actualAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.answer''',
                                                                                ).toString();
                                                                                safeSetState(() {});
                                                                                FFAppState().selectedColorIndex = 0;
                                                                                FFAppState().update(() {});
                                                                              },
                                                                              child: Container(
                                                                                width: 369.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FFAppState().selectedColorIndex == 0 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                alignment: AlignmentDirectional(0.0, 0.0),
                                                                                child: Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(16.0),
                                                                                    child: Text(
                                                                                      'True',
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
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                16.0),
                                                                            child:
                                                                                InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                _model.userAnswer = 'False';
                                                                                _model.actualAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.answer''',
                                                                                ).toString();
                                                                                safeSetState(() {});
                                                                                FFAppState().selectedColorIndex = 1;
                                                                                FFAppState().update(() {});
                                                                              },
                                                                              child: Container(
                                                                                width: 369.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FFAppState().selectedColorIndex == 1 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                child: Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(16.0),
                                                                                    child: Text(
                                                                                      'False',
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
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else if ('${getJsonField(
                                                                      selfchallengeQuizItem,
                                                                      r'''$.question_type''',
                                                                    ).toString()}' ==
                                                                    'images') {
                                                                  return Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            50.0,
                                                                            16.0,
                                                                            20.0),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          50.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        borderRadius:
                                                                            BorderRadius.circular(16.0),
                                                                      ),
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              -1.0),
                                                                      child:
                                                                          ListView(
                                                                        padding:
                                                                            EdgeInsets.fromLTRB(
                                                                          0,
                                                                          24.0,
                                                                          0,
                                                                          24.0,
                                                                        ),
                                                                        shrinkWrap:
                                                                            true,
                                                                        scrollDirection:
                                                                            Axis.vertical,
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                double.infinity,
                                                                            decoration:
                                                                                BoxDecoration(),
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              child: CachedNetworkImage(
                                                                                fadeInDuration: Duration(milliseconds: 500),
                                                                                fadeOutDuration: Duration(milliseconds: 500),
                                                                                imageUrl: getJsonField(
                                                                                          selfchallengeQuizItem,
                                                                                          r'''$.image''',
                                                                                        ) !=
                                                                                        null
                                                                                    ? '${FFAppConstants.imageBaseURL}${getJsonField(
                                                                                        selfchallengeQuizItem,
                                                                                        r'''$.image''',
                                                                                      ).toString()}'
                                                                                    : 'https://images.unsplash.com/photo-1472457974886-0ebcd59440cc?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyfHxsZWdvfGVufDB8fHx8MTcyNTUyNTYwMnww&ixlib=rb-4.0.3&q=80&w=1080',
                                                                                width: 200.0,
                                                                                height: 200.0,
                                                                                fit: BoxFit.contain,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Align(
                                                                            alignment:
                                                                                AlignmentDirectional(-1.0, 0.0),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 24.0),
                                                                              child: Text(
                                                                                getJsonField(
                                                                                  selfchallengeQuizItem,
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
                                                                          Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children:
                                                                                [
                                                                              Expanded(
                                                                                child: InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  focusColor: Colors.transparent,
                                                                                  hoverColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  onTap: () async {
                                                                                    _model.userAnswer = getJsonField(
                                                                                      selfchallengeQuizItem,
                                                                                      r'''$.option.a''',
                                                                                    ).toString();
                                                                                    _model.actualAnswer = getJsonField(
                                                                                      selfchallengeQuizItem,
                                                                                      r'''$.answer''',
                                                                                    ).toString();
                                                                                    safeSetState(() {});
                                                                                    FFAppState().selectedColorIndex = 0;
                                                                                    FFAppState().update(() {});
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(
                                                                                      color: FFAppState().selectedColorIndex == 0 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                      borderRadius: BorderRadius.circular(12.0),
                                                                                    ),
                                                                                    alignment: AlignmentDirectional(0.0, 0.0),
                                                                                    child: Align(
                                                                                      alignment: AlignmentDirectional(0.0, 0.0),
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.all(16.0),
                                                                                        child: Text(
                                                                                          getJsonField(
                                                                                            selfchallengeQuizItem,
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
                                                                              Expanded(
                                                                                child: InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  focusColor: Colors.transparent,
                                                                                  hoverColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  onTap: () async {
                                                                                    _model.userAnswer = getJsonField(
                                                                                      selfchallengeQuizItem,
                                                                                      r'''$.option.b''',
                                                                                    ).toString();
                                                                                    _model.actualAnswer = getJsonField(
                                                                                      selfchallengeQuizItem,
                                                                                      r'''$.answer''',
                                                                                    ).toString();
                                                                                    safeSetState(() {});
                                                                                    FFAppState().selectedColorIndex = 1;
                                                                                    FFAppState().update(() {});
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(
                                                                                      color: FFAppState().selectedColorIndex == 1 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                      borderRadius: BorderRadius.circular(12.0),
                                                                                    ),
                                                                                    child: Align(
                                                                                      alignment: AlignmentDirectional(0.0, 0.0),
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.all(16.0),
                                                                                        child: Text(
                                                                                          getJsonField(
                                                                                            selfchallengeQuizItem,
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
                                                                            ].divide(SizedBox(width: 16.0)),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                16.0,
                                                                                0.0,
                                                                                0.0),
                                                                            child:
                                                                                Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: InkWell(
                                                                                    splashColor: Colors.transparent,
                                                                                    focusColor: Colors.transparent,
                                                                                    hoverColor: Colors.transparent,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: () async {
                                                                                      _model.userAnswer = getJsonField(
                                                                                        selfchallengeQuizItem,
                                                                                        r'''$.option.c''',
                                                                                      ).toString();
                                                                                      _model.actualAnswer = getJsonField(
                                                                                        selfchallengeQuizItem,
                                                                                        r'''$.answer''',
                                                                                      ).toString();
                                                                                      safeSetState(() {});
                                                                                      FFAppState().selectedColorIndex = 2;
                                                                                      FFAppState().update(() {});
                                                                                    },
                                                                                    child: Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: FFAppState().selectedColorIndex == 2 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                        borderRadius: BorderRadius.circular(12.0),
                                                                                      ),
                                                                                      alignment: AlignmentDirectional(0.0, 0.0),
                                                                                      child: Align(
                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(16.0),
                                                                                          child: Text(
                                                                                            getJsonField(
                                                                                              selfchallengeQuizItem,
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
                                                                                Expanded(
                                                                                  child: InkWell(
                                                                                    splashColor: Colors.transparent,
                                                                                    focusColor: Colors.transparent,
                                                                                    hoverColor: Colors.transparent,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: () async {
                                                                                      _model.userAnswer = getJsonField(
                                                                                        selfchallengeQuizItem,
                                                                                        r'''$.option.d''',
                                                                                      ).toString();
                                                                                      _model.actualAnswer = getJsonField(
                                                                                        selfchallengeQuizItem,
                                                                                        r'''$.answer''',
                                                                                      ).toString();
                                                                                      safeSetState(() {});
                                                                                      FFAppState().selectedColorIndex = 3;
                                                                                      FFAppState().update(() {});
                                                                                    },
                                                                                    child: Container(
                                                                                      decoration: BoxDecoration(
                                                                                        color: FFAppState().selectedColorIndex == 3 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                        borderRadius: BorderRadius.circular(12.0),
                                                                                      ),
                                                                                      child: Align(
                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(16.0),
                                                                                          child: Text(
                                                                                            getJsonField(
                                                                                              selfchallengeQuizItem,
                                                                                              r'''$.option.d''',
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
                                                                              ].divide(SizedBox(width: 16.0)),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else if ('${getJsonField(
                                                                      selfchallengeQuizItem,
                                                                      r'''$.question_type''',
                                                                    ).toString()}' ==
                                                                    'audio') {
                                                                  return Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            16.0,
                                                                            50.0,
                                                                            16.0,
                                                                            20.0),
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          50.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .secondaryBackground,
                                                                        borderRadius:
                                                                            BorderRadius.circular(16.0),
                                                                      ),
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                              0.0,
                                                                              -1.0),
                                                                      child:
                                                                          ListView(
                                                                        padding:
                                                                            EdgeInsets.fromLTRB(
                                                                          0,
                                                                          24.0,
                                                                          0,
                                                                          24.0,
                                                                        ),
                                                                        primary:
                                                                            false,
                                                                        scrollDirection:
                                                                            Axis.vertical,
                                                                        children: [
                                                                          Align(
                                                                            alignment:
                                                                                AlignmentDirectional(-1.0, 0.0),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                                                                              child: Text(
                                                                                getJsonField(
                                                                                  selfchallengeQuizItem,
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
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                24.0),
                                                                            child:
                                                                                FlutterFlowAudioPlayer(
                                                                              audio: Audio.network(
                                                                                'https://filesamples.com/samples/audio/mp3/sample3.mp3',
                                                                                metas: Metas(
                                                                                  id: 'sample3.mp3-f8c6d9da',
                                                                                  title: 'Audio',
                                                                                ),
                                                                              ),
                                                                              titleTextStyle: FlutterFlowTheme.of(context).titleLarge.override(
                                                                                    fontFamily: 'Roboto',
                                                                                    letterSpacing: 0.0,
                                                                                    useGoogleFonts: false,
                                                                                  ),
                                                                              playbackDurationTextStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                                                    fontFamily: 'Roboto',
                                                                                    letterSpacing: 0.0,
                                                                                    useGoogleFonts: false,
                                                                                  ),
                                                                              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                                              playbackButtonColor: FlutterFlowTheme.of(context).primary,
                                                                              activeTrackColor: FlutterFlowTheme.of(context).primary,
                                                                              inactiveTrackColor: FlutterFlowTheme.of(context).alternate,
                                                                              elevation: 0.0,
                                                                              playInBackground: PlayInBackground.disabledRestoreOnForeground,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                16.0),
                                                                            child:
                                                                                InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                _model.userAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.option.a''',
                                                                                ).toString();
                                                                                _model.actualAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.answer''',
                                                                                ).toString();
                                                                                safeSetState(() {});
                                                                                FFAppState().selectedColorIndex = 0;
                                                                                FFAppState().update(() {});
                                                                              },
                                                                              child: Container(
                                                                                width: 369.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FFAppState().selectedColorIndex == 0 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                alignment: AlignmentDirectional(0.0, 0.0),
                                                                                child: Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(16.0),
                                                                                    child: Text(
                                                                                      getJsonField(
                                                                                        selfchallengeQuizItem,
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
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                16.0),
                                                                            child:
                                                                                InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                _model.userAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.option.b''',
                                                                                ).toString();
                                                                                _model.actualAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.answer''',
                                                                                ).toString();
                                                                                safeSetState(() {});
                                                                                FFAppState().selectedColorIndex = 1;
                                                                                FFAppState().update(() {});
                                                                              },
                                                                              child: Container(
                                                                                width: 369.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FFAppState().selectedColorIndex == 1 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                child: Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(16.0),
                                                                                    child: Text(
                                                                                      getJsonField(
                                                                                        selfchallengeQuizItem,
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
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                0.0,
                                                                                0.0,
                                                                                0.0,
                                                                                16.0),
                                                                            child:
                                                                                InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                _model.userAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.option.c''',
                                                                                ).toString();
                                                                                _model.actualAnswer = getJsonField(
                                                                                  selfchallengeQuizItem,
                                                                                  r'''$.answer''',
                                                                                ).toString();
                                                                                safeSetState(() {});
                                                                                FFAppState().selectedColorIndex = 2;
                                                                                FFAppState().update(() {});
                                                                              },
                                                                              child: Container(
                                                                                width: 369.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: FFAppState().selectedColorIndex == 2 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                ),
                                                                                child: Align(
                                                                                  alignment: AlignmentDirectional(0.0, 0.0),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(16.0),
                                                                                    child: Text(
                                                                                      getJsonField(
                                                                                        selfchallengeQuizItem,
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
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
                                                                              _model.userAnswer = getJsonField(
                                                                                selfchallengeQuizItem,
                                                                                r'''$.option.d''',
                                                                              ).toString();
                                                                              _model.actualAnswer = getJsonField(
                                                                                selfchallengeQuizItem,
                                                                                r'''$.answer''',
                                                                              ).toString();
                                                                              safeSetState(() {});
                                                                              FFAppState().selectedColorIndex = 3;
                                                                              FFAppState().update(() {});
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              width: 369.0,
                                                                              decoration: BoxDecoration(
                                                                                color: FFAppState().selectedColorIndex == 3 ? FlutterFlowTheme.of(context).primary : FlutterFlowTheme.of(context).grey,
                                                                                borderRadius: BorderRadius.circular(12.0),
                                                                              ),
                                                                              child: Align(
                                                                                alignment: AlignmentDirectional(0.0, 0.0),
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.all(16.0),
                                                                                  child: Text(
                                                                                    getJsonField(
                                                                                      selfchallengeQuizItem,
                                                                                      r'''$.option.d''',
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
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  return Container(
                                                                    width:
                                                                        100.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryBackground,
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 24.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Expanded(
                                                    child: Builder(
                                                      builder: (context) =>
                                                          Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    16.0,
                                                                    0.0,
                                                                    16.0,
                                                                    0.0),
                                                        child: FFButtonWidget(
                                                          onPressed: () async {
                                                            if (_model.userAnswer ==
                                                                    null ||
                                                                _model.userAnswer ==
                                                                    '') {
                                                              await showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (dialogContext) {
                                                                  return Dialog(
                                                                    elevation:
                                                                        0,
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
                                                                            Directionality.of(context)),
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        FocusScope.of(dialogContext)
                                                                            .unfocus();
                                                                        FocusManager
                                                                            .instance
                                                                            .primaryFocus
                                                                            ?.unfocus();
                                                                      },
                                                                      child:
                                                                          OptionDialogWidget(
                                                                        istimeout:
                                                                            () async {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            } else {
                                                              FFAppState()
                                                                      .userAns =
                                                                  _model
                                                                      .userAnswer!;
                                                              safeSetState(
                                                                  () {});
                                                              if ('${getJsonField(
                                                                    QuizGroup
                                                                        .selfchallangequizApiCall
                                                                        .quizdetailsList(
                                                                          (_model.selfRes?.jsonBody ??
                                                                              ''),
                                                                        )
                                                                        ?.elementAtOrNull(
                                                                            _model.pageViewCurrentIndex),
                                                                    r'''$.question_type''',
                                                                  ).toString()}' ==
                                                                  'text_only') {
                                                                FFAppState()
                                                                    .addToQuesList(<String,
                                                                        dynamic>{
                                                                  'question_title':
                                                                      getJsonField(
                                                                    QuizGroup
                                                                        .selfchallangequizApiCall
                                                                        .quizdetailsList(
                                                                          (_model.selfRes?.jsonBody ??
                                                                              ''),
                                                                        )
                                                                        ?.elementAtOrNull(
                                                                            _model.pageViewCurrentIndex),
                                                                    r'''$.question_title''',
                                                                  ),
                                                                  'question_type':
                                                                      getJsonField(
                                                                    QuizGroup
                                                                        .selfchallangequizApiCall
                                                                        .quizdetailsList(
                                                                          (_model.selfRes?.jsonBody ??
                                                                              ''),
                                                                        )
                                                                        ?.elementAtOrNull(
                                                                            _model.pageViewCurrentIndex),
                                                                    r'''$.question_type''',
                                                                  ),
                                                                  'answer':
                                                                      getJsonField(
                                                                    QuizGroup
                                                                        .selfchallangequizApiCall
                                                                        .quizdetailsList(
                                                                          (_model.selfRes?.jsonBody ??
                                                                              ''),
                                                                        )
                                                                        ?.elementAtOrNull(
                                                                            _model.pageViewCurrentIndex),
                                                                    r'''$.answer''',
                                                                  ),
                                                                  'option':
                                                                      getJsonField(
                                                                    QuizGroup
                                                                        .selfchallangequizApiCall
                                                                        .quizdetailsList(
                                                                          (_model.selfRes?.jsonBody ??
                                                                              ''),
                                                                        )
                                                                        ?.elementAtOrNull(
                                                                            _model.pageViewCurrentIndex),
                                                                    r'''$.option''',
                                                                  ),
                                                                  'user_answer':
                                                                      FFAppState()
                                                                          .userAns,
                                                                });
                                                                FFAppState()
                                                                    .update(
                                                                        () {});
                                                                if (_model
                                                                        .userAnswer ==
                                                                    _model
                                                                        .actualAnswer) {
                                                                  FFAppState()
                                                                          .correctSelfQues =
                                                                      FFAppState()
                                                                              .correctSelfQues +
                                                                          1;
                                                                  FFAppState()
                                                                      .update(
                                                                          () {});
                                                                } else {
                                                                  FFAppState()
                                                                          .wrongSelfques =
                                                                      FFAppState()
                                                                              .wrongSelfques +
                                                                          1;
                                                                  FFAppState()
                                                                      .update(
                                                                          () {});
                                                                }

                                                                FFAppState()
                                                                        .noOfQues =
                                                                    QuizGroup
                                                                        .selfchallangequizApiCall
                                                                        .quizdetailsList(
                                                                          (_model.selfRes?.jsonBody ??
                                                                              ''),
                                                                        )!
                                                                        .length;
                                                                FFAppState()
                                                                    .update(
                                                                        () {});
                                                                if (FFAppState()
                                                                        .noOfQues ==
                                                                    (_model.pageViewCurrentIndex +
                                                                        1)) {
                                                                  FFAppState()
                                                                      .selectedColorIndex = -1;
                                                                  FFAppState()
                                                                      .update(
                                                                          () {});
                                                                  _model
                                                                      .timerController
                                                                      .onStopTimer();
                                                                  await showDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (dialogContext) {
                                                                      return Dialog(
                                                                        elevation:
                                                                            0,
                                                                        insetPadding:
                                                                            EdgeInsets.zero,
                                                                        backgroundColor:
                                                                            Colors.transparent,
                                                                        alignment:
                                                                            AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            FocusScope.of(dialogContext).unfocus();
                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                          },
                                                                          child:
                                                                              CompleteQuizWidget(
                                                                            completed:
                                                                                () async {
                                                                              FFAppState().quesIndex = 0;
                                                                              safeSetState(() {});
                                                                              FFAppState().clearCoinsCache();

                                                                              context.goNamed(
                                                                                SelfQuizResultWidget.routeName,
                                                                                queryParameters: {
                                                                                  'correctAnswer': serializeParam(
                                                                                    FFAppState().correctSelfQues,
                                                                                    ParamType.int,
                                                                                  ),
                                                                                  'wrongAnswer': serializeParam(
                                                                                    FFAppState().wrongSelfques,
                                                                                    ParamType.int,
                                                                                  ),
                                                                                  'totalQuestion': serializeParam(
                                                                                    QuizGroup.selfchallangequizApiCall
                                                                                        .quizdetailsList(
                                                                                          (_model.selfRes?.jsonBody ?? ''),
                                                                                        )
                                                                                        ?.length,
                                                                                    ParamType.int,
                                                                                  ),
                                                                                  'notAnswer': serializeParam(
                                                                                    FFAppState().notAnswerQues,
                                                                                    ParamType.int,
                                                                                  ),
                                                                                  'quizID': serializeParam(
                                                                                    widget.quizID,
                                                                                    ParamType.String,
                                                                                  ),
                                                                                  'quizTime': serializeParam(
                                                                                    widget.questime,
                                                                                    ParamType.String,
                                                                                  ),
                                                                                }.withoutNulls,
                                                                              );

                                                                              _model.timerController.onResetTimer();
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
                                                                    curve: Curves
                                                                        .ease,
                                                                  );
                                                                } else {
                                                                  FFAppState()
                                                                          .quesIndex =
                                                                      _model.pageViewCurrentIndex +
                                                                          1;
                                                                  FFAppState()
                                                                      .update(
                                                                          () {});
                                                                  FFAppState()
                                                                      .selectedColorIndex = -1;
                                                                  FFAppState()
                                                                      .update(
                                                                          () {});
                                                                  _model.userAnswer =
                                                                      null;
                                                                  _model.actualAnswer =
                                                                      null;
                                                                  safeSetState(
                                                                      () {});
                                                                  await _model
                                                                      .pageViewController
                                                                      ?.nextPage(
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            300),
                                                                    curve: Curves
                                                                        .ease,
                                                                  );
                                                                }

                                                                FFAppState()
                                                                    .addToQuesType(
                                                                        getJsonField(
                                                                  QuizGroup
                                                                      .selfchallangequizApiCall
                                                                      .quizdetailsList(
                                                                        (_model.selfRes?.jsonBody ??
                                                                            ''),
                                                                      )!
                                                                      .elementAtOrNull(
                                                                          _model
                                                                              .pageViewCurrentIndex),
                                                                  r'''$.question_type''',
                                                                ).toString());
                                                                FFAppState()
                                                                    .update(
                                                                        () {});
                                                              } else {
                                                                if ('${getJsonField(
                                                                      QuizGroup
                                                                          .selfchallangequizApiCall
                                                                          .quizdetailsList(
                                                                            (_model.selfRes?.jsonBody ??
                                                                                ''),
                                                                          )
                                                                          ?.elementAtOrNull(
                                                                              _model.pageViewCurrentIndex),
                                                                      r'''$.question_type''',
                                                                    ).toString()}' ==
                                                                    'true_false') {
                                                                  FFAppState()
                                                                      .addToQuesList(<String,
                                                                          dynamic>{
                                                                    'question_title':
                                                                        getJsonField(
                                                                      QuizGroup
                                                                          .selfchallangequizApiCall
                                                                          .quizdetailsList(
                                                                            (_model.selfRes?.jsonBody ??
                                                                                ''),
                                                                          )
                                                                          ?.elementAtOrNull(
                                                                              _model.pageViewCurrentIndex),
                                                                      r'''$.question_title''',
                                                                    ),
                                                                    'question_type':
                                                                        getJsonField(
                                                                      QuizGroup
                                                                          .selfchallangequizApiCall
                                                                          .quizdetailsList(
                                                                            (_model.selfRes?.jsonBody ??
                                                                                ''),
                                                                          )
                                                                          ?.elementAtOrNull(
                                                                              _model.pageViewCurrentIndex),
                                                                      r'''$.question_type''',
                                                                    ),
                                                                    'answer':
                                                                        getJsonField(
                                                                      QuizGroup
                                                                          .selfchallangequizApiCall
                                                                          .quizdetailsList(
                                                                            (_model.selfRes?.jsonBody ??
                                                                                ''),
                                                                          )
                                                                          ?.elementAtOrNull(
                                                                              _model.pageViewCurrentIndex),
                                                                      r'''$.answer''',
                                                                    ),
                                                                    'user_answer':
                                                                        FFAppState()
                                                                            .userAns,
                                                                  });
                                                                  FFAppState()
                                                                      .update(
                                                                          () {});
                                                                  if (_model
                                                                          .userAnswer ==
                                                                      _model
                                                                          .actualAnswer) {
                                                                    FFAppState()
                                                                            .correctSelfQues =
                                                                        FFAppState().correctSelfQues +
                                                                            1;
                                                                    FFAppState()
                                                                        .update(
                                                                            () {});
                                                                  } else {
                                                                    FFAppState()
                                                                            .wrongSelfques =
                                                                        FFAppState().wrongSelfques +
                                                                            1;
                                                                    FFAppState()
                                                                        .update(
                                                                            () {});
                                                                  }

                                                                  FFAppState()
                                                                          .noOfQues =
                                                                      QuizGroup
                                                                          .selfchallangequizApiCall
                                                                          .quizdetailsList(
                                                                            (_model.selfRes?.jsonBody ??
                                                                                ''),
                                                                          )!
                                                                          .length;
                                                                  FFAppState()
                                                                      .update(
                                                                          () {});
                                                                  if (FFAppState()
                                                                          .noOfQues ==
                                                                      (_model.pageViewCurrentIndex +
                                                                          1)) {
                                                                    FFAppState()
                                                                        .selectedColorIndex = -1;
                                                                    FFAppState()
                                                                        .update(
                                                                            () {});
                                                                    _model
                                                                        .timerController
                                                                        .onStopTimer();
                                                                    await showDialog(
                                                                      barrierDismissible:
                                                                          false,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (dialogContext) {
                                                                        return Dialog(
                                                                          elevation:
                                                                              0,
                                                                          insetPadding:
                                                                              EdgeInsets.zero,
                                                                          backgroundColor:
                                                                              Colors.transparent,
                                                                          alignment:
                                                                              AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(dialogContext).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                CompleteQuizWidget(
                                                                              completed: () async {
                                                                                FFAppState().quesIndex = 0;
                                                                                FFAppState().update(() {});
                                                                                FFAppState().clearCoinsCache();

                                                                                context.goNamed(
                                                                                  SelfQuizResultWidget.routeName,
                                                                                  queryParameters: {
                                                                                    'correctAnswer': serializeParam(
                                                                                      FFAppState().correctSelfQues,
                                                                                      ParamType.int,
                                                                                    ),
                                                                                    'wrongAnswer': serializeParam(
                                                                                      FFAppState().wrongSelfques,
                                                                                      ParamType.int,
                                                                                    ),
                                                                                    'totalQuestion': serializeParam(
                                                                                      QuizGroup.selfchallangequizApiCall
                                                                                          .quizdetailsList(
                                                                                            (_model.selfRes?.jsonBody ?? ''),
                                                                                          )
                                                                                          ?.length,
                                                                                      ParamType.int,
                                                                                    ),
                                                                                    'notAnswer': serializeParam(
                                                                                      FFAppState().notAnswerQues,
                                                                                      ParamType.int,
                                                                                    ),
                                                                                    'quizID': serializeParam(
                                                                                      widget.quizID,
                                                                                      ParamType.String,
                                                                                    ),
                                                                                    'quizTime': serializeParam(
                                                                                      widget.questime,
                                                                                      ParamType.String,
                                                                                    ),
                                                                                  }.withoutNulls,
                                                                                );

                                                                                _model.timerController.onResetTimer();
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
                                                                      curve: Curves
                                                                          .ease,
                                                                    );
                                                                  } else {
                                                                    FFAppState()
                                                                            .quesIndex =
                                                                        _model.pageViewCurrentIndex +
                                                                            1;
                                                                    FFAppState()
                                                                        .update(
                                                                            () {});
                                                                    FFAppState()
                                                                        .selectedColorIndex = -1;
                                                                    FFAppState()
                                                                        .update(
                                                                            () {});
                                                                    _model.userAnswer =
                                                                        null;
                                                                    _model.actualAnswer =
                                                                        null;
                                                                    safeSetState(
                                                                        () {});
                                                                    await _model
                                                                        .pageViewController
                                                                        ?.nextPage(
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              300),
                                                                      curve: Curves
                                                                          .ease,
                                                                    );
                                                                  }

                                                                  FFAppState()
                                                                      .addToQuesType(
                                                                          getJsonField(
                                                                    QuizGroup
                                                                        .selfchallangequizApiCall
                                                                        .quizdetailsList(
                                                                          (_model.selfRes?.jsonBody ??
                                                                              ''),
                                                                        )!
                                                                        .elementAtOrNull(
                                                                            _model.pageViewCurrentIndex),
                                                                    r'''$.question_type''',
                                                                  ).toString());
                                                                  FFAppState()
                                                                      .update(
                                                                          () {});
                                                                } else {
                                                                  if ('${getJsonField(
                                                                        QuizGroup
                                                                            .selfchallangequizApiCall
                                                                            .quizdetailsList(
                                                                              (_model.selfRes?.jsonBody ?? ''),
                                                                            )
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.question_type''',
                                                                      ).toString()}' ==
                                                                      'images') {
                                                                    FFAppState()
                                                                        .addToQuesList(<String,
                                                                            dynamic>{
                                                                      'question_title':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .selfchallangequizApiCall
                                                                            .quizdetailsList(
                                                                              (_model.selfRes?.jsonBody ?? ''),
                                                                            )
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.question_title''',
                                                                      ),
                                                                      'question_type':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .selfchallangequizApiCall
                                                                            .quizdetailsList(
                                                                              (_model.selfRes?.jsonBody ?? ''),
                                                                            )
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.question_type''',
                                                                      ),
                                                                      'answer':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .selfchallangequizApiCall
                                                                            .quizdetailsList(
                                                                              (_model.selfRes?.jsonBody ?? ''),
                                                                            )
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.answer''',
                                                                      ),
                                                                      'option':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .selfchallangequizApiCall
                                                                            .quizdetailsList(
                                                                              (_model.selfRes?.jsonBody ?? ''),
                                                                            )
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.option''',
                                                                      ),
                                                                      'user_answer':
                                                                          FFAppState()
                                                                              .userAns,
                                                                    });
                                                                    FFAppState()
                                                                        .update(
                                                                            () {});
                                                                    if (_model
                                                                            .userAnswer ==
                                                                        _model
                                                                            .actualAnswer) {
                                                                      FFAppState()
                                                                              .correctSelfQues =
                                                                          FFAppState().correctSelfQues +
                                                                              1;
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                    } else {
                                                                      FFAppState()
                                                                              .wrongSelfques =
                                                                          FFAppState().wrongSelfques +
                                                                              1;
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                    }

                                                                    FFAppState()
                                                                            .noOfQues =
                                                                        QuizGroup
                                                                            .selfchallangequizApiCall
                                                                            .quizdetailsList(
                                                                              (_model.selfRes?.jsonBody ?? ''),
                                                                            )!
                                                                            .length;
                                                                    FFAppState()
                                                                        .update(
                                                                            () {});
                                                                    if (FFAppState()
                                                                            .noOfQues ==
                                                                        (_model.pageViewCurrentIndex +
                                                                            1)) {
                                                                      FFAppState()
                                                                          .selectedColorIndex = -1;
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                      _model
                                                                          .timerController
                                                                          .onStopTimer();
                                                                      await showDialog(
                                                                        barrierDismissible:
                                                                            false,
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (dialogContext) {
                                                                          return Dialog(
                                                                            elevation:
                                                                                0,
                                                                            insetPadding:
                                                                                EdgeInsets.zero,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            alignment:
                                                                                AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
                                                                            child:
                                                                                GestureDetector(
                                                                              onTap: () {
                                                                                FocusScope.of(dialogContext).unfocus();
                                                                                FocusManager.instance.primaryFocus?.unfocus();
                                                                              },
                                                                              child: CompleteQuizWidget(
                                                                                completed: () async {
                                                                                  FFAppState().quesIndex = 0;
                                                                                  FFAppState().update(() {});
                                                                                  FFAppState().clearCoinsCache();

                                                                                  context.goNamed(
                                                                                    SelfQuizResultWidget.routeName,
                                                                                    queryParameters: {
                                                                                      'correctAnswer': serializeParam(
                                                                                        FFAppState().correctSelfQues,
                                                                                        ParamType.int,
                                                                                      ),
                                                                                      'wrongAnswer': serializeParam(
                                                                                        FFAppState().wrongSelfques,
                                                                                        ParamType.int,
                                                                                      ),
                                                                                      'totalQuestion': serializeParam(
                                                                                        QuizGroup.selfchallangequizApiCall
                                                                                            .quizdetailsList(
                                                                                              (_model.selfRes?.jsonBody ?? ''),
                                                                                            )
                                                                                            ?.length,
                                                                                        ParamType.int,
                                                                                      ),
                                                                                      'notAnswer': serializeParam(
                                                                                        FFAppState().notAnswerQues,
                                                                                        ParamType.int,
                                                                                      ),
                                                                                      'quizID': serializeParam(
                                                                                        widget.quizID,
                                                                                        ParamType.String,
                                                                                      ),
                                                                                      'quizTime': serializeParam(
                                                                                        widget.questime,
                                                                                        ParamType.String,
                                                                                      ),
                                                                                    }.withoutNulls,
                                                                                  );

                                                                                  _model.timerController.onResetTimer();
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
                                                                        duration:
                                                                            Duration(milliseconds: 500),
                                                                        curve: Curves
                                                                            .ease,
                                                                      );
                                                                    } else {
                                                                      FFAppState()
                                                                              .quesIndex =
                                                                          _model.pageViewCurrentIndex +
                                                                              1;
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                      FFAppState()
                                                                          .selectedColorIndex = -1;
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                      _model.userAnswer =
                                                                          null;
                                                                      _model.actualAnswer =
                                                                          null;
                                                                      safeSetState(
                                                                          () {});
                                                                      await _model
                                                                          .pageViewController
                                                                          ?.nextPage(
                                                                        duration:
                                                                            Duration(milliseconds: 300),
                                                                        curve: Curves
                                                                            .ease,
                                                                      );
                                                                    }

                                                                    FFAppState()
                                                                        .addToQuesType(
                                                                            getJsonField(
                                                                      QuizGroup
                                                                          .selfchallangequizApiCall
                                                                          .quizdetailsList(
                                                                            (_model.selfRes?.jsonBody ??
                                                                                ''),
                                                                          )!
                                                                          .elementAtOrNull(
                                                                              _model.pageViewCurrentIndex),
                                                                      r'''$.question_type''',
                                                                    ).toString());
                                                                    FFAppState()
                                                                        .update(
                                                                            () {});
                                                                  } else {
                                                                    if ('${getJsonField(
                                                                          QuizGroup
                                                                              .selfchallangequizApiCall
                                                                              .quizdetailsList(
                                                                                (_model.selfRes?.jsonBody ?? ''),
                                                                              )
                                                                              ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                          r'''$.question_type''',
                                                                        ).toString()}' ==
                                                                        'audio') {
                                                                      FFAppState()
                                                                          .addToQuesList(<String,
                                                                              dynamic>{
                                                                        'question_title':
                                                                            getJsonField(
                                                                          QuizGroup
                                                                              .selfchallangequizApiCall
                                                                              .quizdetailsList(
                                                                                (_model.selfRes?.jsonBody ?? ''),
                                                                              )
                                                                              ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                          r'''$.question_title''',
                                                                        ),
                                                                        'question_type':
                                                                            getJsonField(
                                                                          QuizGroup
                                                                              .selfchallangequizApiCall
                                                                              .quizdetailsList(
                                                                                (_model.selfRes?.jsonBody ?? ''),
                                                                              )
                                                                              ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                          r'''$.question_type''',
                                                                        ),
                                                                        'answer':
                                                                            getJsonField(
                                                                          QuizGroup
                                                                              .selfchallangequizApiCall
                                                                              .quizdetailsList(
                                                                                (_model.selfRes?.jsonBody ?? ''),
                                                                              )
                                                                              ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                          r'''$.answer''',
                                                                        ),
                                                                        'option':
                                                                            getJsonField(
                                                                          QuizGroup
                                                                              .selfchallangequizApiCall
                                                                              .quizdetailsList(
                                                                                (_model.selfRes?.jsonBody ?? ''),
                                                                              )
                                                                              ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                          r'''$.option''',
                                                                        ),
                                                                        'user_answer':
                                                                            FFAppState().userAns,
                                                                      });
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                      if (_model
                                                                              .userAnswer ==
                                                                          _model
                                                                              .actualAnswer) {
                                                                        FFAppState()
                                                                            .correctSelfQues = FFAppState()
                                                                                .correctSelfQues +
                                                                            1;
                                                                        FFAppState()
                                                                            .update(() {});
                                                                      } else {
                                                                        FFAppState()
                                                                            .wrongSelfques = FFAppState()
                                                                                .wrongSelfques +
                                                                            1;
                                                                        FFAppState()
                                                                            .update(() {});
                                                                      }

                                                                      FFAppState().noOfQues = QuizGroup
                                                                          .selfchallangequizApiCall
                                                                          .quizdetailsList(
                                                                            (_model.selfRes?.jsonBody ??
                                                                                ''),
                                                                          )!
                                                                          .length;
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                      if (FFAppState()
                                                                              .noOfQues ==
                                                                          (_model.pageViewCurrentIndex +
                                                                              1)) {
                                                                        FFAppState().selectedColorIndex =
                                                                            -1;
                                                                        safeSetState(
                                                                            () {});
                                                                        _model
                                                                            .timerController
                                                                            .onStopTimer();
                                                                        await showDialog(
                                                                          barrierDismissible:
                                                                              false,
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (dialogContext) {
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
                                                                                child: CompleteQuizWidget(
                                                                                  completed: () async {
                                                                                    FFAppState().quesIndex = 0;
                                                                                    safeSetState(() {});
                                                                                    FFAppState().clearCoinsCache();

                                                                                    context.goNamed(
                                                                                      SelfQuizResultWidget.routeName,
                                                                                      queryParameters: {
                                                                                        'correctAnswer': serializeParam(
                                                                                          FFAppState().correctSelfQues,
                                                                                          ParamType.int,
                                                                                        ),
                                                                                        'wrongAnswer': serializeParam(
                                                                                          FFAppState().wrongSelfques,
                                                                                          ParamType.int,
                                                                                        ),
                                                                                        'totalQuestion': serializeParam(
                                                                                          QuizGroup.selfchallangequizApiCall
                                                                                              .quizdetailsList(
                                                                                                (_model.selfRes?.jsonBody ?? ''),
                                                                                              )
                                                                                              ?.length,
                                                                                          ParamType.int,
                                                                                        ),
                                                                                        'notAnswer': serializeParam(
                                                                                          FFAppState().notAnswerQues,
                                                                                          ParamType.int,
                                                                                        ),
                                                                                        'quizID': serializeParam(
                                                                                          widget.quizID,
                                                                                          ParamType.String,
                                                                                        ),
                                                                                        'quizTime': serializeParam(
                                                                                          widget.questime,
                                                                                          ParamType.String,
                                                                                        ),
                                                                                      }.withoutNulls,
                                                                                    );

                                                                                    _model.timerController.onResetTimer();
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
                                                                          duration:
                                                                              Duration(milliseconds: 500),
                                                                          curve:
                                                                              Curves.ease,
                                                                        );
                                                                      } else {
                                                                        FFAppState()
                                                                            .quesIndex = _model
                                                                                .pageViewCurrentIndex +
                                                                            1;
                                                                        safeSetState(
                                                                            () {});
                                                                        FFAppState().selectedColorIndex =
                                                                            -1;
                                                                        safeSetState(
                                                                            () {});
                                                                        _model.userAnswer =
                                                                            null;
                                                                        _model.actualAnswer =
                                                                            null;
                                                                        safeSetState(
                                                                            () {});
                                                                        await _model
                                                                            .pageViewController
                                                                            ?.nextPage(
                                                                          duration:
                                                                              Duration(milliseconds: 300),
                                                                          curve:
                                                                              Curves.ease,
                                                                        );
                                                                      }

                                                                      FFAppState()
                                                                          .addToQuesType(
                                                                              getJsonField(
                                                                        QuizGroup
                                                                            .selfchallangequizApiCall
                                                                            .quizdetailsList(
                                                                              (_model.selfRes?.jsonBody ?? ''),
                                                                            )!
                                                                            .elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.question_type''',
                                                                      ).toString());
                                                                      FFAppState()
                                                                          .update(
                                                                              () {});
                                                                    }
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          },
                                                          text: FFAppState()
                                                                      .quesIndex ==
                                                                  QuizGroup
                                                                      .selfchallangequizApiCall
                                                                      .quizdetailsList(
                                                                        (_model.selfRes?.jsonBody ??
                                                                            ''),
                                                                      )
                                                                      ?.length
                                                              ? 'Submit'
                                                              : 'Next',
                                                          options:
                                                              FFButtonOptions(
                                                            height: 56.0,
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        24.0,
                                                                        0.0,
                                                                        24.0,
                                                                        0.0),
                                                            iconPadding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .black,
                                                                      fontSize:
                                                                          18.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      useGoogleFonts:
                                                                          false,
                                                                      lineHeight:
                                                                          1.2,
                                                                    ),
                                                            elevation: 0.0,
                                                            borderSide:
                                                                BorderSide(
                                                              color: Colors
                                                                  .transparent,
                                                              width: 1.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                          showLoadingIndicator:
                                                              false,
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
                                    Align(
                                      alignment:
                                          AlignmentDirectional(0.0, -1.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 62.0, 16.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 15.0, 0.0, 0.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: Container(
                                                    width: 309.0,
                                                    height: 10.0,
                                                    child: custom_widgets
                                                        .LinearBarTimer(
                                                      width: 309.0,
                                                      height: 10.0,
                                                      time: widget.timer,
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
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                              ),
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: Builder(
                                                builder: (context) =>
                                                    FlutterFlowTimer(
                                                  initialTime:
                                                      (widget.timer!) * 1000,
                                                  getDisplayTime: (value) =>
                                                      StopWatchTimer
                                                          .getDisplayTime(
                                                    value,
                                                    hours: false,
                                                    milliSecond: false,
                                                  ),
                                                  controller:
                                                      _model.timerController,
                                                  updateStateInterval: Duration(
                                                      milliseconds: 1000),
                                                  onChanged: (value,
                                                      displayTime,
                                                      shouldUpdate) {
                                                    _model.timerMilliseconds =
                                                        value;
                                                    _model.timerValue =
                                                        displayTime;
                                                    if (shouldUpdate)
                                                      safeSetState(() {});
                                                  },
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Roboto',
                                                        color: Colors.white,
                                                        fontSize: 16.0,
                                                        useGoogleFonts: false,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ].divide(SizedBox(width: 16.0)),
                                        ),
                                      ),
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
                    );
                  }
                },
              );
            } else {
              return Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Lottie.asset(
                  'assets/jsons/No_Wifi.json',
                  width: 150.0,
                  height: 150.0,
                  fit: BoxFit.contain,
                  animate: true,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
