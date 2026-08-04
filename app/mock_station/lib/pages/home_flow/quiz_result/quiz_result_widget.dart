import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'quiz_result_model.dart';
export 'quiz_result_model.dart';

class QuizResultWidget extends StatefulWidget {
  const QuizResultWidget({
    super.key,
    this.correctAnswer,
    this.wrongAnswer,
    this.totalQuestion,
    this.notAnswer,
    this.quizID,
    this.title,
    this.image,
    this.quizTime,
    this.catID,
    this.correctAnsReward,
    this.penaltyPerQuestion,
  });

  final int? correctAnswer;
  final int? wrongAnswer;
  final int? totalQuestion;
  final int? notAnswer;
  final String? quizID;
  final String? title;
  final String? image;
  final String? quizTime;
  final String? catID;
  final double? correctAnsReward;
  final double? penaltyPerQuestion;

  static String routeName = 'quiz_result';
  static String routePath = '/quizResult';

  @override
  State<QuizResultWidget> createState() => _QuizResultWidgetState();
}

class _QuizResultWidgetState extends State<QuizResultWidget> {
  late QuizResultModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  double get _score {
    return (((widget.correctAnswer ?? 0) * (widget.correctAnsReward ?? 0.0)) -
        ((widget.wrongAnswer ?? 0) * (widget.penaltyPerQuestion ?? 0.0)));
  }

  int get _skippedQuestions {
    return FFAppState()
        .quesList
        .where((q) => (q['user_answer'] == 'skipped'))
        .length;
  }

  double get _accuracy {
    final total = widget.totalQuestion ?? 0;
    if (total <= 0) {
      return 0;
    }
    return ((widget.correctAnswer ?? 0) / total) * 100;
  }

