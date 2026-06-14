import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_audio_player.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'quiz_review_screen_model.dart';
export 'quiz_review_screen_model.dart';

class QuizReviewScreenWidget extends StatefulWidget {
  const QuizReviewScreenWidget({
    super.key,
    this.catID,
  });

  final String? catID;

  static String routeName = 'quiz_review_screen';
  static String routePath = '/quizReviewScreen';

  @override
  State<QuizReviewScreenWidget> createState() => _QuizReviewScreenWidgetState();
}

class _QuizReviewScreenWidgetState extends State<QuizReviewScreenWidget>
    with TickerProviderStateMixin {
  late QuizReviewScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Helper function to extract option image
  String extractOptionImage(dynamic optionData) {
    if (optionData is Map) {
      final image = getJsonField(optionData, r'$.image');
      if (image != null && image.toString().isNotEmpty) {
        return image.toString();
      }
    }
    return '';
  }

  // Helper function to extract option text
  String extractOptionText(dynamic optionData) {
    if (optionData is Map) {
      final text = getJsonField(optionData, r'$.text');
      if (text is Map) {
        return getJsonField(text, r'$.text')?.toString() ?? '';
      } else if (text != null) {
        return text.toString();
      }
    } else if (optionData != null) {
      return optionData.toString();
    }
    return '';
  }

  // Helper function to build question HTML widget with images
  Map<String, Style> _questionHtmlStyle(BuildContext context) {
    final baseTextStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'Roboto',
          fontSize: 15.0,
          letterSpacing: 0.0,
          fontWeight: FontWeight.bold,
          useGoogleFonts: false,
          lineHeight: 1.5,
        );

    final style = Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      color: FlutterFlowTheme.of(context).primaryText,
      fontFamily: baseTextStyle.fontFamily,
      fontSize: FontSize(baseTextStyle.fontSize ?? 15.0),
      fontWeight: baseTextStyle.fontWeight,
      letterSpacing: baseTextStyle.letterSpacing,
      lineHeight: LineHeight(baseTextStyle.height ?? 1.5),
    );

    return {
      "body": style,
      "p": style,
      "span": style,
    };
  }

  Widget _buildQuestionHtmlWidget({
    required BuildContext context,
    required String questionHtml,
  }) {
    final cleanedHtml = questionHtml.replaceAll('&quot;', '"');

    return Container(
      width: double.infinity,
      child: Html(
        data: cleanedHtml,
        style: _questionHtmlStyle(context),
        onLinkTap: (url, attributes, element) {
          // Handle link taps if needed
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => QuizReviewScreenModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Builder(
          builder: (context) {
            if (FFAppState().connected == true) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.appBarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: AppBarWidget(
                      title: 'Test overview',
                      backIcon: false,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment(0.0, 0),
                          child: TabBar(
                            labelColor:
                                FlutterFlowTheme.of(context).primaryText,
                            unselectedLabelColor:
                                FlutterFlowTheme.of(context).secondaryText,
                            labelStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Roboto',
                                  letterSpacing: 0.0,
                                  useGoogleFonts: false,
                                ),
                            unselectedLabelStyle: TextStyle(),
                            indicatorColor:
                                FlutterFlowTheme.of(context).primary,
                            padding: EdgeInsets.all(4.0),
                            tabs: [
                              Tab(
                                text: 'Answered',
                              ),
                              Tab(
                                text: 'Skipped',
                              ),
                            ],
                            controller: _model.tabBarController,
                            onTap: (i) async {
                              [() async {}, () async {}][i]();
                            },
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _model.tabBarController,
                            children: [
                              Builder(
                                builder: (context) {
                                  final ques = FFAppState()
                                      .quesReviewList
                                      .where((q) =>
                                          q['user_answer'] != null &&
                                          q['user_answer'] != 'skipped')
                                      .toList();

                                  return ListView.separated(
                                    padding: EdgeInsets.fromLTRB(
                                      0,
                                      13.0,
                                      0,
                                      13.0,
                                    ),
                                    primary: false,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: ques.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 16.0),
                                    itemBuilder: (context, quesIndex) {
                                      final quesItem = ques[quesIndex];
print('=quesItem==ANSWER=>>>${quesItem}');
                                      final options = quesItem['option'] ?? {};
                                      final userAnswer =
                                          quesItem['user_answer'];
                                      final correctAnswer =
                                          quesItem['correct_answer'] ??
                                              quesItem['answer'];

                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            10.0, 0.0, 10.0, 0.0),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .white,
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 15.0,
                                                color: Color(0x1A000000),
                                                offset: Offset(0.0, 4.0),
                                                spreadRadius: 0.0,
                                              )
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsetsGeometry.all(8),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Question title with HTML support (includes images)
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Q${quesIndex + 1}. ',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                'Roboto',
                                                            fontSize: 15.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            useGoogleFonts:
                                                                false,
                                                            lineHeight: 1.5,
                                                          ),
                                                    ),
                                                    Expanded(
                                                      child:
                                                          _buildQuestionHtmlWidget(
                                                        context: context,
                                                        questionHtml: getJsonField(
                                                                quesItem,
                                                                r'''$.question_title''')
                                                            .toString(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // Question image - show if image field exists and is not empty
                                                if (getJsonField(quesItem,
                                                    r'''$.image''') !=
                                                    null &&
                                                    getJsonField(quesItem,
                                                        r'''$.image''')
                                                        .toString()
                                                        .isNotEmpty)
                                                  Padding(
                                                    padding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(0.0, 16.0,
                                                        0.0, 16.0),
                                                    child: Center(
                                                      child: Container(
                                                        width: double.infinity,
                                                        constraints:
                                                        BoxConstraints(
                                                          maxWidth: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .width -
                                                              64.0,
                                                          maxHeight: 300.0,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              12.0),
                                                          child:
                                                          CachedNetworkImage(
                                                            imageUrl:
                                                            '${FFAppConstants.imageBaseURL}${getJsonField(quesItem, r'''$.image''').toString()}',
                                                            width:
                                                            double.infinity,
                                                            fit: BoxFit.contain,
                                                            alignment:
                                                            Alignment(
                                                                0.0, 0.0),
                                                            placeholder:
                                                                (context,
                                                                url) =>
                                                                Center(
                                                                  child:
                                                                  CircularProgressIndicator(
                                                                    valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                        Color>(
                                                                      FlutterFlowTheme.of(
                                                                          context)
                                                                          .primary,
                                                                    ),
                                                                  ),
                                                                ),
                                                            errorWidget: (context,
                                                                url,
                                                                error) =>
                                                                SizedBox
                                                                    .shrink(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                ...List.generate(options.length,
                                                    (optionIndex) {
                                                  final optionKeys =
                                                      options.keys.toList();
                                                  final optionKey =
                                                      optionKeys[optionIndex];
                                                  final option =
                                                      options[optionKey];
                                                  // Check if this option's text matches the correct answer
                                                  final normalize = (dynamic
                                                          value) =>
                                                      (value ?? '')
                                                          .toString()
                                                          .replaceAll(
                                                              RegExp(r'\s+'),
                                                              ' ')
                                                          .trim()
                                                          .toLowerCase();

                                                  final optionText = option !=
                                                              null &&
                                                          option['text'] != null
                                                      ? (option['text'] is Map
                                                          ? (option['text']
                                                                  ['text'] ??
                                                              option['text']
                                                                  .toString())
                                                          : option['text']
                                                              .toString())
                                                      : '';

                                                  final optionTextNormalized =
                                                      normalize(optionText);
                                                  final userAnswerNormalized =
                                                      normalize(userAnswer);
                                                  final correctAnswerNormalized =
                                                      normalize(correctAnswer);
                                                  final optionKeyNormalized =
                                                      normalize(optionKey);

                                                  final isCorrectAnswer =
                                                      correctAnswerNormalized
                                                              .isNotEmpty &&
                                                          (optionKeyNormalized ==
                                                                  correctAnswerNormalized ||
                                                              optionTextNormalized ==
                                                                  correctAnswerNormalized);

                                                  final isUserSelected = userAnswerNormalized
                                                          .isNotEmpty &&
                                                      (optionKeyNormalized ==
                                                              userAnswerNormalized ||
                                                          optionTextNormalized ==
                                                              userAnswerNormalized);

                                                  // Check if user selected the correct answer
                                                  // This is true if: user selected this option AND this option is the correct answer
                                                  final isUserCorrect =
                                                      isUserSelected &&
                                                          isCorrectAnswer;

                                                  // Debug logging for answered tab

                                                  return Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 8.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      children: [
                                                        // Icon indicator
                                                        Container(
                                                          width: 24.0,
                                                          height: 24.0,
                                                          child: isUserCorrect
                                                              ? Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: Colors
                                                                      .green,
                                                                  size: 24.0,
                                                                )
                                                              : isCorrectAnswer
                                                                  ? Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      color: Colors
                                                                          .green,
                                                                      size:
                                                                          24.0,
                                                                    )
                                                                  : isUserSelected
                                                                      ? Icon(
                                                                          Icons
                                                                              .cancel,
                                                                          color:
                                                                              Colors.red,
                                                                          size:
                                                                              24.0,
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .cancel,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryText,
                                                                          size:
                                                                              24.0,
                                                                        ),
                                                        ),
                                                        SizedBox(width: 12.0),

                                                        // Option content
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // Image for image-based options
                                                              if (getJsonField(quesItem,
                                                                              r'''$.question_type''')
                                                                          .toString() ==
                                                                      'images' &&
                                                                  option !=
                                                                      null &&
                                                                  option['image'] !=
                                                                      null &&
                                                                  option['image']
                                                                      .toString()
                                                                      .isNotEmpty)
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          8.0),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl:
                                                                          '${FFAppConstants.imageBaseURL}${option['image']}',
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                                  ),
                                                                ),

                                                              // Option text
                                                              RichText(
                                                                textScaler: MediaQuery.of(
                                                                        context)
                                                                    .textScaler,
                                                                text: TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text: extractOptionText(
                                                                          option),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            fontSize:
                                                                                17.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            useGoogleFonts:
                                                                                false,
                                                                            lineHeight:
                                                                                1.5,
                                                                          ),
                                                                    ),
                                                                    if (isUserCorrect)
                                                                      TextSpan(
                                                                        text:
                                                                            ' (Correct Answer & Your Answer)',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      )
                                                                    else if (isCorrectAnswer)
                                                                      TextSpan(
                                                                        text:
                                                                            ' (Correct Answer)',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      )
                                                                    else if (isUserSelected)
                                                                      TextSpan(
                                                                        text:
                                                                            ' (Your Answer)',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).error,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                  ],
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        fontSize:
                                                                            17.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            false,
                                                                        lineHeight:
                                                                            1.5,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              Builder(
                                builder: (context) {
                                  final question = FFAppState()
                                      .quesReviewList
                                      .where(
                                          (q) => q['user_answer'] == 'skipped')
                                      .toList();

                                  return ListView.separated(
                                    padding: EdgeInsets.fromLTRB(
                                      0,
                                      13.0,
                                      0,
                                      13.0,
                                    ),
                                    primary: false,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: question.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 16.0),
                                    itemBuilder: (context, questionIndex) {
                                      final questionItem =
                                          question[questionIndex];
                                      print('=quesItem==SKIPPED=>>>${questionItem}');
                                      final options =
                                          questionItem['option'] ?? {};
                                      final correctAnswer =
                                          questionItem['correct_answer'] ??
                                              questionItem['answer'];

                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            10.0, 0.0, 10.0, 0.0),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .white,
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 15.0,
                                                color: Color(0x1A000000),
                                                offset: Offset(0.0, 4.0),
                                                spreadRadius: 0.0,
                                              )
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 16.0, 16.0, 16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Question title with HTML support (includes images)
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Q${questionIndex + 1}. ',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily:
                                                                'Roboto',
                                                            fontSize: 15.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            useGoogleFonts:
                                                                false,
                                                            lineHeight: 1.5,
                                                          ),
                                                    ),
                                                    Expanded(
                                                      child:
                                                          _buildQuestionHtmlWidget(
                                                        context: context,
                                                        questionHtml: getJsonField(
                                                                questionItem,
                                                                r'''$.question_title''')
                                                            .toString(),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // Question image - show if image field exists and is not empty
                                                if (getJsonField(questionItem,
                                                            r'''$.image''') !=
                                                        null &&
                                                    getJsonField(questionItem,
                                                            r'''$.image''')
                                                        .toString()
                                                        .isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 16.0,
                                                                0.0, 16.0),
                                                    child: Center(
                                                      child: Container(
                                                        width: double.infinity,
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              64.0,
                                                          maxHeight: 300.0,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12.0),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl:
                                                                '${FFAppConstants.imageBaseURL}${getJsonField(questionItem, r'''$.image''').toString()}',
                                                            width:
                                                                double.infinity,
                                                            fit: BoxFit.contain,
                                                            alignment:
                                                                Alignment(
                                                                    0.0, 0.0),
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                        Color>(
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                ),
                                                              ),
                                                            ),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                SizedBox
                                                                    .shrink(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if ('audio' ==
                                                    getJsonField(
                                                      questionItem,
                                                      r'''$.question_type''',
                                                    ).toString())
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 16.0,
                                                                0.0, 0.0),
                                                    child:
                                                        FlutterFlowAudioPlayer(
                                                      audio: Audio.network(
                                                        getJsonField(
                                                                  questionItem,
                                                                  r'''$.audio''',
                                                                ) !=
                                                                null
                                                            ? '${FFAppConstants.imageBaseURL}${getJsonField(
                                                                questionItem,
                                                                r'''$.audio''',
                                                              ).toString()}'
                                                            : 'https://filesamples.com/samples/audio/mp3/sample3.mp3',
                                                        metas: Metas(
                                                          title: 'Title',
                                                        ),
                                                      ),
                                                      titleTextStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Roboto',
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    false,
                                                              ),
                                                      playbackDurationTextStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelMedium
                                                              .override(
                                                                fontFamily:
                                                                    'Roboto',
                                                                letterSpacing:
                                                                    0.0,
                                                                useGoogleFonts:
                                                                    false,
                                                              ),
                                                      fillColor: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      playbackButtonColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      activeTrackColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      inactiveTrackColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .alternate,
                                                      elevation: 0.0,
                                                      playInBackground:
                                                          PlayInBackground
                                                              .disabledRestoreOnForeground,
                                                    ),
                                                  ),

                                                // Options with indicators
                                                ...List.generate(options.length,
                                                    (optionIndex) {
                                                  final optionKeys =
                                                      options.keys.toList();
                                                  final optionKey =
                                                      optionKeys[optionIndex];
                                                  final option =
                                                      options[optionKey];
                                                  final normalize = (dynamic
                                                          value) =>
                                                      (value ?? '')
                                                          .toString()
                                                          .replaceAll(
                                                              RegExp(r'\s+'),
                                                              ' ')
                                                          .trim()
                                                          .toLowerCase();

                                                  final optionText = option !=
                                                              null &&
                                                          option['text'] != null
                                                      ? (option['text'] is Map
                                                          ? (option['text']
                                                                  ['text'] ??
                                                              option['text']
                                                                  .toString())
                                                          : option['text']
                                                              .toString())
                                                      : '';

                                                  final optionTextNormalized =
                                                      normalize(optionText);
                                                  final correctAnswerNormalized =
                                                      normalize(correctAnswer);
                                                  final optionKeyNormalized =
                                                      normalize(optionKey);

                                                  final isCorrectAnswer =
                                                      correctAnswerNormalized
                                                              .isNotEmpty &&
                                                          (optionKeyNormalized ==
                                                                  correctAnswerNormalized ||
                                                              optionTextNormalized ==
                                                                  correctAnswerNormalized);

                                                  return Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 8.0,
                                                                0.0, 0.0),
                                                    child: Row(
                                                      children: [
                                                        // Icon indicator
                                                        Container(
                                                          width: 24.0,
                                                          height: 24.0,
                                                          child: isCorrectAnswer
                                                              ? Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: Colors
                                                                      .green,
                                                                  size: 24.0,
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .radio_button_unchecked,
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  size: 24.0,
                                                                ),
                                                        ),
                                                        SizedBox(width: 12.0),

                                                        // Option content
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // Image for image-based options
                                                              if (getJsonField(questionItem,
                                                                              r'''$.question_type''')
                                                                          .toString() ==
                                                                      'images' &&
                                                                  option !=
                                                                      null &&
                                                                  option['image'] !=
                                                                      null &&
                                                                  option['image']
                                                                      .toString()
                                                                      .isNotEmpty)
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          8.0),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl:
                                                                          '${FFAppConstants.imageBaseURL}${option['image']}',
                                                                      width:
                                                                          50.0,
                                                                      height:
                                                                          50.0,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                                  ),
                                                                ),

                                                              // Option text
                                                              RichText(
                                                                textScaler: MediaQuery.of(
                                                                        context)
                                                                    .textScaler,
                                                                text: TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text: extractOptionText(
                                                                          option),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            fontSize:
                                                                                17.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            useGoogleFonts:
                                                                                false,
                                                                            lineHeight:
                                                                                1.5,
                                                                          ),
                                                                    ),
                                                                    if (isCorrectAnswer)
                                                                      TextSpan(
                                                                        text:
                                                                            ' (Correct Answer)',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                  ],
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        fontSize:
                                                                            17.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        useGoogleFonts:
                                                                            false,
                                                                        lineHeight:
                                                                            1.5,
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
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
