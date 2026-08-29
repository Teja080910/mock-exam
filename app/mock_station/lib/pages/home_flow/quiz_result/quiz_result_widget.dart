import 'dart:convert';

import '/app_constants.dart';
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

class _QuizResultWidgetState extends State<QuizResultWidget>
    with TickerProviderStateMixin {
  late QuizResultModel _model;
  late TabController _tabController;
  late TabController _answerKeyTabController;

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
              fontSize: 10.0,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 16.0,
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
                  fontSize: 9.0,
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

  Widget _buildSectionalSummary() {
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
                fontSize: 16.0,
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
                      fontSize: 11.0,
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
                      fontSize: 11.0,
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
                      fontSize: 11.0,
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
                      fontSize: 11.0,
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
                      fontSize: 11.0,
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
                            fontSize: 13.0,
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
                            fontSize: 13.0,
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
                            fontSize: 13.0,
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
                            fontSize: 13.0,
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
                            fontSize: 13.0,
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

    for (final item in items) {
      final questionData = item is Map && item['question'] is Map ? item['question'] as Map : <String, dynamic>{};
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
                fontSize: 13.0,
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
                            Text('Great Job! 🎉', style: TextStyle(color: Color(0xFF18C66A), fontSize: 24.0, fontWeight: FontWeight.w900)),
                            SizedBox(height: 8.0),
                            Text('You have completed the test successfully.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13.0, height: 1.35, fontWeight: FontWeight.w500)),
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
                            Text('$correct/$total', style: const TextStyle(color: Color(0xFF111827), fontSize: 26.0, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4.0),
                            const Text('Score', style: TextStyle(color: Color(0xFF64748B), fontSize: 11.0, fontWeight: FontWeight.w600)),
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
                      Text('Performance Summary', style: TextStyle(color: Color(0xFF111827), fontSize: 16.0, fontWeight: FontWeight.w800)),
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
                      _buildMetricCard(title: 'Accuracy', value: accuracyLabel, icon: Icons.track_changes_rounded, accentColor: const Color(0xFF0B84FF), backgroundColor: const Color(0xFFF1F6FF), badge: _accuracy >= 60 ? 'Good' : 'Low'),
                    ],
                  ),
                  const SizedBox(height: 14.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(color: const Color(0xFFF7F1FF), borderRadius: BorderRadius.circular(12.0)),
                    child: Row(
                      children: [
                        Container(
                          width: 44.0, height: 44.0,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.0)),
                          child: const Icon(Icons.timer_outlined, color: Color(0xFFA855F7), size: 28.0),
                        ),
                        const SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Time Taken', style: TextStyle(color: Color(0xFF111827), fontSize: 12.0, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6.0),
                            Text(timeLabel, style: const TextStyle(color: Color(0xFF111827), fontSize: 20.0, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18.0),
                  _buildSectionalSummary(),
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
    final questions = FFAppState().quesList.toList();
    final list = questions.isNotEmpty
        ? questions
        : List.generate(
            widget.totalQuestion ?? 0,
            (index) => <String, dynamic>{'user_answer': 'skipped'},
          );

    final answered = list.where((q) =>
        q['user_answer'] != null && q['user_answer'] != 'skipped').toList();
    final skipped = list.where((q) =>
        q['user_answer'] == null || q['user_answer'] == 'skipped').toList();

    return Column(
      children: [
        Align(
          alignment: const Alignment(0.0, 0),
          child: TabBar(
            labelColor: FlutterFlowTheme.of(context).primaryText,
            unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
            labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Roboto',
                  letterSpacing: 0.0,
                  useGoogleFonts: false,
                ),
            unselectedLabelStyle: const TextStyle(),
            indicatorColor: FlutterFlowTheme.of(context).primary,
            padding: const EdgeInsets.all(4.0),
            tabs: [
              Tab(text: 'Answered (${answered.length})'),
              Tab(text: 'Skipped (${skipped.length})'),
            ],
            controller: _answerKeyTabController,
            onTap: (i) async {},
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _answerKeyTabController,
            children: [
              _buildAnsweredList(answered),
              _buildSkippedList(skipped),
            ],
          ),
        ),
      ],
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
                          fontSize: 13.0,
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
                              '${optionIndex + 1}',
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 12.0,
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
                                          fontSize: 14.0,
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
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      else if (isCorrectAnswer)
                                        const TextSpan(
                                          text: ' (Correct Answer)',
                                          style: TextStyle(
                                            color: Color(0xFF16A34A),
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      else if (isUserSelected)
                                        const TextSpan(
                                          text: ' (Your Answer)',
                                          style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 13.0,
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
                        fontSize: 14.0,
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
                          fontSize: 13.0,
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
                              '${optionIndex + 1}',
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 12.0,
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
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          height: 1.4,
                                        ),
                                      ),
                                      if (isCorrectAnswer)
                                        const TextSpan(
                                          text: ' (Correct Answer)',
                                          style: TextStyle(
                                            color: Color(0xFF16A34A),
                                            fontSize: 13.0,
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
                        fontSize: 14.0,
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
                              fontSize: 12.0,
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
                                      '${_pointsLabel(topThree[1])} / ${maxScore.toDouble().toStringAsFixed(1)}',
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
                                      '${_pointsLabel(topThree[0])} / ${maxScore.toDouble().toStringAsFixed(1)}',
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
                                      '${_pointsLabel(topThree[2])} / ${maxScore.toDouble().toStringAsFixed(1)}',
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
                        points: '${_pointsLabel(users[i])} / ${maxScore.toInt()}',
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
                            points: '${_pointsLabel(currentUserData)} / ${maxScore.toInt()}',
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
    final value = getJsonField(user, r'''$.points''') ?? getJsonField(user, r'''$.point''') ?? getJsonField(user, r'''$.score''');
    final points = double.tryParse(value?.toString() ?? '') ?? 0.0;
    return points % 1 == 0 ? points.toInt().toString() : points.toStringAsFixed(1);
  }

  String _cleanText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return '';
    return stripHtmlTagsAdvanced(text);
  }

  Map<String, dynamic> _optionMap(dynamic item) {
    final options = getJsonField(item, r'''$.option''');
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
          getJsonField(questionData, r'''$.subject''') ??
          (item is Map ? item['subcategoryName'] : null) ??
          getJsonField(questionData, r'''$.subcategoryName'''),
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
                      fontSize: 10.0,
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
              fontSize: 12.0,
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
              fontSize: 12.0,
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
                fontSize: 12.0,
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
                fontSize: 12.0,
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
                fontSize: 11.0,
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
    final correct = widget.correctAnswer ?? 0;
    final wrong = widget.wrongAnswer ?? 0;
    final skipped = widget.notAnswer ?? 0;
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
                    child: Text('Test Result', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF111827), fontSize: 18.0, fontWeight: FontWeight.w800)),
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
    _model = createModel(context, () => QuizResultModel());
    _tabController = TabController(vsync: this, length: 3)
      ..addListener(() => safeSetState(() {}));
    _answerKeyTabController = TabController(vsync: this, length: 2)
      ..addListener(() => safeSetState(() {}));

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
        score: (((widget.correctAnswer ?? 0) * (widget.correctAnsReward ?? 0.0)) - ((widget.wrongAnswer ?? 0) * (widget.penaltyPerQuestion ?? 0.0))),
        token: FFAppState().loginToken,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _answerKeyTabController.dispose();
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
