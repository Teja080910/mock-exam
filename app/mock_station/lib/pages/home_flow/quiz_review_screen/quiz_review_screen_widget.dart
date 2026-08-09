import '/flutter_flow/flutter_flow_audio_player.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/componants/quit_quiz/quit_quiz_widget.dart';
import '/index.dart';
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
    this.quizID,
    this.title,
    this.correctAnsReward,
    this.penaltyPerQuestion,
    this.quizTime,
  });

  final String? catID;
  final String? quizID;
  final String? title;
  final double? correctAnsReward;
  final double? penaltyPerQuestion;
  final String? quizTime;

  static String routeName = 'quiz_review_screen';
  static String routePath = '/quizReviewScreen';

  @override
  State<QuizReviewScreenWidget> createState() => _QuizReviewScreenWidgetState();
}

class _QuizReviewScreenWidgetState extends State<QuizReviewScreenWidget> {
  late QuizReviewScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedSectionIndex = 0;

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

  Future<void> _showQuitQuizDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(dialogContext).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: const QuitQuizWidget(),
          ),
        );
      },
    );
  }

  List<dynamic> _reviewQuestions() {
    final list = FFAppState().quesReviewList;
    if (list.isNotEmpty) return list.toList();
    return FFAppState().quesList.toList();
  }

  bool _isAnswered(dynamic question) {
    final value = getJsonField(question, r'''$.user_answer''');
    return value != null && value.toString() != 'skipped';
  }

  Widget _buildLegendDot({
    required Color color,
    required String label,
    bool outlined = false,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12.0,
            height: 12.0,
            decoration: BoxDecoration(
              color: outlined ? Colors.white : color,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.2),
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberChip({
    required int number,
    required bool filled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF1D66E5) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: filled ? const Color(0xFF1D66E5) : const Color(0xFFD6DCE5),
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: const Color(0xFF1D66E5).withOpacity(0.16),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        alignment: Alignment.center,
        child: Text(
          number.toString(),
          style: TextStyle(
            color: filled ? Colors.white : const Color(0xFF374151),
            fontSize: 12.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTab({
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFFF43F5E)
                      : const Color(0xFF4B5563),
                  fontSize: 11.0,
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

  Widget _buildQuestionGridCard({
    required String title,
    required List<dynamic> questions,
    required bool showSubmitButton,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFE8EDF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: const Color(0xFF1F2937).withOpacity(0.9),
                  size: 24.0,
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBFF),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFE4EAF4)),
              ),
              child: Row(
                children: [
                  _buildLegendDot(
                    color: const Color(0xFF1D66E5),
                    label: 'Answered',
                  ),
                  Container(
                    width: 1.0,
                    height: 16.0,
                    color: const Color(0xFFE5E7EB),
                  ),
                  _buildLegendDot(
                    color: const Color(0xFF8EA0BF),
                    label: 'Not Answered',
                    outlined: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14.0),
            _buildQuestionGrid(questions: questions),
            if (showSubmitButton) ...[
              const SizedBox(height: 14.0),
              SizedBox(
                width: double.infinity,
                height: 46.0,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pushNamed(
                      QuizResultWidget.routeName,
                      queryParameters: {
                        'correctAnswer': serializeParam(FFAppState().correctQues, ParamType.int),
                        'wrongAnswer': serializeParam(FFAppState().wrongQues, ParamType.int),
                        'totalQuestion': serializeParam(FFAppState().quesList.length, ParamType.int),
                        'notAnswer': serializeParam(FFAppState().notAnswerQues, ParamType.int),
                        'quizID': serializeParam(widget.quizID ?? '', ParamType.String),
                        'title': serializeParam(widget.title ?? '', ParamType.String),
                        'correctAnsReward': serializeParam(widget.correctAnsReward ?? 0.0, ParamType.double),
                        'penaltyPerQuestion': serializeParam(widget.penaltyPerQuestion ?? 0.0, ParamType.double),
                        'quizTime': serializeParam(widget.quizTime ?? '', ParamType.String),
                      }.withoutNulls,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF1D66E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  icon: const Icon(Icons.description_outlined, size: 18.0),
                  label: const Text(
                    'SUBMIT TEST',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionGrid({
    required List<dynamic> questions,
    List<dynamic>? allQuestions,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const itemSpacing = 8.0;
        const columns = 5;
        final itemSize =
            ((constraints.maxWidth - (itemSpacing * (columns - 1))) / columns)
                .floorToDouble();
        return Wrap(
          spacing: itemSpacing,
          runSpacing: itemSpacing,
          children: [
            for (var i = 0; i < questions.length; i++)
              SizedBox(
                width: itemSize,
                child: Center(
                  child: _buildNumberChip(
                    number: (allQuestions != null
                            ? allQuestions.indexOf(questions[i])
                            : i) +
                        1,
                    filled: _isAnswered(questions[i]),
                    onTap: () => context.pop(allQuestions != null
                        ? allQuestions.indexOf(questions[i])
                        : i),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSubjectGridCard({
    required String subject,
    required List<dynamic> questions,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFE8EDF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12.0),
            _buildQuestionGrid(questions: questions),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionPanel({
    required List<dynamic> questions,
  }) {
    final Map<String, List<dynamic>> grouped = {};
    for (final q in questions) {
      final questionData = q is Map ? (q['question'] ?? q) : q;
      final sub = (getJsonField(questionData, r'''$.subcategoryName''') ?? '').toString().trim();
      final key = sub.isEmpty ? 'General' : sub;
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(q);
    }
    final subjectKeys = grouped.keys.toList();
    if (subjectKeys.isEmpty) subjectKeys.add('General');
    final hasSubjectTabs = subjectKeys.length > 1 || subjectKeys.first != 'General';
    final tabLabels = hasSubjectTabs ? ['All', ...subjectKeys] : subjectKeys;
    if (_selectedSectionIndex >= tabLabels.length) {
      _selectedSectionIndex = 0;
    }
    final displayQuestions = hasSubjectTabs && _selectedSectionIndex > 0
        ? grouped[subjectKeys[_selectedSectionIndex - 1]] ?? questions
        : questions;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFE8EDF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18.0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2.0),
            if (hasSubjectTabs)
              Row(
                children: tabLabels.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final name = entry.value;
                  return _buildSectionTab(
                    text: name,
                    selected: _selectedSectionIndex == idx,
                    onTap: () => setState(() => _selectedSectionIndex = idx),
                  );
                }).toList(),
              ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                const Text(
                  'Questions:',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4.0),
                Text(
                  displayQuestions.length.toString(),
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 22.0,
                  height: 22.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF9CA3AF)),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 14.0,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            LayoutBuilder(
              builder: (context, constraints) {
                const columns = 5;
                const spacing = 10.0;
                final itemSize = ((constraints.maxWidth -
                            ((columns - 1) * spacing)) /
                        columns)
                    .floorToDouble();
                final questionCount = displayQuestions.length.clamp(0, 25);
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (var i = 0; i < questionCount; i++)
                      SizedBox(
                        width: itemSize,
                        child: Center(
                          child: _buildNumberChip(
                            number: i + 1,
                            filled: i < displayQuestions.length
                                ? _isAnswered(displayQuestions[i])
                                : false,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18.0),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBFF),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFE4EAF4)),
              ),
              child: Row(
                children: [
                  _buildLegendDot(
                    color: const Color(0xFF1D66E5),
                    label: 'Answered',
                  ),
                  Container(
                    width: 1.0,
                    height: 16.0,
                    color: const Color(0xFFE5E7EB),
                  ),
                  _buildLegendDot(
                    color: const Color(0xFF8EA0BF),
                    label: 'Not Answered',
                    outlined: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42.0,
                    child: OutlinedButton(
                      onPressed: _showQuitQuizDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1D66E5),
                        side: const BorderSide(color: Color(0xFF9EC0FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Submit Section',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: SizedBox(
                    height: 42.0,
                    child: ElevatedButton(
                      onPressed: _showQuitQuizDialog,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF1D66E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Submit Test',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSubjectGridCards(List<dynamic> questions) {
    final Map<String, List<dynamic>> grouped = {};
    for (final q in questions) {
      final questionData = q is Map ? (q['question'] ?? q) : q;
      final sub = (getJsonField(questionData, r'''$.subcategoryName''') ?? '').toString();
      grouped.putIfAbsent(sub.isEmpty ? 'General' : sub, () => []);
      grouped[sub.isEmpty ? 'General' : sub]!.add(q);
    }

    final subjectKeys = grouped.keys.toList();
    final hasSubjects = subjectKeys.length > 1;
    if (!hasSubjects) return [];

    final tabLabels = subjectKeys;
    if (_selectedSectionIndex >= tabLabels.length) {
      _selectedSectionIndex = 0;
    }
    final displayQuestions = grouped[tabLabels[_selectedSectionIndex]]!;

    return [
      const SizedBox(height: 16.0),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: const Color(0xFFE8EDF5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18.0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: tabLabels.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final name = entry.value;
                  return _buildSectionTab(
                    text: name,
                    selected: _selectedSectionIndex == idx,
                    onTap: () => setState(() => _selectedSectionIndex = idx),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBFF),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFE4EAF4)),
                ),
                child: Row(
                  children: [
                    _buildLegendDot(
                      color: const Color(0xFF1D66E5),
                      label: 'Answered',
                    ),
                    Container(
                      width: 1.0,
                      height: 16.0,
                      color: const Color(0xFFE5E7EB),
                    ),
                    _buildLegendDot(
                      color: const Color(0xFF8EA0BF),
                      label: 'Not Answered',
                      outlined: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
              _buildQuestionGrid(
                questions: displayQuestions,
                allQuestions: questions,
              ),
              const SizedBox(height: 14.0),
              SizedBox(
                width: double.infinity,
                height: 46.0,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pushNamed(
                      QuizResultWidget.routeName,
                      queryParameters: {
                        'correctAnswer': serializeParam(FFAppState().correctQues, ParamType.int),
                        'wrongAnswer': serializeParam(FFAppState().wrongQues, ParamType.int),
                        'totalQuestion': serializeParam(FFAppState().quesList.length, ParamType.int),
                        'notAnswer': serializeParam(FFAppState().notAnswerQues, ParamType.int),
                        'quizID': serializeParam(widget.quizID ?? '', ParamType.String),
                        'title': serializeParam(widget.title ?? '', ParamType.String),
                        'correctAnsReward': serializeParam(widget.correctAnsReward ?? 0.0, ParamType.double),
                        'penaltyPerQuestion': serializeParam(widget.penaltyPerQuestion ?? 0.0, ParamType.double),
                        'quizTime': serializeParam(widget.quizTime ?? '', ParamType.String),
                      }.withoutNulls,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF1D66E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  icon: const Icon(Icons.description_outlined, size: 18.0),
                  label: const Text(
                    'SUBMIT TEST',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => QuizReviewScreenModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final questions = _reviewQuestions();
    final sectionTabCount = questions.isEmpty ? 25 : questions.length.clamp(0, 25).toInt();
    final answeredCount = questions.where(_isAnswered).length;
    final notAnsweredCount = (questions.isEmpty ? 25 : questions.length) - answeredCount;

    final Map<String, List<dynamic>> grouped = {};
    for (final q in questions) {
      final questionData = q is Map ? (q['question'] ?? q) : q;
      final sub = (getJsonField(questionData, r'''$.subcategoryName''') ?? '').toString();
      grouped.putIfAbsent(sub.isEmpty ? 'General' : sub, () => []);
      grouped[sub.isEmpty ? 'General' : sub]!.add(q);
    }
    final hasSubjects = grouped.keys.length > 1;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF6F9FF),
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
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
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
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Grid View',
                              style: TextStyle(
                                color: Color(0xFF1F2937),
                                fontSize: 20.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40.0),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 18.0),
                      child: Column(
                        children: [
                          if (!hasSubjects) ...[
                            _buildQuestionGridCard(
                              title: 'Grid View',
                              questions: questions.isEmpty
                                  ? List.generate(
                                      25,
                                      (index) => {'user_answer': 'skipped'},
                                    )
                                  : questions,
                              showSubmitButton: true,
                            ),
                            const SizedBox(height: 12.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text(
                                'Answered: $answeredCount  |  Not Answered: ${notAnsweredCount < 0 ? 0 : notAnsweredCount}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          ..._buildSubjectGridCards(questions),
                          if (hasSubjects) ...[
                            const SizedBox(height: 12.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Text(
                                'Answered: $answeredCount  |  Not Answered: ${notAnsweredCount < 0 ? 0 : notAnsweredCount}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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
