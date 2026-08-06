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
import '/custom_code/utils/html_stripper.dart';
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'quiz_questions_screen_model.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
export 'quiz_questions_screen_model.dart';

class QuizQuestionsScreenWidget extends StatefulWidget {
  const QuizQuestionsScreenWidget({
    super.key,
    this.title,
    this.catId,
    this.image,
    this.quizTime,
    this.description,
    this.ques,
    this.quizID,
    this.timerStatus,
  });

  final String? title;
  final String? catId;
  final String? image;
  final String? quizTime;
  final String? description;
  final int? ques;
  final String? quizID;
  final int? timerStatus;

  static String routeName = 'quiz_questions_screen';
  static String routePath = '/quizQuestionsScreen';

  @override
  State<QuizQuestionsScreenWidget> createState() =>
      _QuizQuestionsScreenWidgetState();
}

class _QuizQuestionsScreenWidgetState extends State<QuizQuestionsScreenWidget>
    with WidgetsBindingObserver {
  late QuizQuestionsScreenModel _model;
  bool _didParseParams = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Translation related state
  late Translation _translation;
  String _selectedLang = 'en';
  String _translatedQuestion = '';
  List<String> _translatedOptions = [];
  bool _isTranslating = false;

  // Track selected option index for each question
  Map<int, int> selectedOptionPerQuestion = {};

  // Add this at the top of the _QuizQuestionsScreenWidgetState class:
  Map<int, String> userAnswersPerQuestion = {};
  bool showBody = false;
  int actualQuizDurationMinutes = 0;
  bool timerStarted = false;
  bool timerInitialized = false;
  bool quizAutoSubmitted = false; // Prevent multiple auto-submits
  final Map<String, Widget> _questionHtmlCache = {};

  // Track app lifecycle state for timer pause/resume
  AppLifecycleState? _lastLifecycleState;
  DateTime? _backgroundTime;

  Future<void> startQuizTimer() async {
    if (timerStarted) {
      return; // Prevent multiple timer starts
    }

    // Extract quiz duration from the API response
    int quizDurationMinutes = 0;
    if (_model.quizRes?.jsonBody != null) {
      final questions = QuizGroup.getquestionsbyquizidApiCall
          .questionDetailsList(_model.quizRes!.jsonBody);
      if (questions is List && questions.isNotEmpty) {
        final quizIdObj = getJsonField(questions[0], r'$.quizId');
        final apiDuration = getJsonField(quizIdObj, r'$.minutes_per_quiz');
        if (apiDuration != null) {
          if (apiDuration is num) {
            quizDurationMinutes = apiDuration.toInt();
          } else if (apiDuration is String) {
            quizDurationMinutes = int.tryParse(apiDuration) ?? 0;
          }
        }
      }
    }

    if (quizDurationMinutes <= 0) {
      return;
    }

    // Update the state variable
    setState(() {
      actualQuizDurationMinutes = quizDurationMinutes;
    });

    try {
      // Only create timer controller if it hasn't been initialized
      if (!timerInitialized) {
        // Safely dispose the old timer controller if it exists and is initialized
        try {
          _model.timerController.dispose();
        } catch (e) {
          // Timer might not be initialized yet, ignore disposal errors
        }

        // Create a new timer controller with the correct initial time
        _model.timerController = FlutterFlowTimerController(
          StopWatchTimer(
            mode: StopWatchMode.countDown,
            presetMillisecond: quizDurationMinutes * 60 * 1000,
          ),
        );
        timerInitialized = true;
      }

      // Start the timer only if it hasn't been started yet
      if (!timerStarted) {
        _model.timerController.onStartTimer();
        timerStarted = true;
      }

      // Force immediate state update
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      timerStarted = false; // Reset flag on error
      timerInitialized = false;
    }
  }

  void _pauseTimer() {
    if (timerStarted && timerInitialized) {
      try {
        _model.timerController.onStopTimer();
      } catch (e) {
      }
    }
  }

  void _resumeTimer() {
    if (timerStarted && timerInitialized) {
      try {
        _model.timerController.onStartTimer();
      } catch (e) {
      }
    }
  }

  String get _elapsedTimeLabel {
    if (!timerInitialized || actualQuizDurationMinutes <= 0) {
      return '';
    }
    try {
      final elapsedMs = actualQuizDurationMinutes * 60 * 1000 -
          _model.timerController.timer.rawTime.value;
      if (elapsedMs < 0) {
        return '';
      }
      final int hours = elapsedMs ~/ 3600000;
      final int minutes = (elapsedMs % 3600000) ~/ 60000;
      final int seconds = (elapsedMs % 60000) ~/ 1000;
      final String mm = minutes.toString().padLeft(2, '0');
      final String ss = seconds.toString().padLeft(2, '0');
      if (hours > 0) {
        return '$hours:$mm:$ss';
      }
      return '$mm:$ss';
    } catch (e) {
      return '';
    }
  }

  String _resolveQuestionHtml(dynamic questionItem) {
    final rawHtml = _selectedLang == 'en'
        ? getJsonField(questionItem, r'''$.question_title''').toString()
        : _translatedQuestion.isNotEmpty
            ? _translatedQuestion
            : getJsonField(questionItem, r'''$.question_title''').toString();
    return rawHtml.replaceAll('&quot;', '"');
  }

  Map<String, Style> _questionHtmlStyle(BuildContext context) {
    final baseTextStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'Roboto',
          fontSize: 18.0,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w400,
          useGoogleFonts: false,
          lineHeight: 1.2,
        );

    final style = Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
      color: FlutterFlowTheme.of(context).primaryText,
      fontFamily: baseTextStyle.fontFamily,
      fontSize: FontSize(baseTextStyle.fontSize ?? 18.0),
      fontWeight: baseTextStyle.fontWeight,
      letterSpacing: baseTextStyle.letterSpacing,
      lineHeight: LineHeight(baseTextStyle.height ?? 1.2),
    );

    return {
      "body": style,
      "p": style,
      "span": style,
    };
  }

  void _invalidateQuestionHtmlCache() {
    _questionHtmlCache.clear();
  }

  Widget _buildQuestionHtmlWidget({
    required BuildContext context,
    required String questionHtml,
    required int questionIndex,
    required String variantKey,
  }) {
    final cacheKey =
        '$questionIndex-$variantKey-$_selectedLang-${questionHtml.hashCode}';
    final cachedWidget = _questionHtmlCache[cacheKey];
    if (cachedWidget != null) {
      return cachedWidget;
    }

    final htmlWidget = Html(
      key: ValueKey('question-html-$cacheKey'),
      data: questionHtml,
      style: _questionHtmlStyle(context),
      onLinkTap: (url, attributes, element) {
        if (url != null) {
          launchURL(url);
        }
      },
    );

    _questionHtmlCache[cacheKey] = htmlWidget;
    return htmlWidget;
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

  Widget _buildScoreChip({
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTimerChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 14.0,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 6.0),
          Text(
            _model.timerValue.isNotEmpty ? _model.timerValue : '00:00',
            style: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizHeader({
    required int totalQuestions,
    required double correctAnsReward,
    required double penaltyPerQuestion,
  }) {
    final currentQuestion = _model.pageViewCurrentIndex + 1;
    final title = widget.title ?? '';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6F9FF), Color(0xFFFFFFFF)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 14.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F7FF),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5ECF7)),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.0),
                      onTap: _showQuitQuizDialog,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 28.0,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  if (widget.image != null && widget.image!.isNotEmpty)
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.image.toString(),
                        width: 32.0,
                        height: 32.0,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 32.0,
                          height: 32.0,
                          color: const Color(0xFFE5E7EB),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE5E7EB),
                          ),
                          child: const Icon(Icons.image_outlined, size: 20.0),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE5E7EB),
                      ),
                      child: const Icon(Icons.school_rounded, size: 16.0),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 8.0),
            child: Row(
              children: [
                _buildScoreChip(
                  label: '$currentQuestion',
                  backgroundColor: const Color(0xFFEEEBFF),
                  textColor: const Color(0xFF4338CA),
                ),
                const SizedBox(width: 10.0),
                _buildScoreChip(
                  label: '+${correctAnsReward.toStringAsFixed(correctAnsReward.truncateToDouble() == correctAnsReward ? 0 : 1)}',
                  backgroundColor: const Color(0xFFEAF8EB),
                  textColor: const Color(0xFF16A34A),
                ),
                const SizedBox(width: 10.0),
                _buildScoreChip(
                  label: '-${penaltyPerQuestion.toStringAsFixed(penaltyPerQuestion.truncateToDouble() == penaltyPerQuestion ? 0 : 2)}',
                  backgroundColor: const Color(0xFFFDEBEC),
                  textColor: const Color(0xFFEF4444),
                ),
                const Spacer(),
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F111827),
                        blurRadius: 12.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final apiQuestions = QuizGroup.getquestionsbyquizidApiCall.questionDetailsList(
                        (_model.quizRes?.jsonBody ?? ''),
                      )?.toList() ?? [];
                      if (apiQuestions.isNotEmpty) {
                        final reviewList = apiQuestions.map((q) {
                          final idx = apiQuestions.indexOf(q);
                          final userAns = userAnswersPerQuestion[idx];
                          return {
                            'question': q,
                            'user_answer': userAns ?? 'skipped',
                            'correct_answer': getJsonField(q, r'''$.answer'''),
                            'subcategoryName': getJsonField(q, r'''$.subcategoryName'''),
                          };
                        }).toList();
                        FFAppState().quesReviewList = reviewList;
                      } else if (FFAppState().quesList.isNotEmpty) {
                        FFAppState().quesReviewList = FFAppState().quesList.toList();
                      }
                      final result = await context.pushNamed<int>(QuizReviewScreenWidget.routeName, queryParameters: {
                        'quizID': serializeParam(widget.quizID, ParamType.String),
                        'title': serializeParam(widget.title, ParamType.String),
                        'correctAnsReward': serializeParam(correctAnsReward, ParamType.double),
                        'penaltyPerQuestion': serializeParam(penaltyPerQuestion, ParamType.double),
                        'quizTime': serializeParam(_elapsedTimeLabel, ParamType.String),
                      }.withoutNulls);
                      if (result != null && _model.pageViewController != null) {
                        _model.pageViewController!.animateToPage(
                          result,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Color(0xFF111827),
                      size: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String label,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF3F7FF) : Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFFE5E7EB),
                width: isSelected ? 1.6 : 1.0,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x143B82F6),
                        blurRadius: 14.0,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF111827),
                    fontSize: 17.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ),
                const SizedBox(width: 14.0),
                Container(
                  width: 1.0,
                  height: 34.0,
                  color: const Color(0xFFE5E7EB),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isPrimary,
    required Color accentColor,
    IconData? leadingIcon,
    IconData? trailingIcon,
  }) {
    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18.0),
          const SizedBox(width: 4.0),
        ],
        Flexible(child: Text(text, overflow: TextOverflow.visible, textAlign: TextAlign.center)),
        if (trailingIcon != null) ...[
          const SizedBox(width: 4.0),
          Icon(trailingIcon, size: 18.0),
        ],
      ],
    );

    if (isPrimary) {
      return SizedBox(
        height: 54.0,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      height: 54.0,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor.withOpacity(0.45)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: buttonChild,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observe app lifecycle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        showBody = true;
      });
    });
    _model = createModel(context, () => QuizQuestionsScreenModel());
    _translation = Translation(
        apiKey:
            'AIzaSyCsrdktiTiJHrsd9n3EZ323XksrqVBIUzw'); // <-- Replace with your API key

    // Initialize timer state (but don't reset if already started)
    if (!timerStarted) {
      timerInitialized = false;
      actualQuizDurationMinutes = 0;
      quizAutoSubmitted = false;
    }

    // On page load action.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Handle background/foreground transitions for timer
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (timerStarted && timerInitialized) {
        _backgroundTime = DateTime.now();
        _pauseTimer();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null && timerStarted && timerInitialized) {
        final timeInMemory = DateTime.now().difference(_backgroundTime!).inMilliseconds;
        _backgroundTime = null;

        // Adjust the timer by subtracting the time spent in background
        if (timeInMemory > 0) {
          try {
            final currentMs = _model.timerController.timer.rawTime.value;
            int newMs = currentMs - timeInMemory;
            
            if (newMs <= 0) {
              newMs = 0;
            }
            
            // Update the timer with the new remaining time
            _model.timerController.timer.setPresetTime(mSec: newMs, add: false);
          } catch (e) {
            // Handle error gracefully
          }
        }
        
        _resumeTimer();
      }
    }
    
    _lastLifecycleState = state;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _translateQuestionAndOptions(
      String question, List<String> options) async {
    setState(() {
      _isTranslating = true;
    });
    final translatedQ =
        await _translation.translate(text: question, to: _selectedLang);
    final translatedOpts = <String>[];
    for (final opt in options) {
      final t = await _translation.translate(text: opt, to: _selectedLang);
      translatedOpts.add(t.translatedText);
    }
    setState(() {
      _translatedQuestion = translatedQ.translatedText;
      _translatedOptions = translatedOpts;
      _isTranslating = false;
      _invalidateQuestionHtmlCache();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
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

    // Set actualQuizDurationMinutes immediately when quiz data is available
    // This ensures timer widget has the correct duration from the start
    if (quizDurationMinutes > 0 && actualQuizDurationMinutes == 0) {
      actualQuizDurationMinutes = quizDurationMinutes;
    }



    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: showBody
            ? Scaffold(
                bottomNavigationBar: Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 40),
                  child: SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                FlutterFlowTheme.of(context).primary,
                            foregroundColor: Colors.white),
                        onPressed: () {
                          setState(() {
                            showBody = false;
                            SchedulerBinding.instance
                                .addPostFrameCallback((_) async {
                              FFAppState().quesIndex =
                                  _model.pageViewCurrentIndex + 1;
                              safeSetState(() {});
                              try {
                                _model.quizRes = await QuizGroup
                                    .getquestionsbyquizidApiCall
                                    .call(
                                  quizId: widget.quizID,
                                  token: FFAppState().loginToken,
                                );
                              } catch (e) {

                              }
                              FFAppState().questionType = getJsonField(
                                (_model.quizRes?.jsonBody ?? ''),
                                r'''$.question_type''',
                              ).toString().toString();
                              safeSetState(() {});
                              _model.isLoading = false;
                              safeSetState(() {});

                              // Start the quiz timer immediately after quiz data is loaded
                              // Start timer right away to ensure it starts on first question
                              if (!timerStarted &&
                                  _model.quizRes?.jsonBody != null) {
                                // Start timer synchronously
                                await startQuizTimer();
                                // Force state update to ensure timer widget rebuilds
                                safeSetState(() {});
                              }

                              await Future.delayed(
                                  const Duration(milliseconds: 1000));
                            });

                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => safeSetState(() {}));
                          });
                        },
                        child: Text('Agree & Continue')),
                  ),
                ),
                body: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            12.0, 8.0, 12.0, 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(22.0),
                                    onTap: () => context.safePop(),
                                    child: Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF5F8FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_rounded,
                                        color: Color(0xFF111827),
                                        size: 22.0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Text(
                                    widget.title ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (widget.image != null && widget.image!.isNotEmpty)
                                  const SizedBox(width: 12.0),
                                if (widget.image != null && widget.image!.isNotEmpty)
                                  Container(
                                    width: 40.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F8FF),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: const EdgeInsets.all(4.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6.0),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.image!,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) => Container(
                                          color: const Color(0xFFF5F8FF),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.image_outlined,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            custom_widgets.HtmlConverterExp(
                              width: double.infinity,
                              height: null,
                              text: widget.description!,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Builder(
                builder: (context) {
                  if (QuizGroup.getquestionsbyquizidApiCall.success(
                        (_model.quizRes?.jsonBody ?? ''),
                      ) ==
                      2) {
                    return Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        child: Text(
                          valueOrDefault<String>(
                            QuizGroup.getquestionsbyquizidApiCall.message(
                              (_model.quizRes?.jsonBody ?? ''),
                            ),
                            'Message',
                          ),
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Roboto',
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w400,
                                    useGoogleFonts: false,
                                    lineHeight: 1.5,
                                  ),
                        ),
                      ),
                    );
                  } else {
                    return Builder(
                      builder: (context) {
                        if (_model.isLoading == false) {
                          return Builder(
                            builder: (context) {
                              if (QuizGroup.getquestionsbyquizidApiCall.success(
                                    (_model.quizRes?.jsonBody ?? ''),
                                  ) ==
                                  1) {
                                // Start timer once when quiz data is loaded (only if not already started)
                                // This is a backup in case timer didn't start in the button callback
                                if (!timerStarted &&
                                    _model.quizRes?.jsonBody != null &&
                                    actualQuizDurationMinutes > 0) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) async {
                                    if (!timerStarted) {
                                      await startQuizTimer();
                                      safeSetState(() {});
                                    }
                                  });
                                }

                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    _buildQuizHeader(
                                      totalQuestions: totalQuestions,
                                      correctAnsReward: correctAnsReward,
                                      penaltyPerQuestion: penaltyPerQuestion,
                                    ),
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  primary: false,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(),
                                                        child: Builder(
                                                          builder: (context) {
                                                            final availableHeight =
                                                                max(
                                                              0.0,
                                                              MediaQuery.sizeOf(
                                                                          context)
                                                                      .height -
                                                                  MediaQuery.of(context)
                                                                      .padding
                                                                      .top -
                                                                  MediaQuery.of(context)
                                                                      .padding
                                                                      .bottom -
                                                                  220.0,
                                                            );
                                                            final categorywisequiz = QuizGroup
                                                                    .getquestionsbyquizidApiCall
                                                                    .questionDetailsList(
                                                                      (_model.quizRes
                                                                              ?.jsonBody ??
                                                                          ''),
                                                                    )
                                                                    ?.toList() ??
                                                                [];

                                                            return SizedBox(
                                                              height:
                                                                  availableHeight,
                                                              width: double
                                                                  .infinity,
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            40.0),
                                                                child: PageView
                                                                    .builder(
                                                                  physics:
                                                                      const NeverScrollableScrollPhysics(),
                                                                  controller: _model
                                                                          .pageViewController ??=
                                                                      PageController(
                                                                          initialPage: max(
                                                                              0,
                                                                              min(0, categorywisequiz.length - 1))),
                                                                  onPageChanged:
                                                                      (idx) async {
                                                                    FFAppState()
                                                                            .selectedColorIndex =
                                                                        selectedOptionPerQuestion[idx] ??
                                                                            -1;
                                                                    FFAppState()
                                                                        .update(
                                                                            () {});
                                                                    FFAppState()
                                                                            .questionType =
                                                                        getJsonField(
                                                                      categorywisequiz
                                                                          .elementAtOrNull(
                                                                              idx),
                                                                      r'''$.question_type''',
                                                                    ).toString();
                                                                    safeSetState(
                                                                        () {});
                                                                  },
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  itemCount:
                                                                      categorywisequiz
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          categorywisequizIndex) {
                                                                    final categorywisequizItem =
                                                                        categorywisequiz[
                                                                            categorywisequizIndex];
                                                                    final selectedIndex =
                                                                        selectedOptionPerQuestion[
                                                                            categorywisequizIndex];
                                                                    // At the top of the builder function for image-based questions:
                                                                    final optionA =
                                                                        getJsonField(
                                                                            categorywisequizItem,
                                                                            r'''$.option.a''');
                                                                    final optionB =
                                                                        getJsonField(
                                                                            categorywisequizItem,
                                                                            r'''$.option.b''');
                                                                    final optionC =
                                                                        getJsonField(
                                                                            categorywisequizItem,
                                                                            r'''$.option.c''');
                                                                    final optionD =
                                                                        getJsonField(
                                                                            categorywisequizItem,
                                                                            r'''$.option.d''');

                                                                    String extractOptionText(
                                                                        dynamic
                                                                            option) {
                                                                      if (option
                                                                              is Map &&
                                                                          option['text']
                                                                              is String) {
                                                                        return option[
                                                                            'text'];
                                                                      } else if (option
                                                                              is Map &&
                                                                          option['text']
                                                                              is Map &&
                                                                          option['text']['text']
                                                                              is String) {
                                                                        return option['text']
                                                                            [
                                                                            'text'];
                                                                      }
                                                                      return '';
                                                                    }

                                                                    final optionAImage = (optionA
                                                                                is Map &&
                                                                            optionA['image'] !=
                                                                                null)
                                                                        ? optionA['image']
                                                                            .toString()
                                                                        : '';
                                                                    final optionAText =
                                                                        extractOptionText(
                                                                            optionA);
                                                                    final optionBImage = (optionB
                                                                                is Map &&
                                                                            optionB['image'] !=
                                                                                null)
                                                                        ? optionB['image']
                                                                            .toString()
                                                                        : '';
                                                                    final optionBText =
                                                                        extractOptionText(
                                                                            optionB);
                                                                    final optionCImage = (optionC
                                                                                is Map &&
                                                                            optionC['image'] !=
                                                                                null)
                                                                        ? optionC['image']
                                                                            .toString()
                                                                        : '';
                                                                    final optionCText =
                                                                        extractOptionText(
                                                                            optionC);
                                                                    final optionDImage = (optionD
                                                                                is Map &&
                                                                            optionD['image'] !=
                                                                                null)
                                                                        ? optionD['image']
                                                                            .toString()
                                                                        : '';
                                                                    final optionDText =
                                                                        extractOptionText(
                                                                            optionD);
                                                                    final questionHtml =
                                                                        _resolveQuestionHtml(
                                                                            categorywisequizItem);
                                                                    return Builder(
                                                                      builder:
                                                                          (context) {
                                                                        if ('${getJsonField(
                                                                              categorywisequizItem,
                                                                              r'''$.question_type''',
                                                                            ).toString()}' ==
                                                                            'text_only') {
                                                                          return Container(
                                                                            decoration:
                                                                                BoxDecoration(),
                                                                            child:
                                                                                Padding(
                                                                              padding: EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 0.0),
                                                                              child: SingleChildScrollView(
                                                                                physics: const ClampingScrollPhysics(),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                  /// question widget
                                                                                  Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 18.0),
                                                                                    child: _buildQuestionHtmlWidget(
                                                                                      context: context,
                                                                                      questionHtml: questionHtml,
                                                                                      questionIndex: categorywisequizIndex,
                                                                                      variantKey: 'text',
                                                                                    ),
                                                                                  ),
                                                                                  if (timerStatus == 1)
                                                                                    Align(
                                                                                      alignment: AlignmentDirectional(1.0, 0.0),
                                                                                      child: Padding(
                                                                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 18.0),
                                                                                        child: Stack(
                                                                                          alignment: Alignment.center,
                                                                                          children: [
                                                                                            _buildTimerChip(),
                                                                                            if (timerInitialized && actualQuizDurationMinutes > 0)
                                                                                              Opacity(
                                                                                                opacity: 0.0,
                                                                                                child: SizedBox(
                                                                                                  width: 110.0,
                                                                                                  height: 40.0,
                                                                                                  child: FlutterFlowTimer(
                                                                                                    key: const ValueKey('quiz-timer-main'),
                                                                                                    initialTime: actualQuizDurationMinutes * 60 * 1000,
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
                                                                                                          color: Colors.transparent,
                                                                                                          fontSize: 16.0,
                                                                                                          useGoogleFonts: false,
                                                                                                        ),
                                                                                                    onEnded: () async {
                                                                                                      if (quizAutoSubmitted) {
                                                                                                        return;
                                                                                                      }

                                                                                                      quizAutoSubmitted = true;

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
                                                                                                                      'quizTime': serializeParam(_elapsedTimeLabel, ParamType.String),
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
                                                                                              ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  _buildOptionTile(
                                                                                    label: 'A',
                                                                                    text: _selectedLang == 'en' ? optionAText : (_translatedOptions.isNotEmpty ? _translatedOptions[0] : optionAText),
                                                                                    isSelected: selectedIndex == 0,
                                                                                    onTap: () async {
                                                                                        if (selectedIndex == 0) {
                                                                                          _model.userAnswer = null;
                                                                                          _model.actualAnswer = null;
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = -1;
                                                                                          FFAppState().selectedColorIndex = -1;
                                                                                          userAnswersPerQuestion[_model.pageViewCurrentIndex] = 'skipped';
                                                                                        } else {
                                                                                          _model.userAnswer = getJsonField(categorywisequizItem, r'''$.option.a''').toString();
                                                                                          _model.actualAnswer = getJsonField(categorywisequizItem, r'''$.answer''').toString();
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = 0;
                                                                                          FFAppState().selectedColorIndex = 0;
                                                                                          userAnswersPerQuestion[_model.pageViewCurrentIndex] = 'a';
                                                                                        }
                                                                                        safeSetState(() {});
                                                                                        FFAppState().update(() {});
                                                                                      },
                                                                                  ),
                                                                                  _buildOptionTile(
                                                                                    label: 'B',
                                                                                    text: _selectedLang == 'en' ? optionBText : (_translatedOptions.isNotEmpty ? _translatedOptions[1] : optionBText),
                                                                                    isSelected: selectedIndex == 1,
                                                                                    onTap: () async {
                                                                                      if (selectedIndex == 1) {
                                                                                        _model.userAnswer = null;
                                                                                        _model.actualAnswer = null;
                                                                                        selectedOptionPerQuestion[categorywisequizIndex] = -1;
                                                                                        FFAppState().selectedColorIndex = -1;
                                                                                        userAnswersPerQuestion[_model.pageViewCurrentIndex] = 'skipped';
                                                                                      } else {
                                                                                        _model.userAnswer = getJsonField(categorywisequizItem, r'''$.option.b''').toString();
                                                                                        _model.actualAnswer = getJsonField(categorywisequizItem, r'''$.answer''').toString();
                                                                                        selectedOptionPerQuestion[categorywisequizIndex] = 1;
                                                                                        FFAppState().selectedColorIndex = 1;
                                                                                        userAnswersPerQuestion[_model.pageViewCurrentIndex] = 'b';
                                                                                      }
                                                                                      safeSetState(() {});
                                                                                      FFAppState().update(() {});
                                                                                    },
                                                                                  ),
                                                                                  _buildOptionTile(
                                                                                    label: 'C',
                                                                                    text: _selectedLang == 'en' ? optionCText : (_translatedOptions.isNotEmpty ? _translatedOptions[2] : optionCText),
                                                                                    isSelected: selectedIndex == 2,
                                                                                    onTap: () async {
                                                                                        if (selectedIndex == 2) {
                                                                                          _model.userAnswer = null;
                                                                                          _model.actualAnswer = null;
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = -1;
                                                                                          FFAppState().selectedColorIndex = -1;
                                                                                          userAnswersPerQuestion[_model.pageViewCurrentIndex] = 'skipped';
                                                                                        } else {
                                                                                          _model.userAnswer = getJsonField(categorywisequizItem, r'''$.option.c''').toString();
                                                                                          _model.actualAnswer = getJsonField(categorywisequizItem, r'''$.answer''').toString();
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = 2;
                                                                                          FFAppState().selectedColorIndex = 2;
                                                                                          userAnswersPerQuestion[_model.pageViewCurrentIndex] = 'c';
                                                                                        }
                                                                                        safeSetState(() {});
                                                                                        FFAppState().update(() {});
                                                                                      },
                                                                                  ),
                                                                                  _buildOptionTile(
                                                                                    label: 'D',
                                                                                    text: _selectedLang == 'en' ? optionDText : (_translatedOptions.isNotEmpty ? _translatedOptions[3] : optionDText),
                                                                                    isSelected: selectedIndex == 3,
                                                                                    onTap: () async {
                                                                                      if (selectedIndex == 3) {
                                                                                        _model.userAnswer = null;
                                                                                        _model.actualAnswer = null;
                                                                                        selectedOptionPerQuestion[categorywisequizIndex] = -1;
                                                                                        FFAppState().selectedColorIndex = -1;
                                                                                        userAnswersPerQuestion[_model.pageViewCurrentIndex] = 'skipped';
                                                                                      } else {
                                                                                        _model.userAnswer = getJsonField(categorywisequizItem, r'''$.option.d''').toString();
                                                                                        _model.actualAnswer = getJsonField(categorywisequizItem, r'''$.answer''').toString();
                                                                                        selectedOptionPerQuestion[categorywisequizIndex] = 3;
                                                                                        FFAppState().selectedColorIndex = 3;
                                                                                        userAnswersPerQuestion[_model.pageViewCurrentIndex] = 'd';
                                                                                      }
                                                                                      safeSetState(() {});
                                                                                      FFAppState().update(() {});
                                                                                    },
                                                                                  ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        } else if ('${getJsonField(
                                                                              categorywisequizItem,
                                                                              r'''$.question_type''',
                                                                            ).toString()}' ==
                                                                            'true_false') {
                                                                          return Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                16.0,
                                                                                50.0,
                                                                                16.0,
                                                                                20.0),
                                                                            child:
                                                                                Container(
                                                                              width: double.infinity,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                borderRadius: BorderRadius.circular(16.0),
                                                                              ),
                                                                              alignment: AlignmentDirectional(0.0, -1.0),
                                                                              child: SingleChildScrollView(
                                                                                physics: const ClampingScrollPhysics(),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                  Align(
                                                                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                                                                                      child: _buildQuestionHtmlWidget(
                                                                                        context: context,
                                                                                        questionHtml: questionHtml,
                                                                                        questionIndex: categorywisequizIndex,
                                                                                        variantKey: 'boolean',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                                                                    child: InkWell(
                                                                                      splashColor: Colors.transparent,
                                                                                      focusColor: Colors.transparent,
                                                                                      hoverColor: Colors.transparent,
                                                                                      highlightColor: Colors.transparent,
                                                                                      onTap: () async {
                                                                                        if (selectedIndex == 0) {
                                                                                          // Deselect if already selected
                                                                                          _model.userAnswer = null;
                                                                                          _model.actualAnswer = null;
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = -1;
                                                                                          FFAppState().selectedColorIndex = -1;
                                                                                        } else {
                                                                                          _model.userAnswer = 'True';
                                                                                          _model.actualAnswer = getJsonField(
                                                                                            categorywisequizItem,
                                                                                            r'''$.answer''',
                                                                                          ).toString();
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = 0;
                                                                                          FFAppState().selectedColorIndex = 0;
                                                                                        }
                                                                                        safeSetState(() {});
                                                                                        FFAppState().update(() {});
                                                                                      },
                                                                                      child: Container(
                                                                                        width: 369.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: FlutterFlowTheme.of(context).grey,
                                                                                          borderRadius: BorderRadius.circular(12.0),
                                                                                          border: selectedIndex == 0 ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0) : null,
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
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                                                                    child: InkWell(
                                                                                      splashColor: Colors.transparent,
                                                                                      focusColor: Colors.transparent,
                                                                                      hoverColor: Colors.transparent,
                                                                                      highlightColor: Colors.transparent,
                                                                                      onTap: () async {
                                                                                        if (selectedIndex == 1) {
                                                                                          // Deselect if already selected
                                                                                          _model.userAnswer = null;
                                                                                          _model.actualAnswer = null;
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = -1;
                                                                                          FFAppState().selectedColorIndex = -1;
                                                                                        } else {
                                                                                          _model.userAnswer = 'False';
                                                                                          _model.actualAnswer = getJsonField(
                                                                                            categorywisequizItem,
                                                                                            r'''$.answer''',
                                                                                          ).toString();
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = 1;
                                                                                          FFAppState().selectedColorIndex = 1;
                                                                                        }
                                                                                        safeSetState(() {});
                                                                                        FFAppState().update(() {});
                                                                                      },
                                                                                      child: Container(
                                                                                        width: 369.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: FlutterFlowTheme.of(context).grey,
                                                                                          borderRadius: BorderRadius.circular(12.0),
                                                                                          border: selectedIndex == 1 ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0) : null,
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
                                                                            ),
                                                                          );
                                                                        } else if ('${getJsonField(
                                                                              categorywisequizItem,
                                                                              r'''$.question_type''',
                                                                            ).toString()}' ==
                                                                            'images') {
                                                                          return Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                16.0,
                                                                                50.0,
                                                                                16.0,
                                                                                20.0),
                                                                            child:
                                                                                Container(
                                                                              width: double.infinity,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                borderRadius: BorderRadius.circular(16.0),
                                                                              ),
                                                                              alignment: AlignmentDirectional(0.0, -1.0),
                                                                              child: SingleChildScrollView(
                                                                                physics: const ClampingScrollPhysics(),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                  Align(
                                                                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                                                                      child: _buildQuestionHtmlWidget(
                                                                                        context: context,
                                                                                        questionHtml: questionHtml,
                                                                                        questionIndex: categorywisequizIndex,
                                                                                        variantKey: 'image',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  // Timer for image-based questions
                                                                                  Align(
                                                                                    alignment: AlignmentDirectional(1.0, 0.0),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                                                                      child: Container(
                                                                                        width: 100.0,
                                                                                        height: 34.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: FlutterFlowTheme.of(context).primary,
                                                                                          borderRadius: BorderRadius.circular(20.0),
                                                                                        ),
                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                        child: FlutterFlowTimer(
                                                                                          key: const ValueKey('quiz-timer-image'),
                                                                                          initialTime: actualQuizDurationMinutes * 60 * 1000,
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
                                                                                            // Prevent multiple auto-submits
                                                                                            if (quizAutoSubmitted) {
                                                                                              return;
                                                                                            }

                                                                                            quizAutoSubmitted = true;

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
                                                                                                            'quizTime': serializeParam(_elapsedTimeLabel, ParamType.String),
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
                                                                                    ),
                                                                                  ),
                                                                                  if (getJsonField(
                                                                                            categorywisequizItem,
                                                                                            r'''$.image''',
                                                                                          ) !=
                                                                                          null &&
                                                                                      getJsonField(
                                                                                        categorywisequizItem,
                                                                                        r'''$.image''',
                                                                                      ).toString().isNotEmpty)
                                                                                    Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                                                                                      child: Center(
                                                                                        child: Container(
                                                                                          width: double.infinity,
                                                                                          constraints: BoxConstraints(
                                                                                            maxWidth: MediaQuery.of(context).size.width - 32.0,
                                                                                            maxHeight: 300.0,
                                                                                          ),
                                                                                          child: ClipRRect(
                                                                                            borderRadius: BorderRadius.circular(12.0),
                                                                                            child: CachedNetworkImage(
                                                                                              fadeInDuration: Duration(milliseconds: 500),
                                                                                              fadeOutDuration: Duration(milliseconds: 500),
                                                                                              imageUrl: '${FFAppConstants.imageBaseURL}${getJsonField(
                                                                                                categorywisequizItem,
                                                                                                r'''$.image''',
                                                                                              ).toString()}',
                                                                                              width: double.infinity,
                                                                                              fit: BoxFit.contain,
                                                                                              alignment: Alignment(0.0, 0.0),
                                                                                              placeholder: (context, url) => Center(
                                                                                                child: Padding(
                                                                                                  padding: EdgeInsets.all(20.0),
                                                                                                  child: CircularProgressIndicator(
                                                                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                                                                      FlutterFlowTheme.of(context).primary,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              errorWidget: (context, url, error) => Container(
                                                                                                width: double.infinity,
                                                                                                height: 200.0,
                                                                                                decoration: BoxDecoration(
                                                                                                  color: FlutterFlowTheme.of(context).alternate,
                                                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                                                ),
                                                                                                child: Icon(
                                                                                                  Icons.error_outline,
                                                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                                                  size: 48.0,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  // For image-based questions, extract option images and texts as strings:
                                                                                  Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                                                                                    child: Wrap(
                                                                                      spacing: 16.0,
                                                                                      runSpacing: 16.0,
                                                                                      children: [
                                                                                        SizedBox(
                                                                                          width: (MediaQuery.of(context).size.width - 64) / 2, // 16 padding on each side + 16 spacing
                                                                                          child: GestureDetector(
                                                                                            onTap: () {
                                                                                              _model.userAnswer = 'a';
                                                                                              _model.actualAnswer = getJsonField(categorywisequizItem, r'''$.answer''').toString();
                                                                                              selectedOptionPerQuestion[categorywisequizIndex] = 0;
                                                                                              FFAppState().selectedColorIndex = 0;
                                                                                              userAnswersPerQuestion[_model.pageViewCurrentIndex] = _model.userAnswer ?? '';
                                                                                              safeSetState(() {});
                                                                                              FFAppState().update(() {});
                                                                                            },
                                                                                            child: Container(
                                                                                              decoration: BoxDecoration(
                                                                                                border: selectedIndex == 0 ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0) : null,
                                                                                                borderRadius: BorderRadius.circular(12.0),
                                                                                              ),
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  if (optionAImage.isNotEmpty)
                                                                                                    CachedNetworkImage(
                                                                                                      imageUrl: '${FFAppConstants.imageBaseURL}${optionAImage}',
                                                                                                      width: 80,
                                                                                                      height: 80,
                                                                                                      fit: BoxFit.contain,
                                                                                                    ),
                                                                                                  Text(optionAText),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: (MediaQuery.of(context).size.width - 64) / 2,
                                                                                          child: GestureDetector(
                                                                                            onTap: () {
                                                                                              _model.userAnswer = 'b';
                                                                                              _model.actualAnswer = getJsonField(categorywisequizItem, r'''$.answer''').toString();
                                                                                              selectedOptionPerQuestion[categorywisequizIndex] = 1;
                                                                                              FFAppState().selectedColorIndex = 1;
                                                                                              userAnswersPerQuestion[_model.pageViewCurrentIndex] = _model.userAnswer ?? '';
                                                                                              safeSetState(() {});
                                                                                              FFAppState().update(() {});
                                                                                            },
                                                                                            child: Container(
                                                                                              decoration: BoxDecoration(
                                                                                                border: selectedIndex == 1 ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0) : null,
                                                                                                borderRadius: BorderRadius.circular(12.0),
                                                                                              ),
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  if (optionBImage.isNotEmpty)
                                                                                                    CachedNetworkImage(
                                                                                                      imageUrl: '${FFAppConstants.imageBaseURL}${optionBImage}',
                                                                                                      width: 80,
                                                                                                      height: 80,
                                                                                                      fit: BoxFit.contain,
                                                                                                    ),
                                                                                                  Text(optionBText),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: (MediaQuery.of(context).size.width - 64) / 2,
                                                                                          child: GestureDetector(
                                                                                            onTap: () {
                                                                                              _model.userAnswer = 'c';
                                                                                              _model.actualAnswer = getJsonField(categorywisequizItem, r'''$.answer''').toString();
                                                                                              selectedOptionPerQuestion[categorywisequizIndex] = 2;
                                                                                              FFAppState().selectedColorIndex = 2;
                                                                                              userAnswersPerQuestion[_model.pageViewCurrentIndex] = _model.userAnswer ?? '';
                                                                                              safeSetState(() {});
                                                                                              FFAppState().update(() {});
                                                                                            },
                                                                                            child: Container(
                                                                                              decoration: BoxDecoration(
                                                                                                border: selectedIndex == 2 ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0) : null,
                                                                                                borderRadius: BorderRadius.circular(12.0),
                                                                                              ),
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  if (optionCImage.isNotEmpty)
                                                                                                    CachedNetworkImage(
                                                                                                      imageUrl: '${FFAppConstants.imageBaseURL}${optionCImage}',
                                                                                                      width: 80,
                                                                                                      height: 80,
                                                                                                      fit: BoxFit.contain,
                                                                                                    ),
                                                                                                  Text(optionCText),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: (MediaQuery.of(context).size.width - 64) / 2,
                                                                                          child: GestureDetector(
                                                                                            onTap: () {
                                                                                              _model.userAnswer = 'd';
                                                                                              _model.actualAnswer = getJsonField(categorywisequizItem, r'''$.answer''').toString();
                                                                                              selectedOptionPerQuestion[categorywisequizIndex] = 3;
                                                                                              FFAppState().selectedColorIndex = 3;
                                                                                              userAnswersPerQuestion[_model.pageViewCurrentIndex] = _model.userAnswer ?? '';
                                                                                              safeSetState(() {});
                                                                                              FFAppState().update(() {});
                                                                                            },
                                                                                            child: Container(
                                                                                              decoration: BoxDecoration(
                                                                                                border: selectedIndex == 3 ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0) : null,
                                                                                                borderRadius: BorderRadius.circular(12.0),
                                                                                              ),
                                                                                              child: Column(
                                                                                                children: [
                                                                                                  if (optionDImage.isNotEmpty)
                                                                                                    CachedNetworkImage(
                                                                                                      imageUrl: '${FFAppConstants.imageBaseURL}${optionDImage}',
                                                                                                      width: 80,
                                                                                                      height: 80,
                                                                                                      fit: BoxFit.contain,
                                                                                                    ),
                                                                                                  Text(optionDText),
                                                                                                ],
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
                                                                            ),
                                                                          );
                                                                        } else if ('${getJsonField(
                                                                              categorywisequizItem,
                                                                              r'''$.question_type''',
                                                                            ).toString()}' ==
                                                                            'audio') {
                                                                          // Extract option variables for audio questions
                                                                          final optionA = getJsonField(
                                                                              categorywisequizItem,
                                                                              r'''$.option.a''');
                                                                          final optionB = getJsonField(
                                                                              categorywisequizItem,
                                                                              r'''$.option.b''');
                                                                          final optionC = getJsonField(
                                                                              categorywisequizItem,
                                                                              r'''$.option.c''');
                                                                          final optionD = getJsonField(
                                                                              categorywisequizItem,
                                                                              r'''$.option.d''');

                                                                          String
                                                                              extractOptionText(dynamic option) {
                                                                            if (option is Map &&
                                                                                option['text'] is String) {
                                                                              return option['text'];
                                                                            } else if (option is Map && option['text'] is Map && option['text']['text'] is String) {
                                                                              return option['text']['text'];
                                                                            }
                                                                            return '';
                                                                          }

                                                                          final optionAText =
                                                                              extractOptionText(optionA);
                                                                          final optionBText =
                                                                              extractOptionText(optionB);
                                                                          final optionCText =
                                                                              extractOptionText(optionC);
                                                                          final optionDText =
                                                                              extractOptionText(optionD);
                                                                          final questionHtml =
                                                                              _resolveQuestionHtml(categorywisequizItem);
                                                                          final selectedIndex =
                                                                              selectedOptionPerQuestion[categorywisequizIndex];

                                                                          return Padding(
                                                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                                                16.0,
                                                                                50.0,
                                                                                16.0,
                                                                                20.0),
                                                                            child:
                                                                                Container(
                                                                              width: double.infinity,
                                                                              decoration: BoxDecoration(
                                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                borderRadius: BorderRadius.circular(16.0),
                                                                              ),
                                                                              alignment: AlignmentDirectional(0.0, -1.0),
                                                                              child: SingleChildScrollView(
                                                                                physics: const ClampingScrollPhysics(),
                                                                                child: Column(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                  Align(
                                                                                    alignment: AlignmentDirectional(-1.0, 0.0),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                                                                                      child: _buildQuestionHtmlWidget(
                                                                                        context: context,
                                                                                        questionHtml: questionHtml,
                                                                                        questionIndex: categorywisequizIndex,
                                                                                        variantKey: 'audio',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                                                                                    child: FlutterFlowAudioPlayer(
                                                                                      audio: Audio.network(
                                                                                        getJsonField(
                                                                                                  categorywisequizItem,
                                                                                                  r'''$.audio''',
                                                                                                ) !=
                                                                                                null
                                                                                            ? '${FFAppConstants.imageBaseURL}${getJsonField(
                                                                                                categorywisequizItem,
                                                                                                r'''$.audio''',
                                                                                              ).toString()}'
                                                                                            : 'https://filesamples.com/samples/audio/mp3/sample3.mp3',
                                                                                        metas: Metas(
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
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                                                                    child: InkWell(
                                                                                      splashColor: Colors.transparent,
                                                                                      focusColor: Colors.transparent,
                                                                                      hoverColor: Colors.transparent,
                                                                                      highlightColor: Colors.transparent,
                                                                                      onTap: () async {
                                                                                        if (selectedIndex == 0) {
                                                                                          // Deselect if already selected
                                                                                          _model.userAnswer = null;
                                                                                          _model.actualAnswer = null;
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = -1;
                                                                                          FFAppState().selectedColorIndex = -1;
                                                                                        } else {
                                                                                          _model.userAnswer = getJsonField(
                                                                                            categorywisequizItem,
                                                                                            r'''$.option.a''',
                                                                                          ).toString();
                                                                                          _model.actualAnswer = getJsonField(
                                                                                            categorywisequizItem,
                                                                                            r'''$.answer''',
                                                                                          ).toString();
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = 0;
                                                                                          FFAppState().selectedColorIndex = 0;
                                                                                        }
                                                                                        safeSetState(() {});
                                                                                        FFAppState().update(() {});
                                                                                      },
                                                                                      child: Container(
                                                                                        width: 369.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: FlutterFlowTheme.of(context).grey,
                                                                                          borderRadius: BorderRadius.circular(12.0),
                                                                                          border: selectedIndex == 0 ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0) : null,
                                                                                        ),
                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                        child: Align(
                                                                                          alignment: AlignmentDirectional(0.0, 0.0),
                                                                                          child: Padding(
                                                                                            padding: EdgeInsets.all(16.0),
                                                                                            child: Text(
                                                                                              _selectedLang == 'en' ? optionAText : (_translatedOptions.isNotEmpty ? _translatedOptions[0] : optionAText),
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
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                                                                    child: InkWell(
                                                                                      splashColor: Colors.transparent,
                                                                                      focusColor: Colors.transparent,
                                                                                      hoverColor: Colors.transparent,
                                                                                      highlightColor: Colors.transparent,
                                                                                      onTap: () async {
                                                                                        if (selectedIndex == 1) {
                                                                                          // Deselect if already selected
                                                                                          _model.userAnswer = null;
                                                                                          _model.actualAnswer = null;
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = -1;
                                                                                          FFAppState().selectedColorIndex = -1;
                                                                                        } else {
                                                                                          _model.userAnswer = getJsonField(
                                                                                            categorywisequizItem,
                                                                                            r'''$.option.b''',
                                                                                          ).toString();
                                                                                          _model.actualAnswer = getJsonField(
                                                                                            categorywisequizItem,
                                                                                            r'''$.answer''',
                                                                                          ).toString();
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = 1;
                                                                                          FFAppState().selectedColorIndex = 1;
                                                                                        }
                                                                                        safeSetState(() {});
                                                                                        FFAppState().update(() {});
                                                                                      },
                                                                                      child: Container(
                                                                                        width: 369.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: FlutterFlowTheme.of(context).grey,
                                                                                          borderRadius: BorderRadius.circular(12.0),
                                                                                          border: selectedIndex == 1 ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0) : null,
                                                                                        ),
                                                                                        child: Align(
                                                                                          alignment: AlignmentDirectional(0.0, 0.0),
                                                                                          child: Padding(
                                                                                            padding: EdgeInsets.all(16.0),
                                                                                            child: Text(
                                                                                              _selectedLang == 'en' ? optionBText : (_translatedOptions.isNotEmpty ? _translatedOptions[1] : optionBText),
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
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                                                                    child: InkWell(
                                                                                      splashColor: Colors.transparent,
                                                                                      focusColor: Colors.transparent,
                                                                                      hoverColor: Colors.transparent,
                                                                                      highlightColor: Colors.transparent,
                                                                                      onTap: () async {
                                                                                        if (selectedIndex == 2) {
                                                                                          // Deselect if already selected
                                                                                          _model.userAnswer = null;
                                                                                          _model.actualAnswer = null;
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = -1;
                                                                                          FFAppState().selectedColorIndex = -1;
                                                                                        } else {
                                                                                          _model.userAnswer = getJsonField(
                                                                                            categorywisequizItem,
                                                                                            r'''$.option.c''',
                                                                                          ).toString();
                                                                                          _model.actualAnswer = getJsonField(
                                                                                            categorywisequizItem,
                                                                                            r'''$.answer''',
                                                                                          ).toString();
                                                                                          selectedOptionPerQuestion[categorywisequizIndex] = 2;
                                                                                          FFAppState().selectedColorIndex = 2;
                                                                                        }
                                                                                        safeSetState(() {});
                                                                                        FFAppState().update(() {});
                                                                                      },
                                                                                      child: Container(
                                                                                        width: 369.0,
                                                                                        decoration: BoxDecoration(
                                                                                          color: FlutterFlowTheme.of(context).grey,
                                                                                          borderRadius: BorderRadius.circular(12.0),
                                                                                          border: selectedIndex == 2 ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0) : null,
                                                                                        ),
                                                                                        child: Align(
                                                                                          alignment: AlignmentDirectional(0.0, 0.0),
                                                                                          child: Padding(
                                                                                            padding: EdgeInsets.all(16.0),
                                                                                            child: Text(
                                                                                              _selectedLang == 'en' ? optionCText : (_translatedOptions.isNotEmpty ? _translatedOptions[2] : optionCText),
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
                                                                                    splashColor: Colors.transparent,
                                                                                    focusColor: Colors.transparent,
                                                                                    hoverColor: Colors.transparent,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: () async {
                                                                                      if (selectedIndex == 3) {
                                                                                        // Deselect if already selected
                                                                                        _model.userAnswer = null;
                                                                                        _model.actualAnswer = null;
                                                                                        selectedOptionPerQuestion[categorywisequizIndex] = -1;
                                                                                        FFAppState().selectedColorIndex = -1;
                                                                                      } else {
                                                                                        _model.userAnswer = getJsonField(
                                                                                          categorywisequizItem,
                                                                                          r'''$.option.d''',
                                                                                        ).toString();
                                                                                        _model.actualAnswer = getJsonField(
                                                                                          categorywisequizItem,
                                                                                          r'''$.answer''',
                                                                                        ).toString();
                                                                                        selectedOptionPerQuestion[categorywisequizIndex] = 3;
                                                                                        FFAppState().selectedColorIndex = 3;
                                                                                      }
                                                                                      safeSetState(() {});
                                                                                      FFAppState().update(() {});
                                                                                    },
                                                                                    child: Container(
                                                                                      width: 369.0,
                                                                                      decoration: BoxDecoration(
                                                                                        color: FlutterFlowTheme.of(context).grey,
                                                                                        borderRadius: BorderRadius.circular(12.0),
                                                                                        border: selectedIndex == 3 ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0) : null,
                                                                                      ),
                                                                                      child: Align(
                                                                                        alignment: AlignmentDirectional(0.0, 0.0),
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(16.0),
                                                                                          child: Text(
                                                                                            _selectedLang == 'en' ? optionDText : (_translatedOptions.isNotEmpty ? _translatedOptions[3] : optionDText),
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
                                                                            ),
                                                                          );
                                                                        } else {
                                                                          return Container(
                                                                            width:
                                                                                100.0,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: FlutterFlowTheme.of(context).secondaryBackground,
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
                                              ),
                                              Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(20.0,
                                                                  12.0, 20.0,
                                                                  28.0),
                                                      child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                              // Back Button
                                                              Expanded(
                                                                child:
                                                                    _buildFooterButton(
                                                                  onPressed:
                                                                      () async {
                                                                    if (_model
                                                                            .pageViewCurrentIndex >
                                                                        0) {
                                                                      await _model
                                                                          .pageViewController
                                                                          ?.previousPage(
                                                                        duration: Duration(
                                                                            milliseconds:
                                                                                300),
                                                                        curve: Curves
                                                                            .ease,
                                                                      );
                                                                      FFAppState()
                                                                              .quesIndex =
                                                                          _model
                                                                              .pageViewCurrentIndex;
                                                                      safeSetState(
                                                                          () {});

                                                                      // Timer should continue running when navigating between questions
                                                                      // Do not reset timer state on navigation
                                                                    }
                                                                  },
                                                                  text: 'Back',
                                                                  isPrimary: false,
                                                                  accentColor:
                                                                      const Color(
                                                                          0xFFA855F7),
                                                                  leadingIcon:
                                                                      Icons
                                                                          .arrow_back_rounded,
                                                                ),
                                                              ),

                                                              SizedBox(width: 8.0),
                                                              // Skip Button
                                                              Expanded(
                                                                child:
                                                                    _buildFooterButton(
                                                                  onPressed:
                                                                      () async {
                                                                    // Skip logic: go to next question without saving answer
                                                                    if ((_model.pageViewController !=
                                                                            null) &&
                                                                        ((QuizGroup.getquestionsbyquizidApiCall.questionDetailsList((_model.quizRes?.jsonBody ?? ''))?.length ??
                                                                                0) !=
                                                                            (_model.pageViewCurrentIndex +
                                                                                1))) {
                                                                      await _model
                                                                          .pageViewController
                                                                          ?.nextPage(
                                                                       duration: Duration(
                                                                           milliseconds:
                                                                               300),
                                                                       curve: Curves
                                                                           .ease,
                                                                     );
                                                                     FFAppState()
                                                                             .quesIndex =
                                                                         _model.pageViewCurrentIndex +
                                                                             1;
                                                                     safeSetState(
                                                                         () {});
                                                                     FFAppState()
                                                                         .selectedColorIndex = -1;
                                                                     safeSetState(
                                                                         () {});
                                                                     _model.userAnswer =
                                                                         null;
                                                                     _model.actualAnswer =
                                                                         null;
                                                                     safeSetState(
                                                                         () {});
                                                                   }
                                                                 },
                                                                  text: 'Skip',
                                                                 isPrimary: false,
                                                                 accentColor:
                                                                     const Color(
                                                                         0xFF22C55E),
                                                               ),
                                                              ),

                                                              SizedBox(width: 8.0),
                                                              // Save & Next Button
                                                              Expanded(
                                                               child:
                                                                   _buildFooterButton(
                                                                onPressed:
                                                                    () async {
                                                                  // First, process the answer for the current question
                                                                  // Get the user's selected option key
                                                                  final userSelectedKey =
                                                                      userAnswersPerQuestion[
                                                                          _model
                                                                              .pageViewCurrentIndex];

                                                                  if (userSelectedKey !=
                                                                          null &&
                                                                      userSelectedKey !=
                                                                          'skipped') {
                                                                    // Helper function to normalize answer for comparison
                                                                    String normalizeAnswer(
                                                                        dynamic
                                                                            answer) {
                                                                      if (answer ==
                                                                          null)
                                                                        return '';
                                                                      String answerStr = answer
                                                                          .toString()
                                                                          .trim()
                                                                          .toLowerCase();
                                                                      return answerStr;
                                                                    }

                                                                    // Get the current question and correct answer
                                                                    final currentQuestion = QuizGroup
                                                                        .getquestionsbyquizidApiCall
                                                                        .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                            ''))
                                                                        ?.elementAtOrNull(
                                                                            _model.pageViewCurrentIndex);
                                                                    final correctAnswer =
                                                                        getJsonField(
                                                                            currentQuestion,
                                                                            r'''$.answer''');
                                                                    final correctAnswerStr =
                                                                        normalizeAnswer(
                                                                            correctAnswer);

                                                                    // Check if the option key matches directly
                                                                    final userKeyNormalized =
                                                                        normalizeAnswer(
                                                                            userSelectedKey);
                                                                    bool
                                                                        isCorrect =
                                                                        userKeyNormalized ==
                                                                            correctAnswerStr;

                                                                    // If key doesn't match, check option text
                                                                    if (!isCorrect) {
                                                                      final options = getJsonField(
                                                                          currentQuestion,
                                                                          r'''$.option''');
                                                                      if (options
                                                                              is Map &&
                                                                          options[userSelectedKey] !=
                                                                              null) {
                                                                        final selectedOption =
                                                                            options[userSelectedKey];
                                                                        String
                                                                            optionText =
                                                                            '';
                                                                        if (selectedOption
                                                                            is Map) {
                                                                          if (selectedOption['text'] is Map &&
                                                                              selectedOption['text']['text'] !=
                                                                                  null) {
                                                                            optionText =
                                                                                selectedOption['text']['text'].toString();
                                                                          } else if (selectedOption['text'] !=
                                                                              null) {
                                                                            optionText =
                                                                                selectedOption['text'].toString();
                                                                          }
                                                                        } else {
                                                                          optionText =
                                                                              selectedOption.toString();
                                                                        }
                                                                        final optionTextNormalized =
                                                                            normalizeAnswer(optionText);
                                                                        isCorrect =
                                                                            optionTextNormalized ==
                                                                                correctAnswerStr;
                                                                      }

                                                                      // Also check if correct answer is stored as option text
                                                                      if (!isCorrect &&
                                                                          options
                                                                              is Map) {
                                                                        for (var key
                                                                            in [
                                                                          'a',
                                                                          'b',
                                                                          'c',
                                                                          'd'
                                                                        ]) {
                                                                          if (options[key] !=
                                                                              null) {
                                                                            final opt =
                                                                                options[key];
                                                                            String
                                                                                optText =
                                                                                '';
                                                                            if (opt
                                                                                is Map) {
                                                                              if (opt['text'] is Map && opt['text']['text'] != null) {
                                                                                optText = opt['text']['text'].toString();
                                                                              } else if (opt['text'] != null) {
                                                                                optText = opt['text'].toString();
                                                                              }
                                                                            } else {
                                                                              optText = opt.toString();
                                                                            }
                                                                            final optTextNormalized =
                                                                                normalizeAnswer(optText);
                                                                            if (optTextNormalized == correctAnswerStr &&
                                                                                key == userSelectedKey) {
                                                                              isCorrect = true;
                                                                              break;
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    }


                                                                    if (isCorrect) {
                                                                      FFAppState()
                                                                          .correctQues += 1;
                                                                    } else {
                                                                      FFAppState()
                                                                          .wrongQues += 1;
                                                                    }
                                                                  } else {
                                                                    FFAppState()
                                                                        .notAnswerQues += 1;
                                                                    FFAppState()
                                                                        .addToNotAnswerQuestion({
                                                                      'question_title':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.question_title''',
                                                                      ),
                                                                      'question_type':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.question_type''',
                                                                      ),
                                                                      'answer':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.answer''',
                                                                      ),
                                                                      'option':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.option''',
                                                                      ),
                                                                      'user_answer':
                                                                          FFAppState()
                                                                              .userAns,
                                                                    });
                                                                  }
                                                                  FFAppState()
                                                                      .update(
                                                                          () {});

                                                                  final totalQuestions = (QuizGroup
                                                                          .getquestionsbyquizidApiCall
                                                                          .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                              ''))
                                                                          ?.length ??
                                                                      0);
                                                                  final isLast =
                                                                      (_model.pageViewCurrentIndex +
                                                                              1) ==
                                                                          totalQuestions;

                                                                  if (isLast) {
                                                                    // Build quesList with user answers for result screen
                                                                    final questions =
                                                                        QuizGroup.getquestionsbyquizidApiCall.questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                '')) ??
                                                                            [];
                                                                    List<Map<String, dynamic>>
                                                                        quesList =
                                                                        [];

                                                                    // Recalculate correct/wrong counts to ensure accuracy
                                                                    int correctCount =
                                                                        0;
                                                                    int wrongCount =
                                                                        0;
                                                                    int skippedCount =
                                                                        0;

                                                                    // Helper function to normalize answer for comparison
                                                                    String normalizeAnswer(
                                                                        dynamic
                                                                            answer) {
                                                                      if (answer ==
                                                                          null)
                                                                        return '';
                                                                      return answer
                                                                          .toString()
                                                                          .trim()
                                                                          .toLowerCase();
                                                                    }

                                                                    for (int i =
                                                                            0;
                                                                        i < questions.length;
                                                                        i++) {
                                                                      final q = Map<
                                                                          String,
                                                                          dynamic>.from(questions[i]);
                                                                      // Recursively flatten option fields to ensure text and image are strings
                                                                      Map<String,
                                                                              dynamic>
                                                                          flattenOption(
                                                                              Map? opt) {
                                                                        if (opt ==
                                                                            null)
                                                                          return {
                                                                            'text':
                                                                                '',
                                                                            'image':
                                                                                ''
                                                                          };
                                                                        String
                                                                            textValue =
                                                                            '';
                                                                        if (opt['text']
                                                                            is String) {
                                                                          textValue =
                                                                              opt['text'];
                                                                        } else if (opt['text']
                                                                                is Map &&
                                                                            opt['text']['text']
                                                                                is String) {
                                                                          textValue =
                                                                              opt['text']['text'];
                                                                        }
                                                                        String
                                                                            imageValue =
                                                                            '';
                                                                        if (opt['image']
                                                                            is String) {
                                                                          imageValue =
                                                                              opt['image'];
                                                                        } else if (opt['text']
                                                                                is Map &&
                                                                            opt['text']['image']
                                                                                is String) {
                                                                          imageValue =
                                                                              opt['text']['image'];
                                                                        }
                                                                        return {
                                                                          'text':
                                                                              textValue,
                                                                          'image':
                                                                              imageValue,
                                                                        };
                                                                      }

                                                                      final options =
                                                                          q['option'] ??
                                                                              {};
                                                                      final flatOptions =
                                                                          {
                                                                        'a': flattenOption(
                                                                            options['a']),
                                                                        'b': flattenOption(
                                                                            options['b']),
                                                                        'c': flattenOption(
                                                                            options['c']),
                                                                        'd': flattenOption(
                                                                            options['d']),
                                                                      };
                                                                      // Replace the original option field with the flattened one
                                                                      q['option'] =
                                                                          flatOptions;

                                                                      final userAnswer =
                                                                          userAnswersPerQuestion[i] ??
                                                                              'skipped';
                                                                      final correctAnswer =
                                                                          getJsonField(
                                                                              q,
                                                                              r'''$.answer''');

                                                                      // Count correct/wrong/skipped
                                                                      if (userAnswer ==
                                                                          'skipped') {
                                                                        skippedCount++;
                                                                      } else {
                                                                        final userKeyNormalized =
                                                                            normalizeAnswer(userAnswer);
                                                                        final correctAnswerNormalized =
                                                                            normalizeAnswer(correctAnswer);
                                                                        bool
                                                                            isCorrect =
                                                                            userKeyNormalized ==
                                                                                correctAnswerNormalized;

                                                                        // If key doesn't match, check option text
                                                                        if (!isCorrect &&
                                                                            userAnswer !=
                                                                                null &&
                                                                            flatOptions[userAnswer] !=
                                                                                null) {
                                                                          final selectedOption =
                                                                              flatOptions[userAnswer];
                                                                          if (selectedOption !=
                                                                              null) {
                                                                            String
                                                                                optionText =
                                                                                '';
                                                                            if (selectedOption['text'] !=
                                                                                null) {
                                                                              optionText = selectedOption['text'].toString();
                                                                            }
                                                                            final optionTextNormalized =
                                                                                normalizeAnswer(optionText);
                                                                            isCorrect =
                                                                                optionTextNormalized == correctAnswerNormalized;
                                                                          }
                                                                        }

                                                                        // Also check if correct answer matches any option text
                                                                        if (!isCorrect &&
                                                                            userAnswer !=
                                                                                null) {
                                                                          for (var key
                                                                              in [
                                                                            'a',
                                                                            'b',
                                                                            'c',
                                                                            'd'
                                                                          ]) {
                                                                            if (key == userAnswer &&
                                                                                flatOptions[key] != null) {
                                                                              final opt = flatOptions[key];
                                                                              if (opt != null) {
                                                                                String optText = '';
                                                                                if (opt['text'] != null) {
                                                                                  optText = opt['text'].toString();
                                                                                }
                                                                                final optTextNormalized = normalizeAnswer(optText);
                                                                                if (optTextNormalized == correctAnswerNormalized) {
                                                                                  isCorrect = true;
                                                                                  break;
                                                                                }
                                                                              }
                                                                            }
                                                                          }
                                                                        }

                                                                        if (isCorrect) {
                                                                          correctCount++;
                                                                        } else {
                                                                          wrongCount++;
                                                                        }
                                                                      }

                                                                       quesList
                                                                           .add({
                                                                         'question':
                                                                             q,
                                                                         'user_answer':
                                                                             userAnswer,
                                                                         'correct_answer':
                                                                             correctAnswer,
                                                                         'question_title': getJsonField(
                                                                             q,
                                                                             r'''$.question_title'''),
                                                                         'question_type': getJsonField(
                                                                             q,
                                                                             r'''$.question_type'''),
                                                                         'image': getJsonField(
                                                                             q,
                                                                             r'''$.image'''),
                                                                         'audio': getJsonField(
                                                                             q,
                                                                             r'''$.audio'''),
                                                                         'description': getJsonField(
                                                                             q,
                                                                             r'''$.description'''),
                                                                         'subcategoryName': getJsonField(
                                                                             q,
                                                                             r'''$.subcategoryName'''),
                                                                       });
                                                                    }

                                                                    // Update the counts with recalculated values
                                                                    FFAppState()
                                                                            .correctQues =
                                                                        correctCount;
                                                                    FFAppState()
                                                                            .wrongQues =
                                                                        wrongCount;
                                                                    FFAppState()
                                                                            .notAnswerQues =
                                                                        skippedCount;


                                                                    FFAppState()
                                                                            .quesList =
                                                                        quesList;
                                                                    // Debug print to verify outgoing JSON

                                                                    context
                                                                        .goNamed(
                                                                      QuizResultWidget
                                                                          .routeName,
                                                                      queryParameters:
                                                                          {
                                                                        'correctAnswer': serializeParam(
                                                                            FFAppState().correctQues,
                                                                            ParamType.int),
                                                                        'wrongAnswer': serializeParam(
                                                                            FFAppState().wrongQues,
                                                                            ParamType.int),
                                                                        'totalQuestion': serializeParam(
                                                                            totalQuestions,
                                                                            ParamType.int),
                                                                        'notAnswer': serializeParam(
                                                                            FFAppState().notAnswerQues,
                                                                            ParamType.int),
                                                                        'quizID': serializeParam(
                                                                            widget.quizID,
                                                                            ParamType.String),
                                                                        'quizTime': serializeParam(
                                                                            _elapsedTimeLabel,
                                                                            ParamType.String),
                                                                        'catID': serializeParam(
                                                                            widget.catId,
                                                                            ParamType.String),
                                                                        'title': serializeParam(
                                                                            widget.title,
                                                                            ParamType.String),
                                                                        'image': serializeParam(
                                                                            widget.image,
                                                                            ParamType.String),
                                                                        'correctAnsReward': serializeParam(
                                                                            correctAnsReward,
                                                                            ParamType.double),
                                                                        'penaltyPerQuestion': serializeParam(
                                                                            penaltyPerQuestion,
                                                                            ParamType.double),
                                                                      }.withoutNulls,
                                                                    );
                                                                  } else {
                                                                    // It's not the last question, move to the next one
                                                                    await _model
                                                                        .pageViewController
                                                                        ?.nextPage(
                                                                      duration: Duration(
                                                                          milliseconds:
                                                                              300),
                                                                      curve: Curves
                                                                          .ease,
                                                                    );
                                                                    _model.userAnswer =
                                                                        null;
                                                                    _model.actualAnswer =
                                                                        null;
                                                                    FFAppState()
                                                                            .quesIndex =
                                                                        _model.pageViewCurrentIndex +
                                                                            1;
                                                                    FFAppState()
                                                                        .selectedColorIndex = -1;
                                                                    safeSetState(
                                                                        () {});
                                                                  }

                                                                  // Inside the Save & Next button logic, after processing the answer:
                                                                  if (_model.userAnswer !=
                                                                          null &&
                                                                      _model.userAnswer !=
                                                                          '') {
                                                                    final userAnswer =
                                                                        userAnswersPerQuestion[_model.pageViewCurrentIndex] ??
                                                                            'skipped';
                                                                    FFAppState()
                                                                        .addToQuesList({
                                                                      'question_title':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.question_title''',
                                                                      ),
                                                                      'image':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.image''',
                                                                      ),
                                                                      'audio':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.audio''',
                                                                      ),
                                                                      'question_type':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.question_type''',
                                                                      ),
                                                                      'subcategoryName':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.subcategoryName''',
                                                                      ),
                                                                      'option':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.option''',
                                                                      ),
                                                                      'answer':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.answer''',
                                                                      ),
                                                                      'user_answer':
                                                                          userAnswer,
                                                                      'description':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.description''',
                                                                      ),
                                                                    });
                                                                  } else {
                                                                    // For skipped questions
                                                                    final userAnswer =
                                                                        'skipped';
                                                                    FFAppState()
                                                                        .addToQuesList({
                                                                      'question_title':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.question_title''',
                                                                      ),
                                                                      'image':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.image''',
                                                                      ),
                                                                      'audio':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.audio''',
                                                                      ),
                                                                      'question_type':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.question_type''',
                                                                      ),
                                                                      'subcategoryName':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.subcategoryName''',
                                                                      ),
                                                                      'option':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.option''',
                                                                      ),
                                                                      'answer':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.answer''',
                                                                      ),
                                                                      'user_answer':
                                                                          userAnswer,
                                                                      'description':
                                                                          getJsonField(
                                                                        QuizGroup
                                                                            .getquestionsbyquizidApiCall
                                                                            .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                                ''))
                                                                            ?.elementAtOrNull(_model.pageViewCurrentIndex),
                                                                        r'''$.description''',
                                                                      ),
                                                                    });
                                                                  }

                                                                  // Update FFAppState().quesList for ALL questions
                                                                  FFAppState()
                                                                      .quesList = [];
                                                                  for (int i =
                                                                          0;
                                                                      i < totalQuestions;
                                                                      i++) {
                                                                    final q = QuizGroup
                                                                        .getquestionsbyquizidApiCall
                                                                        .questionDetailsList((_model.quizRes?.jsonBody ??
                                                                            ''))
                                                                        ?.elementAtOrNull(
                                                                            i);
                                                                    final userAnswer =
                                                                        userAnswersPerQuestion[i] ??
                                                                            'skipped';
                                                                    FFAppState()
                                                                        .quesList
                                                                        .add({
                                                                      'question_title':
                                                                          getJsonField(
                                                                              q,
                                                                              r'''$.question_title'''),
                                                                      'image':
                                                                          getJsonField(
                                                                              q,
                                                                              r'''$.image'''),
                                                                      'audio':
                                                                          getJsonField(
                                                                              q,
                                                                              r'''$.audio'''),
                                                                      'question_type':
                                                                          getJsonField(
                                                                              q,
                                                                              r'''$.question_type'''),
                                                                      'subcategoryName':
                                                                          getJsonField(
                                                                              q,
                                                                              r'''$.subcategoryName'''),
                                                                      'option':
                                                                          getJsonField(
                                                                              q,
                                                                              r'''$.option'''),
                                                                      'answer':
                                                                          getJsonField(
                                                                              q,
                                                                              r'''$.answer'''),
                                                                      'user_answer':
                                                                          userAnswer,
                                                                      'description':
                                                                          getJsonField(
                                                                              q,
                                                                              r'''$.description'''),
                                                                    });
                                                                  }

                                                                  // Update FFAppState().quesReviewList
                                                                  FFAppState()
                                                                          .quesReviewList =
                                                                      FFAppState()
                                                                          .quesList
                                                                          .toList();
                                                                },
                                                                 text: ((QuizGroup.getquestionsbyquizidApiCall.questionDetailsList((_model.quizRes?.jsonBody ?? ''))?.length ??
                                                                             0) ==
                                                                         (_model.pageViewCurrentIndex +
                                                                             1))
                                                                     ? 'Submit'
                                                                     : 'Next',
                                                                isPrimary: true,
                                                                accentColor:
                                                                    const Color(
                                                                        0xFF2563EB),
                                                                 trailingIcon: ((QuizGroup.getquestionsbyquizidApiCall.questionDetailsList((_model.quizRes?.jsonBody ?? ''))?.length ??
                                                                             0) ==
                                                                         (_model.pageViewCurrentIndex +
                                                                             1))
                                                                     ? Icons
                                                                         .check_rounded
                                                                     : Icons
                                                                         .keyboard_double_arrow_right_rounded,
                                                              ),
                                                            ),
                                                          ]),
                                                    ),
                                                  ]),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                // Return empty widget if quiz data is not successful
                                return SizedBox.shrink();
                              }
                            },
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
              ),
      ),
    );
  }
}