  Future<void> _finishQuiz() async {
    if (_score == 0) {
      FFAppState().correctQues = 0;
      FFAppState().wrongQues = 0;
      FFAppState().notAnswerQues = 0;
      FFAppState().quesList = [];
      FFAppState().notAnswerQuestion = [];
      FFAppState().update(() {});
      FFAppState().clearCompleteCache();
      FFAppState().clearCoinsHistoryCache();

      context.goNamed(HomeScreenWidget.routeName);
      return;
    }

    _model.addPointsRes = await QuizGroup.addPointsApiCall.call(
      userId: getJsonField(
        FFAppState().userDetils,
        r'''$.id''',
      ).toString(),
      points: _score.toDouble(),
      description: '${widget.title} points',
      token: FFAppState().loginToken,
    );

    if (QuizGroup.addPointsApiCall.success(
          (_model.addPointsRes?.jsonBody ?? ''),
        ) ==
        1) {
      FFAppState().correctQues = 0;
      FFAppState().wrongQues = 0;
      FFAppState().notAnswerQues = 0;
      FFAppState().quesList = [];
      FFAppState().notAnswerQuestion = [];
      safeSetState(() {});
      _model.planRes = await QuizGroup.planHistoryAPICall.call(
        userId: getJsonField(
          FFAppState().userDetils,
          r'''$.id''',
        ).toString(),
        token: FFAppState().loginToken,
      );

      FFAppState().clearCompleteCache();
      FFAppState().clearCoinsHistoryCache();

      context.goNamed(HomeScreenWidget.routeName);
    }

    safeSetState(() {});
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required Color backgroundColor,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D0F172A),
                  blurRadius: 8.0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: accentColor, size: 19.0),
          ),
          const SizedBox(height: 12.0),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accentColor,
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(height: 6.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionSummaryRow({
    required IconData icon,
    required Color accentColor,
    required Color backgroundColor,
    required String title,
    required String value,
    String? trailing,
    String? helper,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.18),
                  blurRadius: 12.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: accentColor, size: 28.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 14.0),
                      Container(
                        width: 1.0,
                        height: 22.0,
                        color: const Color(0xFFD1D5DB),
                      ),
                      const SizedBox(width: 14.0),
                      Text(
                        trailing,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (helper != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B55),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                helper,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfettiDot({
    double? top,
    double? left,
    double? right,
    required Color color,
    double size = 5.0,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: 0.75,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.2),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionalSummary({
    required int total,
    required String timeLabel,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 10.0),
            child: Text(
              'Sectional Summary',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 16.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'General Science',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Mathematics',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFF3B55),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'General Intelligence',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Stack(
            children: [
              Container(
                height: 1.0,
                color: const Color(0xFFE5E7EB),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 110.0,
                  height: 3.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B55),
                    borderRadius: BorderRadius.circular(99.0),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildSectionSummaryRow(
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFFF1FFF8),
                  title: 'Your Score',
                  value: _score.toStringAsFixed(1),
                  trailing: total.toString(),
                  helper:
                      'Neg. Marks : -${((widget.wrongAnswer ?? 0) * (widget.penaltyPerQuestion ?? 0.0)).toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12.0),
                _buildSectionSummaryRow(
                  icon: Icons.timer_outlined,
                  accentColor: const Color(0xFFA855F7),
                  backgroundColor: const Color(0xFFF8F2FF),
                  title: 'Time Spent',
                  value: timeLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    final total = widget.totalQuestion ?? 0;
    final correct = widget.correctAnswer ?? 0;
    final wrong = widget.wrongAnswer ?? 0;
    final percent =
        total <= 0 ? 0.0 : (correct / total).clamp(0.0, 1.0).toDouble();
    final accuracyLabel = '${_accuracy.toStringAsFixed(0)}%';
    final timeLabel = widget.quizTime != null && widget.quizTime!.isNotEmpty
        ? '${widget.quizTime}:00'
        : '10:21';

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 12.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _finishQuiz,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF111827),
                      size: 22.0,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Test Result',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48.0),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF1FFF8), Color(0xFFF7FBFF)],
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildConfettiDot(
                              top: 8.0,
                              left: 70.0,
                              color: const Color(0xFFFACC15),
                            ),
                            _buildConfettiDot(
                              top: -4.0,
                              left: 170.0,
                              color: const Color(0xFF0B84FF),
                            ),
                            _buildConfettiDot(
                              top: 54.0,
                              left: 220.0,
                              color: const Color(0xFF10B981),
                            ),
                            _buildConfettiDot(
                              top: 4.0,
                              right: 128.0,
                              color: const Color(0xFF06B6D4),
                            ),
                            _buildConfettiDot(
                              top: 12.0,
                              right: 80.0,
                              color: const Color(0xFFEF4444),
                            ),
                            _buildConfettiDot(
                              top: 28.0,
                              right: 4.0,
                              color: const Color(0xFF8B5CF6),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Great Job! 🎉',
                                        style: TextStyle(
                                          color: Color(0xFF18C66A),
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        'You have completed the test successfully.',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 13.0,
                                          height: 1.35,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CircularPercentIndicator(
                                  percent: percent,
                                  radius: 64.0,
                                  lineWidth: 8.0,
                                  animation: true,
                                  progressColor: const Color(0xFF18C66A),
                                  backgroundColor: Colors.white,
                                  circularStrokeCap: CircularStrokeCap.round,
                                  center: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$correct/$total',
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 26.0,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      const Text(
                                        'Score',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.bar_chart_rounded,
                                  color: Color(0xFF22C55E),
                                  size: 22.0,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'Performance Summary',
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            GridView.count(
                              crossAxisCount: 3,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              mainAxisExtent: 168.0,
                              children: [
                                _buildMetricCard(
                                  title: 'Total Questions',
                                  value: total.toString(),
                                  icon: Icons.article_rounded,
                                  accentColor: const Color(0xFF0B84FF),
                                  backgroundColor: const Color(0xFFF1F6FF),
                                ),
                                _buildMetricCard(
                                  title: 'Total Marks',
                                  value: _score.toStringAsFixed(4),
                                  icon: Icons.emoji_events_rounded,
                                  accentColor: const Color(0xFF7C3AED),
                                  backgroundColor: const Color(0xFFF7F1FF),
                                ),
                                _buildMetricCard(
                                  title: 'Correct Answers',
                                  value: correct.toString(),
                                  icon: Icons.check_circle_rounded,
                                  accentColor: const Color(0xFF16A34A),
                                  backgroundColor: const Color(0xFFF0FBF4),
                                  badge: accuracyLabel,
                                ),
                                _buildMetricCard(
                                  title: 'Incorrect Answers',
                                  value: wrong.toString(),
                                  icon: Icons.cancel_rounded,
                                  accentColor: const Color(0xFFEF4444),
                                  backgroundColor: const Color(0xFFFFF3F3),
                                  badge:
                                      '${(total <= 0 ? 0 : (wrong / total) * 100).toStringAsFixed(0)}%',
                                ),
                                _buildMetricCard(
                                  title: 'Skipped Questions',
                                  value: _skippedQuestions.toString(),
                                  icon: Icons.timer_rounded,
                                  accentColor: const Color(0xFFF59E0B),
                                  backgroundColor: const Color(0xFFFFFAEE),
                                  badge:
                                      '${(total <= 0 ? 0 : (_skippedQuestions / total) * 100).toStringAsFixed(0)}%',
                                ),
                                _buildMetricCard(
                                  title: 'Accuracy',
                                  value: accuracyLabel,
                                  icon: Icons.track_changes_rounded,
                                  accentColor: const Color(0xFF0B84FF),
                                  backgroundColor: const Color(0xFFF1F6FF),
                                  badge: _accuracy >= 60 ? 'Good' : 'Low',
                                ),
                              ],
                            ),
                            const SizedBox(height: 14.0),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F1FF),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44.0,
                                    height: 44.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14.0),
                                    ),
                                    child: const Icon(
                                      Icons.timer_outlined,
                                      color: Color(0xFFA855F7),
                                      size: 28.0,
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total Time Taken',
                                        style: TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        timeLabel,
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18.0),
                            _buildSectionalSummary(
                              total: total,
                              timeLabel: timeLabel,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => QuizResultModel());

    // DEBUG PRINTS
    print('RESULT DEBUG: correctAnswer=' + (widget.correctAnswer?.toString() ?? 'null'));
    print('RESULT DEBUG: wrongAnswer=' + (widget.wrongAnswer?.toString() ?? 'null'));
    print('RESULT DEBUG: correctAnsReward=' + (widget.correctAnsReward?.toString() ?? 'null'));
    print('RESULT DEBUG: penaltyPerQuestion=' + (widget.penaltyPerQuestion?.toString() ?? 'null'));
    print('RESULT DEBUG: Calculated score=' + (((widget.correctAnswer ?? 0) * (widget.correctAnsReward ?? 0.0)) - ((widget.wrongAnswer ?? 0) * (widget.penaltyPerQuestion ?? 0.0))).toString());

    // LOG SKIPPED QUESTIONS
    final skippedCount = FFAppState().quesList.where((q) => (q['user_answer'] == 'skipped')).length;
    print('RESULT DEBUG: Skipped questions count = ' + skippedCount.toString());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.startquizres = await QuizGroup.startquizApiCall.call(
        userId: getJsonField(
          FFAppState().userDetils,
          r'''$.id''',
        ).toString().toString(),
        quizId: widget.quizID,
        questionsJson: FFAppState().quesList,
        totalQuestions: widget.totalQuestion,
        correctAnswers: widget.correctAnswer,
        wrongAnswers: widget.wrongAnswer,
        score: ((((widget.correctAnswer ?? 0) * (widget.correctAnsReward ?? 0.0)) - ((widget.wrongAnswer ?? 0) * (widget.penaltyPerQuestion ?? 0.0))).toInt()),
        token: FFAppState().loginToken,
      );
    });
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
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          body: Builder(
            builder: (context) {
              if (FFAppState().connected == true) {
                return _buildResultContent();
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
      ),
    );
  }
}
