import '/backend/api_requests/api_calls.dart';
import '/componants/subscription_required_dialog/subscription_required_dialog_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubcategoryDetailPageWidget extends StatefulWidget {
  const SubcategoryDetailPageWidget({
    Key? key,
    this.subcategoryId,
    this.subcategoryName,
  }) : super(key: key);

  final String? subcategoryId;
  final String? subcategoryName;

  static String routeName = 'subcategory_detail_page';
  static String routePath = '/subcategoryDetailPage';

  @override
  State<SubcategoryDetailPageWidget> createState() =>
      _SubcategoryDetailPageWidgetState();
}

class _SubcategoryDetailPageWidgetState
    extends State<SubcategoryDetailPageWidget> {
  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFDCEAFF),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 16.0),
          child: Row(
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
                      color: Colors.white,
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
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: FFFont.f18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 21.0,
          height: 21.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: const Color(0xFFD9E4FF)),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 13.0,
            color: const Color(0xFF4A6CF7),
          ),
        ),
        const SizedBox(width: 7.0),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: FFFont.f14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 5).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => Container(
              width: 3.0,
              height: 1.2,
              decoration: BoxDecoration(
                color: const Color(0xFF6D9CFF),
                borderRadius: BorderRadius.circular(999.0),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openQuiz(Map quiz) async {
    // Subscription gate: only allow starting if the user has access
    if (!functions.hasCategoryAccess(
      FFAppState().planStatus,
      FFAppState().subsIsSelectedAll,
      FFAppState().allowedCategoryIds,
      (quiz['_id'] ?? '').toString(),
      null,
    )) {
      await showSubscriptionDialog(context);
      return;
    }
    context.pushNamed(
      'quiz_questions_screen',
      queryParameters: {
        'quizID': quiz['_id'],
        'title': quiz['name'],
        'image': quiz['image'] != null && quiz['image'].toString().isNotEmpty
            ? (quiz['image'].toString().startsWith('http')
                ? quiz['image'].toString()
                : '${FFAppConstants.imageBaseURL}${quiz['image']}')
            : '',
        'quizTime': quiz['minutes_per_quiz'].toString(),
        'description': quiz['description'],
      },
    );
  }

  Widget _buildQuizCard(Map quiz) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async => _openQuiz(quiz),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 176.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 12.0, 14.0, 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5.0,
                height: 28.0,
                margin: const EdgeInsets.only(top: 2.0),
                color: const Color(0xFF1D6FFF),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58.0,
                          height: 58.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8FF),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.all(6.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              imageUrl: quiz['image'] != null && quiz['image'].toString().isNotEmpty
                                  ? (quiz['image'].toString().startsWith('http')
                                      ? quiz['image'].toString()
                                      : '${FFAppConstants.imageBaseURL}${quiz['image']}')
                                  : 'https://picsum.photos/seed/${quiz['_id']}/120',
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
                        const SizedBox(width: 11.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0, right: 6.0),
                                child: Text(
                                  quiz['name'] ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: FFFont.f18,
                                    fontWeight: FontWeight.w800,
                                    height: 1.28,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  _buildMetaItem(
                                    icon: Icons.access_time_rounded,
                                    text: '${quiz['minutes_per_quiz'] ?? ''} mins',
                                  ),
                                  const SizedBox(width: 13.0),
                                  Container(
                                    width: 1.0,
                                    height: 18.0,
                                    color: const Color(0xFFD7E1F0),
                                  ),
                                  const SizedBox(width: 13.0),
                                  _buildMetaItem(
                                    icon: Icons.assignment_outlined,
                                    text:
                                        '${quiz['minimum_required_points'] ?? quiz['total_questions'] ?? 'N/A'} Marks',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      width: 260.0,
                      child: _buildDashedDivider(),
                    ),
                    const SizedBox(height: 14.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 22.0,
                          height: 22.0,
                          child: SvgPicture.asset(
                            'assets/images/google_translate_icon.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Container(
                          width: 1.0,
                          height: 20.0,
                          color: const Color(0xFFD7E1F0),
                        ),
                        const SizedBox(width: 10.0),
                        const Expanded(
                          child: Text(
                            'हिन्दी, English',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: FFFont.f16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 90.0,
                          height: 34.0,
                          child: ElevatedButton(
                            onPressed: () async => _openQuiz(quiz),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF1D6FFF),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'Start Test',
                              style: TextStyle(
                                fontSize: FFFont.f16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final subcategoryId = args != null ? args['subcategoryId'] : widget.subcategoryId;
    final subcategoryName = args != null ? args['subcategoryName'] : widget.subcategoryName;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      body: Column(
        children: [
          _buildHeader(subcategoryName ?? 'Subcategory'),
          Expanded(
            child: FutureBuilder<ApiCallResponse>(
              future: QuizGroup.getQuizBySubcategoryCall.call(
                subcategoryId: subcategoryId,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final quizzesList =
                    QuizGroup.getQuizBySubcategoryCall.quizList(
                          snapshot.data!.jsonBody,
                        ) ??
                        [];
                final quizzes = quizzesList.toList();
                quizzes.sort((a, b) {
                  DateTime? parseDate(String name) {
                    final monthMap = {
                      'jan': 1,
                      'feb': 2,
                      'mar': 3,
                      'apr': 4,
                      'may': 5,
                      'jun': 6,
                      'jul': 7,
                      'aug': 8,
                      'sep': 9,
                      'oct': 10,
                      'nov': 11,
                      'dec': 12,
                      'january': 1,
                      'february': 2,
                      'march': 3,
                      'april': 4,
                      'june': 6,
                      'july': 7,
                      'august': 8,
                      'september': 9,
                      'october': 10,
                      'november': 11,
                      'december': 12
                    };

                    final regex = RegExp(
                      r'(\d{1,2})[\s\-\.]*([a-zA-Z]+)[\s\-\.]*(\d{4})',
                      caseSensitive: false,
                    );
                    final match = regex.firstMatch(name);

                    if (match != null) {
                      final day = int.tryParse(match.group(1)!);
                      final monthStr = match.group(2)!.toLowerCase();
                      final year = int.tryParse(match.group(3)!);
                      final month = monthMap[monthStr];

                      if (day != null && month != null && year != null) {
                        return DateTime(year, month, day);
                      }
                    }
                    return null;
                  }

                  int parseShift(String name) {
                    final match = RegExp(
                      r'\(Shift\s*(\d+)\)',
                      caseSensitive: false,
                    ).firstMatch(name);
                    if (match != null) {
                      return int.tryParse(match.group(1) ?? '0') ?? 0;
                    }
                    return 0;
                  }

                  final createdAtA =
                      DateTime.tryParse(a['createdAt']?.toString() ?? '');
                  final createdAtB =
                      DateTime.tryParse(b['createdAt']?.toString() ?? '');

                  if (createdAtA != null && createdAtB != null) {
                    int createdComp = createdAtB.compareTo(createdAtA);
                    if (createdComp != 0) return createdComp;
                  } else if (createdAtA != null) {
                    return -1;
                  } else if (createdAtB != null) {
                    return 1;
                  }

                  DateTime? dateA = parseDate(a['name'] ?? '');
                  DateTime? dateB = parseDate(b['name'] ?? '');

                  if (dateA != null && dateB != null) {
                    int dateComp = dateB.compareTo(dateA);
                    if (dateComp != 0) return dateComp;
                  } else if (dateA != null) {
                    return -1;
                  } else if (dateB != null) {
                    return 1;
                  }

                  int shiftA = parseShift(a['name'] ?? '');
                  int shiftB = parseShift(b['name'] ?? '');
                  return shiftB.compareTo(shiftA);
                });

                if (quizzes.isEmpty) {
                  return const Center(
                    child: Text('No quizzes found for this subcategory.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0),
                  itemCount: quizzes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                  itemBuilder: (context, index) {
                    return _buildQuizCard(Map<String, dynamic>.from(quizzes[index]));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
