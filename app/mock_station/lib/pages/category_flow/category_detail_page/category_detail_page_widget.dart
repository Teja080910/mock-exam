import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'category_detail_page_model.dart';
export 'category_detail_page_model.dart';

class CategoryDetailPageWidget extends StatefulWidget {
  const CategoryDetailPageWidget({
    super.key,
    this.title,
    this.catId,
    this.image,
  });

  final String? title;
  final String? catId;
  final String? image;

  static String routeName = 'category_detail_page';
  static String routePath = '/categoryDetailPage';

  @override
  State<CategoryDetailPageWidget> createState() =>
      _CategoryDetailPageWidgetState();
}

class _CategoryDetailPageWidgetState extends State<CategoryDetailPageWidget>
    with TickerProviderStateMixin {
  late CategoryDetailPageModel _model;
  TabController? _tabController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFDCEAFF),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 6.0),
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
                  (widget.title ?? '').toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: FFFont.f18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 54.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFDCEAFF),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF2563EB),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color(0xFF2563EB),
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontSize: FFFont.f14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: FFFont.f14,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'PYQs Based Tests'),
          Tab(text: 'Subject Wise Tests'),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEBFF),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10.0),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF2563EB),
              size: 20.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'Disclaimer: Mock Station is not affiliated with any government entity. These mock tests are for practice purposes only.',
              style: TextStyle(
                fontSize: FFFont.f10,
                height: 1.35,
                color: FlutterFlowTheme.of(context).secondaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryCard(dynamic subcategory) {
    final rawImage = getJsonField(subcategory, r'$.image').toString();
    final imageUrl = rawImage.isNotEmpty
        ? (rawImage.startsWith('http')
            ? rawImage
            : '${FFAppConstants.imageBaseURL}$rawImage')
        : 'https://picsum.photos/seed/${getJsonField(subcategory, r'$._id')}/120';

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'subcategory_detail_page',
          queryParameters: {
            'subcategoryId': serializeParam(
              getJsonField(subcategory, r'$._id').toString(),
              ParamType.String,
            ),
            'subcategoryName': serializeParam(
              getJsonField(subcategory, r'$.name').toString(),
              ParamType.String,
            ),
            'categoryName': serializeParam(widget.title, ParamType.String),
            'image': serializeParam(widget.image, ParamType.String),
          }.withoutNulls,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 12.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(0.0, 14.0, 14.0, 14.0),
        child: Row(
          children: [
            Container(
              width: 4.0,
              height: 34.0,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(999.0),
              ),
            ),
            const SizedBox(width: 10.0),
            Container(
              width: 54.0,
              height: 54.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FF),
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.all(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
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
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getJsonField(subcategory, r'$.name')
                        .toString()
                        .toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: FFFont.f16,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Click to view quizzes',
                    style: TextStyle(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: FFFont.f14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF2563EB),
              size: 28.0,
            ),
          ],
        ),
      ),
    ).animateOnPageLoad(
      animationsMap['containerOnPageLoadAnimation']!,
      effects: [
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 300.ms,
          begin: const Offset(40.0, 0.0),
          end: const Offset(0.0, 0.0),
        ),
      ],
    );
  }

  Widget _buildSubcategoryListView(List<dynamic> items,
      {required bool isSubjectTab}) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSubjectTab
                    ? Icons.menu_book_outlined
                    : Icons.assignment_outlined,
                size: 48.0,
                color: const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12.0),
              Text(
                isSubjectTab
                    ? 'No subject-wise tests available yet'
                    : 'No tests available for this category',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: FFFont.f16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Check back soon for new mock tests',
                style: TextStyle(
                  fontSize: FFFont.f14,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 16.0),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14.0),
      itemBuilder: (context, subcategoryIndex) {
        final subcategory = items[subcategoryIndex];
        return _buildSubcategoryCard(subcategory);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoryDetailPageModel());
    _tabController = TabController(length: 2, vsync: this);

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: null,
      ),
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFEAF3FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: FutureBuilder<ApiCallResponse>(
                future: QuizGroup.getSubcategoriesCall
                    .call(categoryId: widget.catId)
                    .then((result) {
                  _model.apiRequestCompleted = true;
                  _model.apiRequestLastUniqueKey =
                      valueOrDefault<String>(widget.catId, '65498');
                  print('Subcategories API Response: ${result.jsonBody}');
                  print('Subcategories API Status: ${result.statusCode}');
                  return result;
                }),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('Error in subcategories API: ${snapshot.error}');
                    return Center(
                        child: Text(
                            'Error loading subcategories: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final response = snapshot.data!;
                  final subcategoryList = (QuizGroup.getSubcategoriesCall
                          .subcategoryList(response.jsonBody)
                          ?.toList() ??
                      [])
                    ..sort((a, b) {
                      String nameA = getJsonField(a, r'$.name')
                          .toString()
                          .trim()
                          .toLowerCase();
                      String nameB = getJsonField(b, r'$.name')
                          .toString()
                          .trim()
                          .toLowerCase();

                      // Extract trailing number from each name
                      final regex = RegExp(r'(\d+)$');
                      final matchA = regex.firstMatch(nameA);
                      final matchB = regex.firstMatch(nameB);

                      if (matchA != null && matchB != null) {
                        int valA = int.parse(matchA.group(1)!);
                        int valB = int.parse(matchB.group(1)!);
                        return valA.compareTo(valB);
                      }
                      if (matchA != null) return -1; // names with numbers first
                      if (matchB != null) return 1;

                      return nameA.compareTo(nameB);
                    });

                  final allList = subcategoryList;
                  final subjectWiseList = subcategoryList.where((s) {
                    final rawType = (s is Map
                            ? (s['test_type'] ?? '')
                            : (getJsonField(s, r'$.test_type') ?? ''))
                        .toString()
                        .trim()
                        .toLowerCase();
                    return rawType == 'subject_wise';
                  }).toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSubcategoryListView(allList, isSubjectTab: false),
                      _buildSubcategoryListView(subjectWiseList, isSubjectTab: true),
                    ],
                  );
                },
              ),
            ),
            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }
}
