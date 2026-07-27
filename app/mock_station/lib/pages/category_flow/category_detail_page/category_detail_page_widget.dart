import '/backend/api_requests/api_calls.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            wrapWithModel(
              model: _model.appBarModel,
              updateCallback: () => safeSetState(() {}),
              child: AppBarWidget(
                title: widget.title ?? '',
                backIcon: false,
              ),
            ),
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
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    itemCount: subcategoryList.length,
                    separatorBuilder: (_, __) => SizedBox(height: 16),
                    itemBuilder: (context, subcategoryIndex) {
                      final subcategory = subcategoryList[subcategoryIndex];
                      return GestureDetector(
                        onTap: () {
                                                  context.pushNamed(
                            'subcategory_detail_page',
                                                    queryParameters: {
                              'subcategoryId': serializeParam(getJsonField(subcategory, r'$._id').toString(), ParamType.String),
                              'subcategoryName': serializeParam(getJsonField(subcategory, r'$.name').toString(), ParamType.String),
                              'categoryName': serializeParam(widget.title, ParamType.String),
                              'image': serializeParam(widget.image, ParamType.String),
                                                    }.withoutNulls,
                                                  );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                                                ),
                            ],
                          ),
                          padding: EdgeInsets.all(16),
                                                  child: Row(
                                                    children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.quiz,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 16),
                                                      Expanded(
                                                          child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                      getJsonField(subcategory, r'$.name').toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                                                    ),
                                                              ),
                                    SizedBox(height: 4),
                                                                  Text(
                                      'Click to view quizzes',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[400],
                                size: 20,
                                                ),
                                              ],
                          ),
                          ),
                        );
                      },
                    );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: FlutterFlowTheme.of(context).primaryBackground,
              child: Text(
                "Disclaimer: Mock Station is not affiliated with any government entity. These mock tests are for practice purposes only.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
