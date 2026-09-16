import 'dart:convert';

import '/backend/api_requests/api_calls.dart';
import '/custom_code/utils/html_stripper.dart';
import '/flutter_flow/flutter_flow_audio_player.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class _QuizResultWidgetState extends State<QuizResultWidget>
    with TickerProviderStateMixin {
  late QuizResultModel _model;
  late TabController _tabController;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _answerKeyFilter = 'all';
  int _selectedAnswerKeyIndex = 0;
  String _answerKeyLanguage = 'en';
  double? _percentile;
  String _strengthFilter = 'Strong';
  int _computedCorrect = 0;
  int _computedWrong = 0;
  int _computedSkipped = 0;
  int _computedReview = 0;

  void _computeCountsFromQuesList() {
    int correct = 0, wrong = 0, skipped = 0, review = 0;
    for (final q in FFAppState().quesList) {
      final markedForReview = q is Map
          ? (q['markedForReview'] == true ||
              q['markedForReview'].toString().toLowerCase() == 'true')
          : false;
      if (markedForReview) {
        review++;
        continue;
      }
      final userAnswer = (q is Map ? (q['user_answer'] ?? '') : '').toString().toLowerCase();
      if (userAnswer.isEmpty || userAnswer == 'skipped') {
        skipped++;
      } else {
        final status = _answerKeyStatus(q);
        if (status == 'correct') {
          correct++;
        } else {
          wrong++;
        }
      }
    }
    _computedCorrect = correct;
    _computedWrong = wrong;
    _computedSkipped = skipped;
    _computedReview = review;
  }

  double get _score {
    return (((_computedCorrect) * (widget.correctAnsReward ?? 0.0)) -
        ((_computedWrong) * (widget.penaltyPerQuestion ?? 0.0)));
  }

  int get _skippedQuestions => _computedSkipped;

  double get _accuracy {
    final total = widget.totalQuestion ?? 0;
    if (total <= 0) {
      return 0;
    }
    return ((_computedCorrect) / total) * 100;
  }

  Future<void> _loadPercentile() async {
    final userId = getJsonField(
      FFAppState().userDetils,
      r'''$.id''',
    ).toString();
    if (userId.isEmpty || (widget.quizID ?? '').isEmpty) return;

    try {
      final response = await QuizGroup.getuserrankApiCall.call(
        userId: userId,
        quizId: widget.quizID,
        token: FFAppState().loginToken,
      );
      if (QuizGroup.getuserrankApiCall.success(response.jsonBody) == 1) {
        final value = double.tryParse(
          (getJsonField(response.jsonBody, r'''$.data.user.percentile''') ?? '')
              .toString(),
        );
        if (mounted && value != null) {
          safeSetState(() => _percentile = value.clamp(0.0, 100.0).toDouble());
        }
      }
    } catch (_) {
      // The local result remains usable when the percentile request is offline.
    }
  }

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

  // Resolves a nested {en, hi} value (or plain String) by app language with
  // fallback to the other language when the selected one is empty.
  String biText(dynamic v) {
    if (v == null) return '';
    if (v is Map) {
      final en = v['en']?.toString() ?? '';
      final hi = v['hi']?.toString() ?? '';
      final lang = FFAppState().quizLang;
      return lang == 'hi'
          ? (hi.trim().isNotEmpty ? hi : en)
          : (en.trim().isNotEmpty ? en : hi);
    }
    return v.toString();
  }

  // Helper function to extract option text
  String extractOptionText(dynamic optionData) {
    if (optionData is Map) {
      final text = getJsonField(optionData, r'$.text');
      if (text is Map) {
        if (text['en'] != null || text['hi'] != null) {
          return biText(text);
        }
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
          fontSize: FFFont.f16,
          letterSpacing: 0.0,
          fontWeight: FontWeight.normal,
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
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.0,
            height: 28.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D0F172A),
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: accentColor, size: 16.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: FFFont.f10,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: FFFont.f16,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(height: 4.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: accentColor,
                  fontSize: FFFont.f10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required Color backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, color: accentColor, size: 24.0),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: FFFont.f10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: FFFont.f20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
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
                        fontSize: FFFont.f18,
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
                          fontSize: FFFont.f18,
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
                    fontSize: FFFont.f11,
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
                  fontSize: FFFont.f10,
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

  List<dynamic> _resultQuestionSource() {
    return FFAppState().quesList.isNotEmpty
        ? FFAppState().quesList.toList()
        : FFAppState().quesReviewList.toList();
  }

  String _chapterName(dynamic item) {
    final questionData = item is Map ? (item['question'] ?? item) : item;
    return _cleanText(
      (item is Map ? item['chapter'] : null) ??
          getJsonField(questionData, r'''$.chapter'''),
    );
  }

  List<Map<String, dynamic>> _chapterAnalysisItems() {
    final groups = <String, Map<String, dynamic>>{};
    final source = _resultQuestionSource();

    for (var index = 0; index < source.length; index++) {
      final item = source[index];
      final chapter = _chapterName(item);
      if (chapter.isEmpty) continue;

      final subject = _subjectName(item);
      // Strengths and weaknesses are chapter-wise. Do not create separate
      // divisions for subjects in a mixed exam.
      final key = chapter.toLowerCase();
      final group = groups.putIfAbsent(
        key,
        () => <String, dynamic>{
          'chapter': chapter,
          'subject': subject,
          'correct': 0,
          'wrong': 0,
          'skipped': 0,
          'review': 0,
          'questions': <Map<String, dynamic>>[],
        },
      );
      final status = _answerKeyStatus(item);
      if (status == 'correct') {
        group['correct'] = (group['correct'] as int) + 1;
      } else if (status == 'incorrect') {
        group['wrong'] = (group['wrong'] as int) + 1;
      } else if (status == 'review') {
        group['review'] = (group['review'] as int) + 1;
      } else {
        group['skipped'] = (group['skipped'] as int) + 1;
      }
      (group['questions'] as List<Map<String, dynamic>>).add({
        'number': index + 1,
        'status': status,
      });
    }

    return groups.values.map((group) {
      final questions = group['questions'] as List<Map<String, dynamic>>;
      final total = questions.length;
      final correct = group['correct'] as int;
      final percent = total == 0 ? 0.0 : (correct / total) * 100.0;
      return <String, dynamic>{
        ...group,
        'total': total,
        'percent': percent,
        'category': percent >= 60
            ? 'Strong'
            : percent >= 30
                ? 'Average'
                : 'Weak',
      };
    }).toList()
      ..sort((a, b) => (b['percent'] as double).compareTo(a['percent'] as double));
  }

  Color _strengthColor(String category) {
    switch (category) {
      case 'Strong':
        return const Color(0xFF16A34A);
      case 'Average':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }

  Widget _buildStrengthWeaknesses() {
    final analysis = _chapterAnalysisItems();
    if (analysis.isEmpty) return const SizedBox.shrink();

    // Collect all unique subjects
    final subjects = analysis
        .map((item) => (item['subject'] ?? '').toString().trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    final showSubject = _isSubjectWiseTest(_resultQuestionSource()) && subjects.isNotEmpty;
    final subjectLabel = subjects.join(', ');

    final filtered = analysis
        .where((item) => item['category'] == _strengthFilter)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STRENGTHS AND WEAKNESSES',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: FFFont.f10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          if (showSubject) ...[
            const SizedBox(height: 4.0),
            Text(
              'Subjects: $subjectLabel',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: FFFont.f11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: ['Strong', 'Average', 'Weak'].map((label) {
                final selected = _strengthFilter == label;
                final color = _strengthColor(label);
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.0),
                    onTap: () => safeSetState(() => _strengthFilter = label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7.0),
                      decoration: BoxDecoration(
                        color: selected ? color : Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF64748B),
                          fontSize: FFFont.f11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12.0),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'No ${_strengthFilter.toLowerCase()} chapters yet.',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: FFFont.f12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...filtered.map((item) {
              final category = item['category'] as String;
              final color = _strengthColor(category);
              final percent = item['percent'] as double;
              final correct = item['correct'] as int;
              final total = item['total'] as int;
              final chapter = item['chapter'] as String;
              final questions = item['questions'] as List<Map<String, dynamic>>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chapter,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: FFFont.f12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${percent.round()}% ($correct/$total)',
                          style: TextStyle(
                            color: color,
                            fontSize: FFFont.f11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: LinearProgressIndicator(
                        minHeight: 5.0,
                        value: (percent / 100.0).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 7.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0, right: 8.0),
                          child: Text(
                            'Q No.',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: FFFont.f10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 7.0,
                            runSpacing: 5.0,
                            children: questions.map((question) {
                              final status = question['status'] as String;
                              final isCorrect = status == 'correct';
                              final isWrong = status == 'incorrect';
                              final circleColor = isCorrect
                                  ? const Color(0xFF16A34A)
                                  : isWrong
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFD1D5DB);
                              return GestureDetector(
                                onTap: () {
                                  final qIndex =
                                      (question['number'] as int) - 1;
                                  final entries = _answerKeyEntries();
                                  final matchIdx = entries.indexWhere(
                                      (e) => e['index'] == qIndex);
                                  if (matchIdx >= 0) {
                                    safeSetState(() {
                                      _answerKeyFilter = 'all';
                                      _selectedAnswerKeyIndex = matchIdx;
                                    });
                                    _tabController.animateTo(1);
                                  }
                                },
                                child: Container(
                                  width: 26.0,
                                  height: 26.0,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: circleColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${question['number']}',
                                    style: TextStyle(
                                      color: isCorrect || isWrong
                                          ? Colors.white
                                          : const Color(0xFF374151),
                                      fontSize: FFFont.f10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSectionalSummary() {
    final source = FFAppState().quesList.isNotEmpty
        ? FFAppState().quesList.toList()
        : FFAppState().quesReviewList.toList();
    if (!_isSubjectWiseTest(source)) return const SizedBox.shrink();

    final sections = _sectionSummaryItems();
    if (sections.isEmpty) return const SizedBox.shrink();

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
                fontSize: FFFont.f16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Subject',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: FFFont.f11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Correct',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: FFFont.f11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Wrong',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: FFFont.f11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Marks',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontSize: FFFont.f11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: FFFont.f11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: sections.map((section) {
                final correct = section['correct'] ?? 0;
                final wrong = section['wrong'] ?? 0;
                final total = section['total'] ?? 0;
                final marks = section['marks'] ?? 0.0;
                final time = section['time'] ?? '00:00';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          section['label'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: FFFont.f14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '$correct/$total',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: FFFont.f14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '$wrong',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: FFFont.f14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          marks.toStringAsFixed(1),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF7C3AED),
                            fontSize: FFFont.f14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          time,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFD97706),
                            fontSize: FFFont.f14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  int _parseTotalQuizSeconds() {
    final quizTimeRaw = widget.quizTime ?? '';
    if (quizTimeRaw.contains(':')) {
      final parts = quizTimeRaw.split(':');
      if (parts.length == 2) {
        final m = int.tryParse(parts[0]) ?? 0;
        final s = int.tryParse(parts[1]) ?? 0;
        return m * 60 + s;
      }
    } else if (quizTimeRaw.isNotEmpty) {
      final minutes = int.tryParse(quizTimeRaw) ?? 0;
      if (minutes > 0) return minutes * 60;
    }
    return 600;
  }

  String _formatSeconds(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _sectionSummaryItems() {
    final source = FFAppState().quesList.isNotEmpty
        ? FFAppState().quesList.toList()
        : FFAppState().quesReviewList.toList();
    if (source.isEmpty) return [];

    final sectionLabels = _sectionLabelsFromData(source);
    if (sectionLabels.isEmpty) return [];

    final grouped = <String, List<dynamic>>{};
    for (final item in source) {
      final subject = _subjectName(item).trim();
      final key = subject.isEmpty ? 'General' : subject;
      grouped.putIfAbsent(key, () => <dynamic>[]).add(item);
    }

    final totalQuizSeconds = _parseTotalQuizSeconds();
    final totalQuestionsCount = source.length;

    final sections = <Map<String, dynamic>>[];
    for (final label in sectionLabels) {
      final items = grouped[label] ?? <dynamic>[];
      final secItem = _buildSectionSummaryItem(label, items);

      final secCount = items.length;
      final secSeconds = totalQuestionsCount > 0
          ? ((secCount / totalQuestionsCount) * totalQuizSeconds).round()
          : (totalQuizSeconds ~/ sectionLabels.length);
      secItem['time'] = _formatSeconds(secSeconds);

      sections.add(secItem);
    }

    return sections;
  }

  bool _isSubjectWiseTest(List<dynamic> source) {
    final subjects = source
        .map((item) => _subjectName(item).trim())
        .where((subject) => subject.isNotEmpty)
        .toSet();
    // A subject-wise test has multiple subjects and every question belongs to one.
    return source.isNotEmpty &&
        subjects.length > 1 &&
        source.every((item) => _subjectName(item).trim().isNotEmpty);
  }

  List<String> _sectionLabelsFromData(List<dynamic> source) {
    final labels = <String>[];
    for (final item in source) {
      final subject = _subjectName(item).trim();
      final label = subject.isEmpty ? 'General' : subject;
      if (!labels.contains(label)) {
        labels.add(label);
      }
    }
    return labels;
  }

  Map<String, dynamic> _buildSectionSummaryItem(String label, List<dynamic> items) {
    var correct = 0;
    var wrong = 0;
    var skipped = 0;
    var review = 0;

    for (final item in items) {
      final questionData = item is Map && item['question'] is Map ? item['question'] as Map : <String, dynamic>{};
      final markedForReview = item is Map
          ? (item['markedForReview'] == true ||
              item['markedForReview'].toString().toLowerCase() == 'true')
          : false;
      if (markedForReview) {
        review++;
        continue;
      }
      final options = _optionMap(item);
      final userAnswer = _cleanText((item is Map ? item['user_answer'] : null) ?? questionData['user_answer']).toLowerCase();
      final correctAnswer = _cleanText(
        biText(
          (item is Map ? item['correct_answer'] : null) ??
              (item is Map ? item['answer'] : null) ??
              questionData['correct_answer'] ??
              questionData['answer'],
        ),
      );
      final userKey = _normalizedAnswerKey(userAnswer, options) ?? userAnswer;
      final correctKey = _normalizedAnswerKey(correctAnswer, options) ?? correctAnswer.toLowerCase();

      if (userKey == 'skipped') {
        skipped++;
      } else if (userKey.isNotEmpty && userKey == correctKey) {
        correct++;
      } else {
        wrong++;
      }
    }

    final total = items.length;
    final marks = (correct * (widget.correctAnsReward ?? 0.0)) -
        (wrong * (widget.penaltyPerQuestion ?? 0.0));

    return {
      'label': label,
      'correct': correct,
      'wrong': wrong,
      'skipped': skipped,
      'review': review,
      'total': total,
      'marks': marks,
    };
  }

  Widget _tabLabel(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                color: selected ? const Color(0xFF1D4ED8) : const Color(0xFF6B7280),
                fontSize: FFFont.f14,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              height: 2.5,
              width: 88.0,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF1D4ED8) : Colors.transparent,
                borderRadius: BorderRadius.circular(99.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTab({
    required int total,
    required int correct,
    required int wrong,
    required int skipped,
    required double percent,
  }) {
    final accuracyLabel = '${_accuracy.toStringAsFixed(0)}%';
    final quizTimeRaw = widget.quizTime ?? '';
    String timeLabel;
    if (quizTimeRaw.contains(':')) {
      timeLabel = quizTimeRaw;
    } else if (quizTimeRaw.isNotEmpty) {
      final minutes = int.tryParse(quizTimeRaw) ?? 0;
      timeLabel = '$minutes:00';
    } else {
      timeLabel = '10:21';
    }

    return SingleChildScrollView(
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
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
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
                  _buildConfettiDot(top: 8.0, left: 70.0, color: const Color(0xFFFACC15)),
                  _buildConfettiDot(top: -4.0, left: 170.0, color: const Color(0xFF0B84FF)),
                  _buildConfettiDot(top: 54.0, left: 220.0, color: const Color(0xFF10B981)),
                  _buildConfettiDot(top: 4.0, right: 128.0, color: const Color(0xFF06B6D4)),
                  _buildConfettiDot(top: 12.0, right: 80.0, color: const Color(0xFFEF4444)),
                  _buildConfettiDot(top: 28.0, right: 4.0, color: const Color(0xFF8B5CF6)),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Great Job! 🎉', style: TextStyle(color: Color(0xFF18C66A), fontSize: FFFont.f20, fontWeight: FontWeight.w900)),
                            SizedBox(height: 8.0),
                            Text('You have completed the test successfully.', style: TextStyle(color: Color(0xFF64748B), fontSize: FFFont.f14, height: 1.35, fontWeight: FontWeight.w500)),
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
                            Text('$correct/$total', style: const TextStyle(color: Color(0xFF111827), fontSize: FFFont.f24, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4.0),
                            const Text('Score', style: TextStyle(color: Color(0xFF64748B), fontSize: FFFont.f11, fontWeight: FontWeight.w600)),
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
                      Icon(Icons.bar_chart_rounded, color: Color(0xFF22C55E), size: 22.0),
                      SizedBox(width: 8.0),
                      Text('Performance Summary', style: TextStyle(color: Color(0xFF111827), fontSize: FFFont.f16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    mainAxisExtent: 125.0,
                    children: [
                      _buildMetricCard(title: 'Total Questions', value: total.toString(), icon: Icons.article_rounded, accentColor: const Color(0xFF0B84FF), backgroundColor: const Color(0xFFF1F6FF)),
                      _buildMetricCard(title: 'Total Marks', value: _score.toStringAsFixed(_score.truncateToDouble() == _score ? 0 : 2), icon: Icons.emoji_events_rounded, accentColor: const Color(0xFF7C3AED), backgroundColor: const Color(0xFFF7F1FF)),
                      _buildMetricCard(title: 'Correct Answers', value: correct.toString(), icon: Icons.check_circle_rounded, accentColor: const Color(0xFF16A34A), backgroundColor: const Color(0xFFF0FBF4), badge: accuracyLabel),
                      _buildMetricCard(title: 'Incorrect Answers', value: wrong.toString(), icon: Icons.cancel_rounded, accentColor: const Color(0xFFEF4444), backgroundColor: const Color(0xFFFFF3F3), badge: '${(total <= 0 ? 0 : (wrong / total) * 100).toStringAsFixed(0)}%'),
                      _buildMetricCard(title: 'Skipped Questions', value: skipped.toString(), icon: Icons.timer_rounded, accentColor: const Color(0xFFF59E0B), backgroundColor: const Color(0xFFFFFAEE), badge: '${(total <= 0 ? 0 : (skipped / total) * 100).toStringAsFixed(0)}%'),
                      _buildMetricCard(title: 'Marked for Review', value: _computedReview.toString(), icon: Icons.star_rounded, accentColor: const Color(0xFFEC4899), backgroundColor: const Color(0xFFFDF2F8), badge: '${(total <= 0 ? 0 : (_computedReview / total) * 100).toStringAsFixed(0)}%'),
                      _buildMetricCard(title: 'Accuracy', value: accuracyLabel, icon: Icons.track_changes_rounded, accentColor: const Color(0xFF0B84FF), backgroundColor: const Color(0xFFF1F6FF), badge: _accuracy >= 60 ? 'Good' : 'Low'),
                    ],
                  ),
                  const SizedBox(height: 14.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInsightCard(
                          title: 'Total Time Taken',
                          value: timeLabel,
                          icon: Icons.timer_outlined,
                          accentColor: const Color(0xFFA855F7),
                          backgroundColor: const Color(0xFFF7F1FF),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: _buildInsightCard(
                          title: 'Percentile',
                          value: _percentile == null
                              ? '--'
                              : '${_percentile!.toStringAsFixed(1)}%',
                          icon: Icons.insights_rounded,
                          accentColor: const Color(0xFFF59E0B),
                          backgroundColor: const Color(0xFFFFF7E8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18.0),
                  _buildSectionalSummary(),
                  const SizedBox(height: 18.0),
                  _buildStrengthWeaknesses(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasSubjectData {
    final questions = FFAppState().quesList;
    if (questions.isEmpty) return false;
    return questions.any((q) {
      return _subjectName(q).isNotEmpty;
    });
  }

  Map<String, Map<String, dynamic>> _groupBySubject() {
    final Map<String, Map<String, dynamic>> groups = {};
    final source = FFAppState().quesList.isNotEmpty
        ? FFAppState().quesList.toList()
        : FFAppState().quesReviewList.toList();
    for (final q in source) {
      final sub = _subjectName(q).isEmpty ? 'General' : _subjectName(q);
      groups.putIfAbsent(sub, () => {'correct': 0, 'wrong': 0, 'skipped': 0, 'total': 0});
      groups[sub]!['total'] = (groups[sub]!['total'] ?? 0) + 1;
      final questionData = q is Map && q['question'] is Map ? q['question'] as Map : <String, dynamic>{};
      final options = _optionMap(q);
      final userAnswer = _cleanText((q is Map ? q['user_answer'] : null) ?? questionData['user_answer']).toLowerCase();
      final correctAnswer = _cleanText(
        biText(
          (q is Map ? q['correct_answer'] : null) ??
              (q is Map ? q['answer'] : null) ??
              questionData['correct_answer'] ??
              questionData['answer'],
        ),
      );
      final userKey = _normalizedAnswerKey(userAnswer, options) ?? userAnswer;
      final correctKey = _normalizedAnswerKey(correctAnswer, options) ?? correctAnswer.toLowerCase();

      if (userKey == 'skipped') {
        groups[sub]!['skipped'] = (groups[sub]!['skipped'] ?? 0) + 1;
      } else if (userKey.isNotEmpty && userKey == correctKey) {
        groups[sub]!['correct'] = (groups[sub]!['correct'] ?? 0) + 1;
      } else {
        groups[sub]!['wrong'] = (groups[sub]!['wrong'] ?? 0) + 1;
      }
    }
    return groups;
  }

  Widget _buildAnswerKeyTab() {
    final entries = _answerKeyEntries();
    if (_selectedAnswerKeyIndex >= entries.length) {
      _selectedAnswerKeyIndex = entries.isEmpty ? 0 : entries.length - 1;
    }

    return Column(
      children: [
        _buildAnswerKeyToolbar(entries),
        Expanded(
          child: entries.isEmpty
              ? const Center(
                  child: Text(
                    'No questions match this filter.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: FFFont.f14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 18.0),
                  child: _buildAnswerKeyQuestionCard(
                    question: entries[_selectedAnswerKeyIndex]['question'],
                    questionNumber: entries[_selectedAnswerKeyIndex]['index'] + 1,
                  ),
                ),
        ),
      ],
    );
  }

  List<dynamic> _answerKeySource() {
    final questions = FFAppState().quesList.toList();
    if (questions.isNotEmpty) return questions;
    return List.generate(
      widget.totalQuestion ?? 0,
      (index) => <String, dynamic>{'user_answer': 'skipped'},
    );
  }

  List<Map<String, dynamic>> _answerKeyEntries() {
    final source = _answerKeySource();
    final entries = <Map<String, dynamic>>[];
    for (var index = 0; index < source.length; index++) {
      final question = source[index];
      if (_answerKeyFilter == 'all' ||
          _answerKeyStatus(question) == _answerKeyFilter) {
        entries.add({'question': question, 'index': index});
      }
    }
    return entries;
  }

  dynamic _answerKeyValue(dynamic item, String key) {
    if (item is Map) {
      final directValue = item[key];
      if (directValue != null) return directValue;
      final nested = item['question'];
      if (nested is Map && nested[key] != null) return nested[key];
    }
    return null;
  }

  String _answerKeyStatus(dynamic question) {
    final markedForReview = question is Map
        ? (question['markedForReview'] == true ||
            question['markedForReview'].toString().toLowerCase() == 'true')
        : false;
    if (markedForReview) return 'review';

    final userAnswer = _cleanText(
      _answerKeyValue(question, 'user_answer'),
    ).toLowerCase();
    if (userAnswer.isEmpty || userAnswer == 'skipped') return 'skip';

    final options = _optionMap(question);
    final correctAnswer = _cleanText(
      biText(
        _answerKeyValue(question, 'correct_answer') ??
            _answerKeyValue(question, 'answer'),
      ),
    );
    final userKey = _normalizedAnswerKey(userAnswer, options) ?? userAnswer;
    final correctKey = _normalizedAnswerKey(correctAnswer, options) ??
        correctAnswer.toLowerCase();
    return userKey == correctKey ? 'correct' : 'incorrect';
  }

  Future<void> _showAnswerKeyFilters() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.0)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Filters',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: FFFont.f18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const Divider(height: 1.0),
                ...[
                  ('correct', 'Correct', const Color(0xFF16A34A)),
                  ('incorrect', 'Incorrect', const Color(0xFFDC2626)),
                  ('skip', 'Skip', const Color(0xFF9CA3AF)),
                  ('review', 'Marked for Review', const Color(0xFFF59E0B)),
                ].map((filter) {
                  final isSelected = _answerKeyFilter == filter.$1;
                  return InkWell(
                    onTap: () => Navigator.pop(
                      sheetContext,
                      isSelected ? 'all' : filter.$1,
                    ),
                    child: Container(
                      height: 58.0,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: const Color(0xFF2563EB),
                            size: 26.0,
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              filter.$2,
                              style: const TextStyle(
                                color: Color(0xFF374151),
                                fontSize: FFFont.f14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            width: 14.0,
                            height: 14.0,
                            decoration: BoxDecoration(
                              color: filter.$3,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      safeSetState(() {
        _answerKeyFilter = selected;
        _selectedAnswerKeyIndex = 0;
      });
    }
  }

  void _toggleAnswerKeyLanguage() {
    _answerKeyLanguage = _answerKeyLanguage == 'hi' ? 'en' : 'hi';
    FFAppState().quizLang = _answerKeyLanguage;
    safeSetState(() {});
  }

  Widget _buildAnswerKeyToolbar(List<Map<String, dynamic>> entries) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: entries.asMap().entries.map((entry) {
                  final visibleIndex = entry.key;
                  final item = entry.value;
                  final status = _answerKeyStatus(item['question']);
                  final color = status == 'correct'
                      ? const Color(0xFF16C784)
                      : status == 'incorrect'
                          ? const Color(0xFFFF5A64)
                          : const Color(0xFFD1D5DB);
                  final selected = visibleIndex == _selectedAnswerKeyIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () => safeSetState(
                        () => _selectedAnswerKeyIndex = visibleIndex,
                      ),
                      child: Container(
                        width: 32.0,
                        height: 32.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(
                                  color: const Color(0xFF1D66E5),
                                  width: 2.0,
                                )
                              : null,
                        ),
                        child: Text(
                          '${item['index'] + 1}',
                          style: TextStyle(
                            color: status == 'skip'
                                ? const Color(0xFF374151)
                                : Colors.white,
                            fontSize: FFFont.f12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 6.0),
          Container(width: 1.0, height: 28.0, color: const Color(0xFFE5E7EB)),
          IconButton(
            tooltip: 'Filters',
            onPressed: _showAnswerKeyFilters,
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Color(0xFF111827),
              size: 21.0,
            ),
          ),
          Container(
            width: 34.0,
            height: 34.0,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: _toggleAnswerKeyLanguage,
              icon: SvgPicture.asset(
                'assets/images/google_translate_icon.svg',
                width: 20.0,
                height: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerKeyStats(dynamic question) {
    final source = _answerKeySource();
    final correctCount = source.where((item) => _answerKeyStatus(item) == 'correct').length;
    final total = source.length;
    final correctPercentage = total == 0 ? 0 : ((correctCount / total) * 100).round();
    final yourTime = _answerKeyTime(question);
    final avgTime = _averageAnswerKeyTime(source.length);

    Widget metric(String label, String value, {Widget? icon, int flex = 1}) {
      return Expanded(
        flex: flex,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 5.0),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: FFFont.f10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: FFFont.f12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 14.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFFEC4899)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11.0),
        ),
        child: Row(
          children: [
            metric(
              'Your time',
              yourTime,
              icon: const Icon(Icons.access_time_rounded, color: Color(0xFF2563EB), size: 20.0),
              flex: 10,
            ),
            Container(width: 1.0, height: 30.0, color: const Color(0xFFE5E7EB)),
            metric(
              'Avg. time',
              avgTime,
              icon: Container(
                width: 24.0,
                height: 24.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF9333EA), size: 14.0),
              ),
              flex: 10,
            ),
            Container(width: 1.0, height: 30.0, color: const Color(0xFFE5E7EB)),
            metric(
              'Answered correctly',
              '$correctPercentage%',
              icon: Container(
                width: 24.0,
                height: 24.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 14.0),
              ),
              flex: 14,
            ),
          ],
        ),
      ),
    );
  }

  int _parseAnswerKeySeconds(dynamic value) {
    if (value is num) return value.round();
    final text = value?.toString().trim() ?? '';
    if (text.contains(':')) {
      final parts = text.split(':');
      if (parts.length == 2) {
        return (int.tryParse(parts[0]) ?? 0) * 60 +
            (int.tryParse(parts[1]) ?? 0);
      }
    }
    return int.tryParse(text) ?? 0;
  }

  String _answerKeyTime(dynamic question) {
    final raw = _answerKeyValue(question, 'time_taken') ??
        _answerKeyValue(question, 'timeTaken') ??
        _answerKeyValue(question, 'duration');
    final seconds = _parseAnswerKeySeconds(raw);
    if (seconds > 0) return _formatSeconds(seconds);
    final totalSeconds = _parseAnswerKeySeconds(widget.quizTime);
    return totalSeconds > 0 ? _formatSeconds(totalSeconds) : '00:00';
  }

  String _averageAnswerKeyTime(int questionCount) {
    if (questionCount <= 0) return '00:00';
    final totalSeconds = _parseAnswerKeySeconds(widget.quizTime);
    if (totalSeconds <= 0) return '00:00';
    return _formatSeconds((totalSeconds / questionCount).round());
  }

  Widget _buildAnswerKeyQuestionCard({
    required dynamic question,
    required int questionNumber,
  }) {
    final options = _optionMap(question);
    final userAnswer = _answerKeyValue(question, 'user_answer');
    final correctAnswer = biText(
      _answerKeyValue(question, 'correct_answer') ??
          _answerKeyValue(question, 'answer'),
    );
    final questionTitle = biText(
      _answerKeyValue(question, 'question_title') ??
          _answerKeyValue(question, 'question'),
    );
    final description = biText(
      _answerKeyValue(question, 'description') ??
          _answerKeyValue(question, 'explanation'),
    );
    final chapter = biText(_answerKeyValue(question, 'chapter')).trim();
    final questionImage = _answerKeyValue(question, 'image');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14.0,
            color: Color(0x14000000),
            offset: Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: FFFont.f14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _buildQuestionHtmlWidget(
                  context: context,
                  questionHtml: questionTitle,
                ),
              ),
            ],
          ),
          if (chapter.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Chapter: $chapter',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: FFFont.f12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (questionImage != null && questionImage.toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 14.0, 0.0, 8.0),
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: '${FFAppConstants.imageBaseURL}$questionImage',
                  fit: BoxFit.contain,
                  height: 220.0,
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
              ),
            ),
          const SizedBox(height: 8.0),
          ...options.keys.toList().asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final optionKey = entry.value;
            final option = options[optionKey];
            final optionText = _optionText(options, optionKey);
            final optionImage = option is Map ? option['image'] : null;
            final normalizedOption = _cleanText(optionText).toLowerCase();
            final normalizedCorrect = _cleanText(correctAnswer).toLowerCase();
            final normalizedUser = _cleanText(userAnswer).toLowerCase();
            final isCorrect = normalizedCorrect.isNotEmpty &&
                (_normalizedAnswerKey(normalizedCorrect, options) == optionKey.toLowerCase() ||
                    normalizedOption == normalizedCorrect);
            final isUserSelected = normalizedUser.isNotEmpty &&
                normalizedUser != 'skipped' &&
                (_normalizedAnswerKey(normalizedUser, options) == optionKey.toLowerCase() ||
                    normalizedOption == normalizedUser);
            final isUserCorrect = isCorrect && isUserSelected;

            final background = isUserCorrect || isCorrect
                ? const Color(0xFFF0FBF4)
                : isUserSelected
                    ? const Color(0xFFFFF1F2)
                    : Colors.white;
            final border = isUserCorrect || isCorrect
                ? const Color(0xFF86EFAC)
                : isUserSelected
                    ? const Color(0xFFFECACA)
                    : const Color(0xFFE5E7EB);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 9.0),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(9.0),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 4.0),
                    Icon(
                      isUserCorrect || isCorrect
                          ? Icons.check_circle
                          : isUserSelected
                              ? Icons.cancel
                              : Icons.cancel,
                      color: isUserCorrect || isCorrect
                          ? const Color(0xFF16A34A)
                          : isUserSelected
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF9CA3AF),
                      size: 21.0,
                    ),
                    const SizedBox(width: 10.0),
                    Container(
                      width: 26.0,
                      height: 26.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        String.fromCharCode(65 + optionIndex),
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: FFFont.f12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (optionImage != null && optionImage.toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: CachedNetworkImage(
                                imageUrl: '${FFAppConstants.imageBaseURL}$optionImage',
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) => const SizedBox.shrink(),
                              ),
                            ),
                          RichText(
                            textScaler: MediaQuery.of(context).textScaler,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: optionText,
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: FFFont.f14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                  ),
                                ),
                                if (isUserCorrect)
                                  const TextSpan(
                                    text: ' (Correct Answer & Your Answer)',
                                    style: TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontSize: FFFont.f14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                else if (isCorrect)
                                  const TextSpan(
                                    text: ' (Correct Answer)',
                                    style: TextStyle(
                                      color: Color(0xFF16A34A),
                                      fontSize: FFFont.f14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                else if (isUserSelected)
                                  const TextSpan(
                                    text: ' (Your Answer)',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: FFFont.f14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          _buildAnswerKeyStats(question),
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            child: FFButtonWidget(
              onPressed: () {
                context.pushNamed(
                  ExplanationPageWidget.routeName,
                  queryParameters: {
                    'explanation': serializeParam(
                      description.isNotEmpty
                          ? description
                          : 'No explanation available for this question.',
                      ParamType.String,
                    ),
                  }.withoutNulls,
                );
              },
              text: 'View Solution',
              icon: const Icon(
                Icons.visibility_rounded,
                color: Color(0xFF1D66E5),
                size: 18.0,
              ),
              options: FFButtonOptions(
                width: double.infinity,
                height: 44.0,
                color: const Color(0xFFEAF3FF),
                textStyle: const TextStyle(
                  color: Color(0xFF1D66E5),
                  fontSize: FFFont.f14,
                  fontWeight: FontWeight.w700,
                ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(9.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnsweredList(List<dynamic> questions) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(10.0, 13.0, 10.0, 13.0),
      primary: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
      itemBuilder: (context, quesIndex) {
        final quesItem = questions[quesIndex];
        final options = quesItem['option'] ?? {};
        final userAnswer = quesItem['user_answer'];
        final correctAnswer =
            biText(quesItem['correct_answer'] ?? quesItem['answer']);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 15.0,
                color: Color(0x1A000000),
                offset: Offset(0.0, 4.0),
                spreadRadius: 0.0,
              )
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        'Q${quesIndex + 1}',
                        style: const TextStyle(
                          color: Color(0xFF7C3AED),
                          fontSize: FFFont.f14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: _buildQuestionHtmlWidget(
                        context: context,
                        questionHtml:
                            biText(getJsonField(quesItem, r'''$.question_title''')),
                      ),
                    ),
                  ],
                ),
                if (getJsonField(quesItem, r'''$.image''') != null &&
                    getJsonField(quesItem, r'''$.image''')
                        .toString()
                        .isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width - 64.0,
                          maxHeight: 300.0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: CachedNetworkImage(
                            imageUrl:
                                '${FFAppConstants.imageBaseURL}${getJsonField(quesItem, r'''$.image''').toString()}',
                            width: double.infinity,
                            fit: BoxFit.contain,
                            alignment: const Alignment(0.0, 0.0),
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12.0),
                ...List.generate(options.length, (optionIndex) {
                  final optionKeys = options.keys.toList();
                  final optionKey = optionKeys[optionIndex];
                  final option = options[optionKey];
                  final normalize = (dynamic value) => (value ?? '')
                      .toString()
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim()
                      .toLowerCase();

                  final optionText = option != null && option['text'] != null
                      ? extractOptionText(option)
                      : '';

                  final optionTextNormalized = normalize(optionText);
                  final userAnswerNormalized = normalize(userAnswer);
                  final correctAnswerNormalized = normalize(correctAnswer);
                  final optionKeyNormalized = normalize(optionKey);

                  final isCorrectAnswer =
                      correctAnswerNormalized.isNotEmpty &&
                          (optionKeyNormalized ==
                                  correctAnswerNormalized ||
                              optionTextNormalized ==
                                  correctAnswerNormalized);

                  final isUserSelected =
                      userAnswerNormalized.isNotEmpty &&
                          (optionKeyNormalized ==
                                  userAnswerNormalized ||
                              optionTextNormalized ==
                                  userAnswerNormalized);

                  final isUserCorrect =
                      isUserSelected && isCorrectAnswer;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: isUserCorrect || isCorrectAnswer
                            ? const Color(0xFFF0FBF4)
                            : isUserSelected
                                ? const Color(0xFFFFF3F3)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: isUserCorrect || isCorrectAnswer
                              ? const Color(0xFF86EFAC)
                              : isUserSelected
                                  ? const Color(0xFFFECACA)
                                  : const Color(0xFFE5E7EB),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 4.0),
                          Container(
                            width: 24.0,
                            height: 24.0,
                            alignment: Alignment.center,
                            child: isUserCorrect || isCorrectAnswer
                                ? const Icon(Icons.check_circle,
                                    color: Color(0xFF16A34A), size: 22.0)
                                : isUserSelected
                                    ? const Icon(Icons.cancel,
                                        color: Color(0xFFEF4444), size: 22.0)
                                    : const Icon(Icons.cancel,
                                        color: Color(0xFF9CA3AF), size: 22.0),
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                            width: 26.0,
                            height: 26.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              String.fromCharCode(65 + optionIndex),
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: FFFont.f12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (getJsonField(quesItem,
                                                r'''$.question_type''')
                                            .toString() ==
                                        'images' &&
                                    option != null &&
                                    option['image'] != null &&
                                    option['image'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 0.0, 0.0, 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            '${FFAppConstants.imageBaseURL}${option['image']}',
                                        width: 50.0,
                                        height: 50.0,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                RichText(
                                  textScaler:
                                      MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: extractOptionText(option),
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: FFFont.f14,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                      ),
                                      if (isUserCorrect)
                                        const TextSpan(
                                          text:
                                              ' (Correct Answer & Your Answer)',
                                          style: TextStyle(
                                            color: Color(0xFF16A34A),
                                            fontSize: FFFont.f14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      else if (isCorrectAnswer)
                                        const TextSpan(
                                          text: ' (Correct Answer)',
                                          style: TextStyle(
                                            color: Color(0xFF16A34A),
                                            fontSize: FFFont.f14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      else if (isUserSelected)
                                        const TextSpan(
                                          text: ' (Your Answer)',
                                          style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: FFFont.f14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 14.0),
                SizedBox(
                  width: double.infinity,
                  child: FFButtonWidget(
                    onPressed: () async {
                      final desc = biText(
                        (quesItem is Map ? quesItem['description'] : null) ??
                            (quesItem is Map && quesItem['question'] is Map ? quesItem['question']['description'] : null),
                      );
                      context.pushNamed(
                        ExplanationPageWidget.routeName,
                        queryParameters: {
                          'explanation': serializeParam(
                            desc.isNotEmpty ? desc : 'No explanation available for this question.',
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      );
                    },
                    text: 'View Solution',
                    icon: const Icon(
                      Icons.visibility_rounded,
                      color: Color(0xFF1D66E5),
                      size: 18.0,
                    ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 44.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                      color: const Color(0xFFF1F6FF),
                      textStyle: const TextStyle(
                        color: Color(0xFF1D66E5),
                        fontSize: FFFont.f14,
                        fontWeight: FontWeight.w700,
                      ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkippedList(List<dynamic> questions) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(10.0, 13.0, 10.0, 13.0),
      primary: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
      itemBuilder: (context, questionIndex) {
        final questionItem = questions[questionIndex];
        final options = questionItem['option'] ?? {};
        final correctAnswer =
            biText(questionItem['correct_answer'] ?? questionItem['answer']);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 15.0,
                color: Color(0x1A000000),
                offset: Offset(0.0, 4.0),
                spreadRadius: 0.0,
              )
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        'Q${questionIndex + 1}',
                        style: const TextStyle(
                          color: Color(0xFF7C3AED),
                          fontSize: FFFont.f14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: _buildQuestionHtmlWidget(
                        context: context,
                        questionHtml:
                            biText(getJsonField(questionItem, r'''$.question_title''')),
                      ),
                    ),
                  ],
                ),
                if (getJsonField(questionItem, r'''$.image''') != null &&
                    getJsonField(questionItem, r'''$.image''')
                        .toString()
                        .isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width - 64.0,
                          maxHeight: 300.0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: CachedNetworkImage(
                            imageUrl:
                                '${FFAppConstants.imageBaseURL}${getJsonField(questionItem, r'''$.image''').toString()}',
                            width: double.infinity,
                            fit: BoxFit.contain,
                            alignment: const Alignment(0.0, 0.0),
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const SizedBox.shrink(),
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
                    padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
                    child: FlutterFlowAudioPlayer(
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
                          FlutterFlowTheme.of(context).titleLarge.override(
                                fontFamily: 'Roboto',
                                letterSpacing: 0.0,
                                useGoogleFonts: false,
                              ),
                      playbackDurationTextStyle:
                          FlutterFlowTheme.of(context).labelMedium.override(
                                fontFamily: 'Roboto',
                                letterSpacing: 0.0,
                                useGoogleFonts: false,
                              ),
                      fillColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      playbackButtonColor:
                          FlutterFlowTheme.of(context).primary,
                      activeTrackColor:
                          FlutterFlowTheme.of(context).primary,
                      inactiveTrackColor:
                          FlutterFlowTheme.of(context).alternate,
                      elevation: 0.0,
                      playInBackground: PlayInBackground
                          .disabledRestoreOnForeground,
                    ),
                  ),
                const SizedBox(height: 12.0),
                ...List.generate(options.length, (optionIndex) {
                  final optionKeys = options.keys.toList();
                  final optionKey = optionKeys[optionIndex];
                  final option = options[optionKey];
                  final normalize = (dynamic value) => (value ?? '')
                      .toString()
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim()
                      .toLowerCase();

                  final optionText = option != null && option['text'] != null
                      ? extractOptionText(option)
                      : '';

                  final optionTextNormalized = normalize(optionText);
                  final correctAnswerNormalized = normalize(correctAnswer);
                  final optionKeyNormalized = normalize(optionKey);

                  final isCorrectAnswer =
                      correctAnswerNormalized.isNotEmpty &&
                          (optionKeyNormalized ==
                                  correctAnswerNormalized ||
                              optionTextNormalized ==
                                  correctAnswerNormalized);

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: isCorrectAnswer
                            ? const Color(0xFFF0FBF4)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: isCorrectAnswer
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFE5E7EB),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 4.0),
                          Container(
                            width: 24.0,
                            height: 24.0,
                            alignment: Alignment.center,
                            child: isCorrectAnswer
                                ? const Icon(Icons.check_circle,
                                    color: Color(0xFF16A34A), size: 22.0)
                                : const Icon(Icons.cancel,
                                    color: Color(0xFF9CA3AF), size: 22.0),
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                            width: 26.0,
                            height: 26.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              String.fromCharCode(65 + optionIndex),
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: FFFont.f12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (getJsonField(questionItem,
                                                r'''$.question_type''')
                                            .toString() ==
                                        'images' &&
                                    option != null &&
                                    option['image'] != null &&
                                    option['image'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 0.0, 0.0, 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            '${FFAppConstants.imageBaseURL}${option['image']}',
                                        width: 50.0,
                                        height: 50.0,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                RichText(
                                  textScaler:
                                      MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: extractOptionText(option),
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                          fontSize: FFFont.f14,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                      ),
                                      if (isCorrectAnswer)
                                        const TextSpan(
                                          text: ' (Correct Answer)',
                                          style: TextStyle(
                                            color: Color(0xFF16A34A),
                                            fontSize: FFFont.f14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 14.0),
                SizedBox(
                  width: double.infinity,
                  child: FFButtonWidget(
                    onPressed: () async {
                      final desc = biText(
                        (questionItem is Map ? questionItem['description'] : null) ??
                            (questionItem is Map && questionItem['question'] is Map ? questionItem['question']['description'] : null),
                      );
                      context.pushNamed(
                        ExplanationPageWidget.routeName,
                        queryParameters: {
                          'explanation': serializeParam(
                            desc.isNotEmpty ? desc : 'No explanation available for this question.',
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      );
                    },
                    text: 'View Solution',
                    icon: const Icon(
                      Icons.visibility_rounded,
                      color: Color(0xFF1D66E5),
                      size: 18.0,
                    ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 44.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                      color: const Color(0xFFF1F6FF),
                      textStyle: const TextStyle(
                        color: Color(0xFF1D66E5),
                        fontSize: FFFont.f14,
                        fontWeight: FontWeight.w700,
                      ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardTab() {
    return FutureBuilder<List<ApiCallResponse>>(
      future: Future.wait([
        QuizGroup.leaderboardApiCall.call(
          quizId: widget.quizID,
          token: FFAppState().loginToken,
        ),
        QuizGroup.getuserrankApiCall.call(
          userId: FFAppState().userId,
          quizId: widget.quizID,
          token: FFAppState().loginToken,
        ),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final leaderboardRes = snapshot.data![0];
        final userRankRes = snapshot.data![1];

        final users = _sortedLeaderboard(leaderboardRes);
        final topThree = users.take(3).toList();
        final maxScore = widget.totalQuestion ?? 0;

        final currentUserId = FFAppState().userId;
        final isInTop5 = users.any((u) =>
            (getJsonField(u, r'''$._id''') ?? '').toString() == currentUserId);

        dynamic currentUserData;
        int? currentUserRank;
        if (QuizGroup.getuserrankApiCall.success(
              userRankRes.jsonBody,
            ) ==
            1) {
          currentUserData =
              QuizGroup.getuserrankApiCall.user(userRankRes.jsonBody);
          currentUserRank =
              castToType<int>(getJsonField(currentUserData, r'''$.rank'''));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 18.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12.0, 14.0, 12.0, 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(color: const Color(0xFFF0F2F7)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A111827),
                      blurRadius: 18.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: users.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28.0),
                        child: Center(
                          child: Text(
                            'No leaderboard data yet',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontFamily: 'Roboto',
                              fontSize: FFFont.f12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (topThree.length > 1)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 18.0, right: 6.0),
                                child: _podiumCard(
                                  rank: '2',
                                  name: _displayName(topThree[1], fallbackRank: 1),
                                  points:
                                      '${_pointsLabel(topThree[1])} / ${_totalLabel(topThree[1])}',
                                  accent: const Color(0xFF8FB4F4),
                                  nameBackground: const Color(0xFFD7E5FF),
                                  scoreColor: const Color(0xFF1D4ED8),
                                  size: 74.0,
                                ),
                              ),
                            ),
                          if (topThree.isNotEmpty)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: _podiumCard(
                                  rank: '1',
                                  name: _displayName(topThree[0], fallbackRank: 0),
                                  points:
                                      '${_pointsLabel(topThree[0])} / ${_totalLabel(topThree[0])}',
                                  accent: const Color(0xFFF7C74D),
                                  nameBackground: const Color(0xFFF9E2A8),
                                  scoreColor: const Color(0xFFF97316),
                                  size: 88.0,
                                  crowned: true,
                                ),
                              ),
                            ),
                          if (topThree.length > 2)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 18.0, left: 6.0),
                                child: _podiumCard(
                                  rank: '3',
                                  name: _displayName(topThree[2], fallbackRank: 2),
                                  points:
                                      '${_pointsLabel(topThree[2])} / ${_totalLabel(topThree[2])}',
                                  accent: const Color(0xFFF59F80),
                                  nameBackground: const Color(0xFFFAD9CC),
                                  scoreColor: const Color(0xFFF97316),
                                  size: 74.0,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 12.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(color: const Color(0xFFF0F2F7)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A111827),
                      blurRadius: 18.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < (users.length > 5 ? 5 : users.length); i++)
                      _leaderboardRow(
                        rank: _rankForIndex(i),
                        name: _displayName(users[i], fallbackRank: i),
                        points: '${_pointsLabel(users[i])} / ${_totalLabel(users[i])}',
                        accent: i == 0
                            ? const Color(0xFF1D4ED8)
                            : i == 1
                                ? const Color(0xFF64748B)
                                : i == 2
                                    ? const Color(0xFFF97316)
                                    : const Color(0xFF94A3B8),
                        showBadge: i < 3,
                        isCurrentUser: (getJsonField(users[i], r'''$._id''') ?? '').toString() == currentUserId,
                      ),
                    if (!isInTop5 && currentUserRank != null && currentUserData != null)
                      Column(
                        children: [
                          const Divider(height: 1.0, color: Color(0xFFE5E7EB)),
                          _leaderboardRow(
                            rank: currentUserRank,
                            name: _displayName(currentUserData, fallbackRank: currentUserRank - 1),
                            points: '${_pointsLabel(currentUserData)} / ${_totalLabel(currentUserData)}',
                            accent: const Color(0xFF1D66E5),
                            showBadge: false,
                            isCurrentUser: true,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<dynamic> _sortedLeaderboard(ApiCallResponse response) {
    final users = QuizGroup.leaderboardApiCall.userList(response.jsonBody)?.toList() ?? [];
    users.sort((a, b) {
      final aCorrect = int.tryParse((getJsonField(a, r'''$.correct_answers''') ?? 0).toString()) ?? 0;
      final bCorrect = int.tryParse((getJsonField(b, r'''$.correct_answers''') ?? 0).toString()) ?? 0;
      if (bCorrect != aCorrect) return bCorrect.compareTo(aCorrect);
      final aPoints = double.tryParse((getJsonField(a, r'''$.points''') ?? 0).toString()) ?? 0.0;
      final bPoints = double.tryParse((getJsonField(b, r'''$.points''') ?? 0).toString()) ?? 0.0;
      return bPoints.compareTo(aPoints);
    });
    return users;
  }

  int _rankForIndex(int index) {
    return index + 1;
  }

  String _displayName(dynamic user, {required int fallbackRank}) {
    final first = (getJsonField(user, r'''$.firstname''') ?? '').toString().trim();
    final last = (getJsonField(user, r'''$.lastname''') ?? '').toString().trim();
    final username = (getJsonField(user, r'''$.username''') ?? '').toString().trim();
    final name = '$first $last'.trim();
    if (name.isNotEmpty) return name;
    if (username.isNotEmpty) return username;
    return 'User ${fallbackRank + 1}';
  }

  String _pointsLabel(dynamic user) {
    final value = getJsonField(user, r'''$.correct_answers''') ?? getJsonField(user, r'''$.points''') ?? getJsonField(user, r'''$.point''') ?? getJsonField(user, r'''$.score''');
    final points = double.tryParse(value?.toString() ?? '') ?? 0.0;
    return points % 1 == 0 ? points.toInt().toString() : points.toStringAsFixed(1);
  }

  String _totalLabel(dynamic user) {
    final value = getJsonField(user, r'''$.total_questions''');
    if (value != null) {
      final total = int.tryParse(value.toString());
      if (total != null) return total.toString();
    }
    return '${widget.totalQuestion ?? 0}';
  }

  String _cleanText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return '';
    return stripHtmlTagsAdvanced(text);
  }

  Map<String, dynamic> _optionMap(dynamic item) {
    var options = getJsonField(item, r'''$.option''');
    if (options == null && item is Map && item['question'] is Map) {
      options = getJsonField(item['question'], r'''$.option''');
    }
    if (options is Map) {
      return Map<String, dynamic>.from(options);
    }
    return <String, dynamic>{};
  }

  String _optionText(Map<String, dynamic> options, String key) {
    final option = options[key];
    if (option is Map) {
      final textValue = getJsonField(option, r'''$.text''');
      if (textValue is Map &&
          (textValue['en'] != null || textValue['hi'] != null)) {
        final text = _cleanText(biText(textValue));
        if (text.isNotEmpty) return text;
      }
      final nestedText = textValue is Map
          ? getJsonField(textValue, r'''$.text''') ?? getJsonField(textValue, r'''$.value''')
          : textValue;
      final text = _cleanText(nestedText ?? getJsonField(option, r'''$.value'''));
      if (text.isNotEmpty) return text;
    } else if (option != null) {
      final text = _cleanText(option);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String? _normalizedAnswerKey(dynamic answer, Map<String, dynamic> options) {
    final normalized = _cleanText(answer).toLowerCase();
    if (normalized.isEmpty) return null;

    for (final key in const ['a', 'b', 'c', 'd']) {
      if (normalized == key) return key;
      final optionText = _optionText(options, key).toLowerCase();
      if (optionText.isNotEmpty && optionText == normalized) {
        return key;
      }
    }
    return null;
  }

  String _subjectName(dynamic item) {
    final questionData = item is Map ? (item['question'] ?? item) : item;
    final subject = _cleanText(
      (item is Map ? item['subject'] : null) ??
          getJsonField(questionData, r'''$.subject'''),
    );
    return subject;
  }

  Widget _podiumCard({
    required String rank,
    required String name,
    required String points,
    required Color accent,
    required Color nameBackground,
    required Color scoreColor,
    required double size,
    bool crowned = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (crowned)
          const Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 38.0),
        if (crowned) const SizedBox(height: 4.0),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (crowned)
              Positioned(
                top: -14.0,
                left: 0.0,
                right: 0.0,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.auto_awesome, color: Color(0xFFF7D98A), size: 34.0),
                      Icon(Icons.auto_awesome, color: Color(0xFFF7D98A), size: 34.0),
                    ],
                  ),
                ),
              ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFF64748B),
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 4.0),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.18),
                    blurRadius: 18.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.person, color: Colors.white, size: size * 0.38),
            ),
            Positioned(
              top: 0.0,
              right: 0.0,
              child: Transform.translate(
                offset: const Offset(4.0, -4.0),
                child: Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    rank,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: FFFont.f10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: nameBackground,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontFamily: 'Roboto',
              fontSize: FFFont.f12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A111827),
                blurRadius: 12.0,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            points,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scoreColor,
              fontFamily: 'Roboto',
              fontSize: FFFont.f12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _leaderboardRow({
    required int rank,
    required String name,
    required String points,
    required Color accent,
    bool showBadge = false,
    bool isCurrentUser = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFEEF2FF) : Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB).withOpacity(0.8))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20.0,
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: accent,
                fontFamily: 'Roboto',
                fontSize: FFFont.f12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: isCurrentUser ? const Color(0xFF1D66E5) : const Color(0xFF64748B),
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 2.0),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 22.0),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              isCurrentUser ? 'You' : name,
              style: TextStyle(
                color: const Color(0xFF111827),
                fontFamily: 'Roboto',
                fontSize: FFFont.f12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 62.0,
            child: Text(
              points,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontFamily: 'Roboto',
                fontSize: FFFont.f11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          SizedBox(
            width: 22.0,
            child: showBadge
                ? Icon(
                    rank == 1
                        ? Icons.emoji_events_rounded
                        : Icons.military_tech_rounded,
                    color: accent,
                    size: 18.0,
                  )
                : isCurrentUser
                    ? const Icon(Icons.person_pin, color: Color(0xFF1D66E5), size: 18.0)
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    final total = widget.totalQuestion ?? 0;
    final correct = _computedCorrect;
    final wrong = _computedWrong;
    final skipped = _computedSkipped;
    final percent = total <= 0 ? 0.0 : (correct / total).clamp(0.0, 1.0).toDouble();

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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827), size: 22.0),
                  ),
                  const Expanded(
                    child: Text('Test Result', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF111827), fontSize: FFFont.f18, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 48.0),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 2.0),
                      child: Row(
                        children: [
                          _tabLabel('Test Result', _tabController.index == 0, () => _tabController.animateTo(0)),
                          _tabLabel('Answer Key', _tabController.index == 1, () => _tabController.animateTo(1)),
                          _tabLabel('Leaderboard', _tabController.index == 2, () => _tabController.animateTo(2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildResultTab(total: total, correct: correct, wrong: wrong, skipped: skipped, percent: percent),
                  _buildAnswerKeyTab(),
                  _buildLeaderboardTab(),
                ],
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
    // Quiz is over — unlock the app so the user can navigate away
    FFAppState().isQuizActive = false;
    _answerKeyLanguage = FFAppState().quizLang;
    _model = createModel(context, () => QuizResultModel());
    _tabController = TabController(vsync: this, length: 3)
      ..addListener(() => safeSetState(() {}));

    _computeCountsFromQuesList();

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
        correctAnswers: _computedCorrect,
        wrongAnswers: _computedWrong,
        score: (((_computedCorrect) * (widget.correctAnsReward ?? 0.0)) - ((_computedWrong) * (widget.penaltyPerQuestion ?? 0.0))),
        token: FFAppState().loginToken,
      );
      await _loadPercentile();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          // The completed result is already available locally. Keep showing
          // it even if the connection monitor briefly reports offline; only
          // the percentile value depends on the follow-up API request.
          body: _buildResultContent(),
        ),
      ),
    );
  }
}
