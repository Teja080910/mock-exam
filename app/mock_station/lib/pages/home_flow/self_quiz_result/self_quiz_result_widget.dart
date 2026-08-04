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

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
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
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            value,
            style: TextStyle(
              color: fg,
              fontSize: 22.0,
              fontWeight: FontWeight.w900,
            ),
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE5E7EB).withOpacity(0.8)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22.0,
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: accent,
                fontSize: 14.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Container(
            width: 34.0,
            height: 34.0,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B),
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 2.0),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 14.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8.0),
          Icon(
            crown ? Icons.emoji_events_rounded : Icons.emoji_events_outlined,
            color: accent,
            size: 18.0,
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
                border: Border.all(color: accent, width: 3.0),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 34.0),
            ),
            Positioned(
              top: -2.0,
              right: -2.0,
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
                    fontSize: 11.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (crowned)
              const Positioned(
                top: -26.0,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFF59E0B),
                  size: 28.0,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.20),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            name,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          points,
          style: TextStyle(
            color: accent,
            fontSize: 13.0,
            fontWeight: FontWeight.w700,
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
    return FutureBuilder<ApiCallResponse>(
      future: QuizGroup.getpointssettingApiCall.call(
        token: FFAppState().loginToken,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final pointsResponse = snapshot.data!;
        final totalMark = ((((widget.correctAnswer ?? 0) *
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
                .toDouble())
            .toStringAsFixed(4);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16.0, 18.0, 16.0, 18.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
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
                              fontSize: 24.0,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
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
                      radius: 58.0,
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
                              fontSize: 24.0,
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
              ),
              const SizedBox(height: 14.0),
              Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Summary',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 16.0,
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
                      childAspectRatio: 1.5,
                      children: [
                        _statCard('Total Questions', total.toString(),
                            const Color(0xFF0B84FF), const Color(0xFFF1F6FF)),
                        _statCard('Total Mark', totalMark,
                            const Color(0xFF7C3AED), const Color(0xFFF7F1FF)),
                        _statCard('Correct Answer', correct.toString(),
                            const Color(0xFF16A34A), const Color(0xFFF0FBF4)),
                        _statCard('Incorrect Answer', wrong.toString(),
                            const Color(0xFFEF4444), const Color(0xFFFFF3F3)),
                        _statCard('Skipped Question', skipped.toString(),
                            const Color(0xFFF59E0B), const Color(0xFFFFFAEE)),
                        _statCard('Completion', '$completion%',
                            const Color(0xFF1D4ED8), const Color(0xFFF1F6FF)),
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

  Widget _buildAnswerKeyTab({
    required List<dynamic> questions,
  }) {
    final list = questions.isNotEmpty
        ? questions
        : List.generate(
            widget.totalQuestion ?? 0,
            (index) => <String, dynamic>{'user_answer': 'skipped'},
          );

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 18.0),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10.0),
      itemBuilder: (context, index) {
        final item = list[index];
        final isAnswered = (getJsonField(item, r'''$.user_answer''') ?? '')
                .toString() !=
            'skipped';
        final correct = (getJsonField(item, r'''$.correct_answer''') ??
                getJsonField(item, r'''$.answer'''))
            .toString();
        return Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 30.0,
                height: 30.0,
                decoration: const BoxDecoration(
                  color: Color(0xFF1D4ED8),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAnswered ? 'Answered' : 'Not answered',
                      style: TextStyle(
                        color: isAnswered
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF94A3B8),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Correct: ${correct.isEmpty ? '-' : correct}',
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
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

  Widget _buildLeaderboardTab() {
    return FutureBuilder<ApiCallResponse>(
      future: QuizGroup.leaderboardApiCall.call(
        token: FFAppState().loginToken,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = _sortedLeaderboard(snapshot.data!);
        final topThree = users.take(3).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 18.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (topThree.length > 1)
                        Expanded(
                          child: _podiumCard(
                            rank: '2',
                            name: _displayName(topThree[1], fallbackRank: 1),
                            points: '${_pointsLabel(topThree[1])} / 25.0',
                            accent: const Color(0xFF93C5FD),
                            size: 66.0,
                          ),
                        ),
                      if (topThree.isNotEmpty)
                        Expanded(
                          child: _podiumCard(
                            rank: '1',
                            name: _displayName(topThree[0], fallbackRank: 0),
                            points: '${_pointsLabel(topThree[0])} / 25.0',
                            accent: const Color(0xFFF9D38C),
                            size: 78.0,
                            crowned: true,
                          ),
                        ),
                      if (topThree.length > 2)
                        Expanded(
                          child: _podiumCard(
                            rank: '3',
                            name: _displayName(topThree[2], fallbackRank: 2),
                            points: '${_pointsLabel(topThree[2])} / 25.0',
                            accent: const Color(0xFFF9B38B),
                            size: 66.0,
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1.0, color: Color(0xFFE5E7EB)),
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
                                ? const Color(0xFFB45309)
                                : const Color(0xFF94A3B8),
                    crown: i == 0,
                  ),
              ],
            ),
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
