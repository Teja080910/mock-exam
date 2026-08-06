import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
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

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  Widget _buildHeader() {
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
                  widget.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
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
              color: Colors.white.withOpacity(0.55),
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
                fontSize: 10.0,
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
                    getJsonField(subcategory, r'$.name').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.0,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Click to view quizzes',
                    style: TextStyle(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 14.0,
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CategoryDetailPageModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: null,
      ),
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
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFEAF3FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FutureBuilder<ApiCallResponse>(
                future: FFAppState().details(
                  uniqueQueryKey: valueOrDefault<String>(widget.catId, '65498'),
                  requestFn: () => QuizGroup.getSubcategoriesCall.call(categoryId: widget.catId),
                ).then((result) {
                          _model.apiRequestCompleted = true;
                  _model.apiRequestLastUniqueKey = valueOrDefault<String>(widget.catId, '65498');
                  print('Subcategories API Response: ${result.jsonBody}');
                  print('Subcategories API Status: ${result.statusCode}');
                        return result;
                      }),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                    print('Error in subcategories API: ${snapshot.error}');
                    return Center(child: Text('Error loading subcategories: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                        }
                        final response = snapshot.data!;
                  final subcategoryList = (QuizGroup.getSubcategoriesCall.subcategoryList(response.jsonBody)?.toList() ?? [])
                    ..sort((a, b) {
                      String nameA = getJsonField(a, r'$.name').toString().trim().toLowerCase();
                      String nameB = getJsonField(b, r'$.name').toString().trim().toLowerCase();
                      
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
                  if (subcategoryList.isEmpty) {
                    return Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Text('No subcategories found for this category', style: Theme.of(context).textTheme.bodyLarge),
                          SizedBox(height: 16),
                          Text('Category ID: ${widget.catId}', style: Theme.of(context).textTheme.bodyMedium),
                          SizedBox(height: 8),
                          Text('Response: ${response.jsonBody}', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 16.0),
                    itemCount: subcategoryList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14.0),
                    itemBuilder: (context, subcategoryIndex) {
                      final subcategory = subcategoryList[subcategoryIndex];
                      return _buildSubcategoryCard(subcategory);
                      },
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
