import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/shimmer/shimmer_block/shimmer_block_widget.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'self_quiz_result_model.dart';
export 'self_quiz_result_model.dart';

class SelfQuizResultWidget extends StatefulWidget {
  const SelfQuizResultWidget({
    super.key,
    this.correctAnswer,
    this.wrongAnswer,
    this.totalQuestion,
    this.notAnswer,
    this.quizID,
    this.title,
    this.image,
    this.quizTime,
  });

  final int? correctAnswer;
  final int? wrongAnswer;
  final int? totalQuestion;
  final int? notAnswer;
  final String? quizID;
  final String? title;
  final String? image;
  final String? quizTime;

  static String routeName = 'self_quiz_result';
  static String routePath = '/selfQuizResult';

  @override
  State<SelfQuizResultWidget> createState() => _SelfQuizResultWidgetState();
}

class _SelfQuizResultWidgetState extends State<SelfQuizResultWidget>
    with TickerProviderStateMixin {
  late SelfQuizResultModel _model;
  late TabController _tabController;
  int _answerKeyFilterIndex = 0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Quiz is over — unlock the app so the user can navigate away
    FFAppState().isQuizActive = false;
    _model = createModel(context, () => SelfQuizResultModel());
    _tabController = TabController(vsync: this, length: 3)
      ..addListener(() => safeSetState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _model.dispose();

    super.dispose();
  }

  double get _score => (widget.correctAnswer ?? 0).toDouble();

  List<dynamic> _questions() {
    final list = FFAppState().quesList;
    return list is List ? list.toList() : [];
  }

  List<String> _sectionLabels() {
    final labels = <String>[];
    for (final item in _questions()) {
      final questionData = item is Map ? (item['question'] ?? item) : item;
      final subject = _cleanText(
        (item is Map ? item['subject'] : null) ??
            getJsonField(questionData, r'''$.subject''') ??
            (item is Map ? item['subcategoryName'] : null) ??
            getJsonField(questionData, r'''$.subcategoryName'''),
      );
      if (subject.isEmpty) continue;
      if (!labels.contains(subject)) {
        labels.add(subject);
      }
    }
    return labels;
  }

  Future<void> _goHome() async {
    FFAppState().notAnswerQues = 0;
    FFAppState().quesList = [];
    FFAppState().notAnswerQuestion = [];
    FFAppState().correctSelfQues = 0;
    FFAppState().wrongSelfques = 0;
    FFAppState().update(() {});
    FFAppState().clearCoinsCache();
    FFAppState().clearCoinsHistoryCache();
    if (mounted) {
      context.goNamed(HomeScreenWidget.routeName);
    }
  }

  String _displayName(dynamic user, {required int fallbackRank}) {
    final first =
        (getJsonField(user, r'''$.firstname''') ?? '').toString().trim();
    final last =
        (getJsonField(user, r'''$.lastname''') ?? '').toString().trim();
    final username =
        (getJsonField(user, r'''$.username''') ?? '').toString().trim();
    final name = '$first $last'.trim();
    if (name.isNotEmpty) return name;
    if (username.isNotEmpty) return username;
    return 'User ${fallbackRank + 1}';
  }

  String _pointsLabel(dynamic user) {
    final value = getJsonField(user, r'''$.points''') ??
        getJsonField(user, r'''$.point''') ??
        getJsonField(user, r'''$.score''');
    final points = double.tryParse(value?.toString() ?? '') ?? 0.0;
    return points % 1 == 0 ? points.toInt().toString() : points.toStringAsFixed(1);
  }

  List<dynamic> _sortedLeaderboard(ApiCallResponse response) {
    final users = QuizGroup.leaderboardApiCall.userList(response.jsonBody)
            ?.toList() ??
        [];
    users.sort((a, b) {
      final aPoints = double.tryParse(
              (getJsonField(a, r'''$.points''') ?? 0).toString()) ??
          0.0;
      final bPoints = double.tryParse(
              (getJsonField(b, r'''$.points''') ?? 0).toString()) ??
          0.0;
      return bPoints.compareTo(aPoints);
    });
    return users;
  }

  int _rankForIndex(int index) {
    return index + 1;
  }

  String _cleanText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return '';
    return text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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

  bool _isAnsweredQuestion(dynamic item) {
    final userAnswer = _cleanText(getJsonField(item, r'''$.user_answer'''));
    return userAnswer.isNotEmpty && userAnswer.toLowerCase() != 'skipped';
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
      final text =
          _cleanText(nestedText ?? getJsonField(option, r'''$.value'''));
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

  String _questionLabel(dynamic item, int index) {
    final title = biText(getJsonField(item, r'''$.question_title'''));
    final label = _cleanText(
      title.trim().isNotEmpty
          ? title
          : getJsonField(item, r'''$.question''') ??
              getJsonField(item, r'''$.title'''),
    );
    return label.isNotEmpty ? label : 'Q${index + 1}';
  }

  Widget _answerKeyTabChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFF1D4ED8) : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? const Color(0xFF1D4ED8) : const Color(0xFF6B7280),
              fontSize: FFFont.f14,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _answerKeyOptionRow({
    required String text,
    required Color iconColor,
    required IconData icon,
    required bool emphasized,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: text,
                style: TextStyle(
                  color: const Color(0xFF111827),
                  fontSize: FFFont.f14,
                  fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
                ),
                children: [
                  if (suffix != null)
                    TextSpan(
                      text: suffix,
                      style: TextStyle(
                        color: iconColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerKeyCard({
    required dynamic item,
    required int index,
  }) {
    final options = _optionMap(item);
    final userAnswer = _cleanText(getJsonField(item, r'''$.user_answer'''));
    final answer = biText(getJsonField(item, r'''$.answer'''));
    final correctKey = _normalizedAnswerKey(answer, options);
    final userKey = _normalizedAnswerKey(userAnswer, options);
    final isAnswered = userAnswer.isNotEmpty && userAnswer.toLowerCase() != 'skipped';
    final questionText = _questionLabel(item, index);
    final optionKeys = const ['a', 'b', 'c', 'd'];

    final visibleOptions = <String, String>{};
    for (final key in optionKeys) {
      final optionText = _optionText(options, key);
      if (optionText.isNotEmpty) {
        visibleOptions[key] = optionText;
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14.0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${index + 1}. $questionText',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: FFFont.f16,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14.0),
          if (visibleOptions.isNotEmpty)
            for (final entry in visibleOptions.entries)
              Builder(
                builder: (context) {
                  final key = entry.key;
                  final optionText = entry.value;
                  final isCorrect = correctKey != null && key == correctKey;
                  final isUser = isAnswered && userKey != null && key == userKey;

                  if (!isAnswered && !isCorrect) {
                    return _answerKeyOptionRow(
                      text: optionText,
                      iconColor: const Color(0xFF6B7280),
                      icon: Icons.close_rounded,
                      emphasized: false,
                    );
                  }

                  if (isCorrect) {
                    return _answerKeyOptionRow(
                      text: optionText,
                      iconColor: const Color(0xFF22C55E),
                      icon: Icons.check_rounded,
                      emphasized: true,
                      suffix: ' (Correct Answer)',
                    );
                  }

                  if (isUser) {
                    return _answerKeyOptionRow(
                      text: optionText,
                      iconColor: const Color(0xFFEF4444),
                      icon: Icons.close_rounded,
                      emphasized: true,
                      suffix: ' (Your Answer)',
                    );
                  }

                  return _answerKeyOptionRow(
                    text: optionText,
                    iconColor: const Color(0xFF6B7280),
                    icon: Icons.close_rounded,
                    emphasized: false,
                  );
                },
              )
          else
            Text(
              isAnswered ? 'Answer recorded' : 'Skipped',
              style: TextStyle(
                color: isAnswered ? const Color(0xFF1D4ED8) : const Color(0xFF6B7280),
                fontSize: FFFont.f14,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
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
                color:
                    selected ? const Color(0xFF1D4ED8) : const Color(0xFF6B7280),
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

  Widget _statCard(String title, String value, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: FFFont.f11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            value,
            style: TextStyle(
              color: fg,
              fontSize: FFFont.f20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTab({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFFF43F5E)
                      : const Color(0xFF6B7280),
                  fontSize: FFFont.f11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              height: 3.0,
              width: 92.0,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFF43F5E) : Colors.transparent,
                borderRadius: BorderRadius.circular(999.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryMetricCard({
    required Color color,
    required Color background,
    required IconData icon,
    required String title,
    required String value,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 28.0,
              height: 28.0,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(icon, color: color, size: 18.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 38.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: FFFont.f11,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: FFFont.f20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: color,
                        fontSize: FFFont.f10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeTakenCard(String timeText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEFF),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: const Color(0xFFB04BFF).withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timelapse_rounded,
              color: Color(0xFFB04BFF),
              size: 22.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Time Taken',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: FFFont.f11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                timeText,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: FFFont.f20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leaderboardRow({
    required int rank,
    required String name,
    required String points,
    required Color accent,
    bool crown = false,
    bool isCurrentUser = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      decoration: BoxDecoration(
        color: isCurrentUser ? const Color(0xFFEEF2FF) : Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE9EDF5).withOpacity(0.95)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28.0,
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: rank == 1
                    ? const Color(0xFF1D4ED8)
                    : rank == 2
                        ? const Color(0xFF2563EB)
                        : rank == 3
                            ? const Color(0xFFF97316)
                            : const Color(0xFF64748B),
                fontSize: FFFont.f18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Container(
            width: 52.0,
            height: 52.0,
            decoration: BoxDecoration(
              color: isCurrentUser ? const Color(0xFF1D66E5) : const Color(0xFF64748B),
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 3.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30.0),
          ),
          const SizedBox(width: 18.0),
          Expanded(
            child: Text(
              isCurrentUser ? 'You' : name,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: FFFont.f16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            points,
            style: const TextStyle(
              color: Color(0xFF172554),
              fontSize: FFFont.f16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 14.0),
          Icon(
            isCurrentUser
                ? Icons.person_pin
                : (crown ? Icons.emoji_events_rounded : Icons.verified_rounded),
            color: isCurrentUser
                ? const Color(0xFF1D66E5)
                : (crown ? const Color(0xFFF59E0B) : accent),
            size: 28.0,
          ),
        ],
      ),
    );
  }

  Widget _podiumCard({
    required String rank,
    required String name,
    required String points,
    required Color accent,
    required double size,
    bool crowned = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFF64748B),
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 4.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12.0,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 38.0),
            ),
            Positioned(
              top: 0.0,
              right: 2.0,
              child: Container(
                width: 22.0,
                height: 22.0,
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
                    fontSize: FFFont.f11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (crowned)
              const Positioned(
                top: -34.0,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFF59E0B),
                  size: 34.0,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.20),
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: Text(
            name,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: FFFont.f14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          points,
          style: TextStyle(
            color: rank == '1'
                ? const Color(0xFFF97316)
                : rank == '2'
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFFF97316),
            fontSize: FFFont.f16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildResultTab({
    required int total,
    required int correct,
    required int wrong,
    required int skipped,
    required double percent,
  }) {
    final completion = total <= 0 ? 0 : (((correct + wrong + skipped) / total) * 100).clamp(0, 100).toInt();
    final totalMarks = correct.toDouble();
    final wrongPercentage = total <= 0 ? 0 : ((wrong / total) * 100).round().clamp(0, 100);
    final timeText = _cleanText(widget.quizTime).isNotEmpty ? _cleanText(widget.quizTime) : '--:--';
    final sectionLabels = _sectionLabels();
    final activeSectionIndex = 1;
    return FutureBuilder<ApiCallResponse>(
      future: QuizGroup.getpointssettingApiCall.call(
        token: FFAppState().loginToken,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final pointsResponse = snapshot.data!;
        final double totalMarkVal = ((((widget.correctAnswer ?? 0) *
                        (QuizGroup.getpointssettingApiCall.selfChallengePoints(
                              pointsResponse.jsonBody,
                            ) ??
                            0)
                            .toDouble()) -
                    ((widget.wrongAnswer ?? 0) *
                        (QuizGroup.getpointssettingApiCall.selfChallengePenalty(
                              pointsResponse.jsonBody,
                            ) ??
                            0)))
                .toDouble());
        final totalMark = totalMarkVal.toStringAsFixed(totalMarkVal.truncateToDouble() == totalMarkVal ? 0 : 2);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 18.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Great Job! 🎉',
                            style: TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: FFFont.f24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          const Text(
                            'You have completed the test successfully.',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: FFFont.f14,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 120.0,
                      height: 120.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 14.0,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: CircularPercentIndicator(
                          percent: percent,
                          radius: 54.0,
                          lineWidth: 8.0,
                          animation: true,
                          animateFromLastPercent: true,
                          progressColor: const Color(0xFF16A34A),
                          backgroundColor: const Color(0xFFF3F4F6),
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$correct/$total',
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: FFFont.f24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              const Text(
                                'Score',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: FFFont.f11,
                                  fontWeight: FontWeight.w600,
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
              const SizedBox(height: 14.0),
              Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Summary',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: FFFont.f16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 1.65,
                      children: [
                        _summaryMetricCard(
                          color: const Color(0xFF2563EB),
                          background: const Color(0xFFF1F6FF),
                          icon: Icons.view_list_rounded,
                          title: 'Total Questions',
                          value: total.toString(),
                        ),
                        _summaryMetricCard(
                          color: const Color(0xFF7C3AED),
                          background: const Color(0xFFF7F1FF),
                          icon: Icons.emoji_events_rounded,
                          title: 'Total Marks',
                          value: totalMark,
                        ),
                        _summaryMetricCard(
                          color: const Color(0xFF16A34A),
                          background: const Color(0xFFF0FBF4),
                          icon: Icons.check_circle_rounded,
                          title: 'Correct Answers',
                          value: correct.toString(),
                          badge: '${total <= 0 ? 0 : ((correct / total) * 100).round()}%',
                        ),
                        _summaryMetricCard(
                          color: const Color(0xFFEF4444),
                          background: const Color(0xFFFFF3F3),
                          icon: Icons.cancel_rounded,
                          title: 'Incorrect Answers',
                          value: wrong.toString(),
                          badge: '$wrongPercentage%',
                        ),
                        _summaryMetricCard(
                          color: const Color(0xFFF59E0B),
                          background: const Color(0xFFFFFAEE),
                          icon: Icons.access_time_rounded,
                          title: 'Skipped Questions',
                          value: skipped.toString(),
                          badge: '${total <= 0 ? 0 : ((skipped / total) * 100).round()}%',
                        ),
                        _summaryMetricCard(
                          color: const Color(0xFF1D4ED8),
                          background: const Color(0xFFF1F6FF),
                          icon: Icons.radio_button_checked_rounded,
                          title: 'Accuracy',
                          value: '${total <= 0 ? 0 : ((correct / total) * 100).round()}%',
                          badge: 'Low',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    _timeTakenCard(timeText),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
              if (sectionLabels.length >= 2)
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sectional Summary',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: FFFont.f16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        for (var i = 0; i < sectionLabels.length; i++)
                          _sectionTab(
                            text: sectionLabels[i],
                            selected: activeSectionIndex == i,
                            onTap: () {},
                          ),
                      ],
                    ),
                    const SizedBox(height: 14.0),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4FFF6),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38.0,
                            height: 38.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF10B981),
                              size: 22.0,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Score',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: FFFont.f11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '${(totalMarks - wrong).toStringAsFixed(1)}   |   $total',
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: FFFont.f18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4D4F),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Neg. Marks : -${(wrong * 0.5).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: FFFont.f10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4EEFF),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38.0,
                            height: 38.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB04BFF).withOpacity(0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.timelapse_rounded,
                              color: Color(0xFFB04BFF),
                              size: 22.0,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time Spent',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: FFFont.f11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                timeText,
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: FFFont.f18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildAnswerKeyTab({
    required List<dynamic> questions,
  }) {
    final list = questions.isNotEmpty
        ? questions
        : List.generate(
            widget.totalQuestion ?? 0,
            (index) => <String, dynamic>{'user_answer': 'skipped'},
          );

    final answered = list.where(_isAnsweredQuestion).toList();
    final skipped = list.where((item) => !_isAnsweredQuestion(item)).toList();
    final visibleList = _answerKeyFilterIndex == 0 ? answered : skipped;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                _answerKeyTabChip(
                  label: 'Answered',
                  selected: _answerKeyFilterIndex == 0,
                  onTap: () => setState(() => _answerKeyFilterIndex = 0),
                ),
                _answerKeyTabChip(
                  label: 'Skipped',
                  selected: _answerKeyFilterIndex == 1,
                  onTap: () => setState(() => _answerKeyFilterIndex = 1),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 18.0),
            children: [
              if (visibleList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    _answerKeyFilterIndex == 0
                        ? 'No answered questions yet.'
                        : 'No skipped questions found.',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: FFFont.f14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                for (var i = 0; i < visibleList.length; i++)
                  _answerKeyCard(
                    item: visibleList[i],
                    index: i,
                  ),
            ],
          ),
        ),
      ],
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
                padding: const EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 18.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 18.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (topThree.length > 1)
                      Expanded(
                        child: _podiumCard(
                          rank: '2',
                          name: _displayName(topThree[1], fallbackRank: 1),
                          points: '${_pointsLabel(topThree[1])} / 25.0',
                          accent: const Color(0xFF9DBAF9),
                          size: 88.0,
                        ),
                      ),
                    if (topThree.isNotEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: _podiumCard(
                            rank: '1',
                            name: _displayName(topThree[0], fallbackRank: 0),
                            points: '${_pointsLabel(topThree[0])} / 25.0',
                            accent: const Color(0xFFF7C84A),
                            size: 108.0,
                            crowned: true,
                          ),
                        ),
                      ),
                    if (topThree.length > 2)
                      Expanded(
                        child: _podiumCard(
                          rank: '3',
                          name: _displayName(topThree[2], fallbackRank: 2),
                          points: '${_pointsLabel(topThree[2])} / 25.0',
                          accent: const Color(0xFFF7B08A),
                          size: 88.0,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
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
                        points: '${_pointsLabel(users[i])} / 25',
                        accent: i == 0
                            ? const Color(0xFFF59E0B)
                            : i == 1
                                ? const Color(0xFF64748B)
                                : i == 2
                                    ? const Color(0xFFF97316)
                                    : const Color(0xFF94A3B8),
                        crown: i == 0,
                        isCurrentUser: (getJsonField(users[i], r'''$._id''') ?? '').toString() == currentUserId,
                      ),
                    if (!isInTop5 && currentUserRank != null && currentUserData != null)
                      Column(
                        children: [
                          const Divider(height: 1.0, color: Color(0xFFE9EDF5)),
                          _leaderboardRow(
                            rank: currentUserRank,
                            name: _displayName(currentUserData, fallbackRank: currentUserRank - 1),
                            points: '${_pointsLabel(currentUserData)} / 25',
                            accent: const Color(0xFF1D66E5),
                            crown: false,
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

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final questions = _questions();
    final total = widget.totalQuestion ?? questions.length;
    final correct = widget.correctAnswer ?? 0;
    final wrong = widget.wrongAnswer ?? 0;
    final skipped = widget.notAnswer ?? 0;
    final percent = total <= 0 ? 0.0 : (correct / total).clamp(0.0, 1.0).toDouble();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF7F9FC),
        body: Builder(
          builder: (context) {
            if (FFAppState().connected != true) {
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

            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 10.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18.0,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        const Expanded(
                          child: SizedBox.shrink(),
                        ),
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
                                _tabLabel(
                                  'Test Result',
                                  _tabController.index == 0,
                                  () => _tabController.animateTo(0),
                                ),
                                _tabLabel(
                                  'Answer Key',
                                  _tabController.index == 1,
                                  () => _tabController.animateTo(1),
                                ),
                                _tabLabel(
                                  'Leaderboard',
                                  _tabController.index == 2,
                                  () => _tabController.animateTo(2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4.0),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildResultTab(
                          total: total,
                          correct: correct,
                          wrong: wrong,
                          skipped: skipped,
                          percent: percent,
                        ),
                        _buildAnswerKeyTab(questions: questions),
                        _buildLeaderboardTab(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
