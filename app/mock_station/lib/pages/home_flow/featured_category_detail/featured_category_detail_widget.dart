import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'featured_category_detail_model.dart';
export 'featured_category_detail_model.dart';

class FeaturedCategoryDetailWidget extends StatefulWidget {
  const FeaturedCategoryDetailWidget({
    super.key,
    this.title,
    this.quizList,
    this.index,
  });

  final String? title;
  final List<dynamic>? quizList;
  final int? index;

  static String routeName = 'featured_category_detail';
  static String routePath = '/featuredCategoryDetail';

  @override
  State<FeaturedCategoryDetailWidget> createState() =>
      _FeaturedCategoryDetailWidgetState();
}

class _FeaturedCategoryDetailWidgetState
    extends State<FeaturedCategoryDetailWidget> with TickerProviderStateMixin {
  late FeaturedCategoryDetailModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  Future<void> _openQuiz(dynamic quizzesItem) async {
    if (FFAppState().isLogin == true) {
      context.pushNamed(
        DetailScreenWidget.routeName,
        queryParameters: {
          'catId': serializeParam(
            getJsonField(
              quizzesItem,
              r'''$.categoryId''',
            ).toString(),
            ParamType.String,
          ),
          'name': serializeParam(
            getJsonField(
              quizzesItem,
              r'''$.name''',
            ).toString(),
            ParamType.String,
          ),
          'image': serializeParam(
            '${FFAppConstants.baseURL}assets/userImages/${getJsonField(
              quizzesItem,
              r'''$.image''',
            ).toString()}',
            ParamType.String,
          ),
          'quizTime': serializeParam(
            getJsonField(
              quizzesItem,
              r'''$.minutes_per_quiz''',
            ).toString(),
            ParamType.String,
          ),
          'description': serializeParam(
            getJsonField(
              quizzesItem,
              r'''$.description''',
            ).toString(),
            ParamType.String,
          ),
          'ques': serializeParam(
            getJsonField(
              quizzesItem,
              r'''$.total_questions''',
            ),
            ParamType.int,
          ),
          'quizID': serializeParam(
            getJsonField(
              quizzesItem,
              r'''$._id''',
            ).toString(),
            ParamType.String,
          ),
          'title': serializeParam(
            widget.title,
            ParamType.String,
          ),
          'timerStatus': serializeParam(
            getJsonField(
              quizzesItem,
              r'''$.timer_status''',
            ),
            ParamType.int,
          ),
        }.withoutNulls,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please login first for View Content',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: FlutterFlowTheme.of(context).primaryText,
            fontSize: FFFont.f16,
          ),
        ),
        duration: const Duration(milliseconds: 2000),
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        action: SnackBarAction(
          label: 'Login',
          textColor: FlutterFlowTheme.of(context).primaryText,
          onPressed: () async {
            context.goNamed(LoginScreenWidget.routeName);
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFDCEAFF),
      ),
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

  Widget _buildQuizCard(dynamic quizzesItem, int quizzesIndex) {
    final imagePath = getJsonField(quizzesItem, r'''$.image''');
    final imageUrl = imagePath != null && imagePath.toString().isNotEmpty
        ? '${FFAppConstants.imageBaseURL}${imagePath.toString()}'
        : 'https://picsum.photos/seed/29/600';
    final name = getJsonField(quizzesItem, r'''$.name''').toString();
    final minutes =
        getJsonField(quizzesItem, r'''$.minutes_per_quiz''').toString();
    final totalQuestions =
        getJsonField(quizzesItem, r'''$.total_questions''').toString();

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async => _openQuiz(quizzesItem),
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
                decoration: BoxDecoration(
                  color: const Color(0xFF1D6FFF),
                  borderRadius: BorderRadius.circular(0.0),
                ),
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
                          width: 72.0,
                          height: 72.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F8FF),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.all(6.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              fadeInDuration:
                                  const Duration(milliseconds: 300),
                              fadeOutDuration:
                                  const Duration(milliseconds: 300),
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 11.0),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2.0, right: 6.0),
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: FFFont.f18,
                                fontWeight: FontWeight.w800,
                                height: 1.28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: [
                        _buildMetaItem(
                          icon: Icons.access_time_rounded,
                          text: '$minutes mins',
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
                          text: '$totalQuestions Marks',
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
                          width: 30.0,
                          height: 30.0,
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
                          width: 107.0,
                          height: 42.0,
                          child: ElevatedButton(
                            onPressed: () async => _openQuiz(quizzesItem),
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
    ).animateOnPageLoad(
      animationsMap['containerOnPageLoadAnimation']!,
      effects: [
        MoveEffect(
          curve: Curves.easeInOut,
          delay: valueOrDefault<double>(
            quizzesIndex * 111,
            0.0,
          ).ms,
          duration: 400.0.ms,
          begin: const Offset(100.0, 0.0),
          end: const Offset(0.0, 0.0),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FeaturedCategoryDetailModel());

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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFEAF3FF),
        body: Builder(
          builder: (context) {
            if (FFAppState().connected == true) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildHeader(),
                  Expanded(
                    child: FutureBuilder<ApiCallResponse>(
                      future: FFAppState()
                          .featured(
                        requestFn: () => GetFeatureCategoryCall.call(),
                      )
                          .then((result) {
                        _model.apiRequestCompleted = true;
                        return result;
                      }),
                      builder: (context, snapshot) {
                        // Customize what your widget looks like when it's loading.
                        if (!snapshot.hasData) {
                          return Center(
                            child: SizedBox(
                              width: 50.0,
                              height: 50.0,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            ),
                          );
                        }
                        final containerGetFeatureCategoryResponse =
                            snapshot.data!;

                        return Container(
                          decoration: BoxDecoration(),
                          child: Builder(
                            builder: (context) {
                              if (GetFeatureCategoryCall.success(
                                    containerGetFeatureCategoryResponse
                                        .jsonBody,
                                  ) ==
                                  2) {
                                return Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: Text(
                                      valueOrDefault<String>(
                                        GetFeatureCategoryCall.message(
                                          containerGetFeatureCategoryResponse
                                              .jsonBody,
                                        ),
                                        'Message',
                                      ),
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Roboto',
                                            fontSize: FFFont.f18,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            useGoogleFonts: false,
                                            lineHeight: 1.5,
                                          ),
                                    ),
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12.0, 0.0, 12.0, 0.0),
                                  child: Builder(
                                    builder: (context) {
                                      final quizzes = getJsonField(
                                        GetFeatureCategoryCall.categoryDetails(
                                          containerGetFeatureCategoryResponse
                                              .jsonBody,
                                        )?.elementAtOrNull(widget.index!),
                                        r'''$.quizzes''',
                                      ).toList();

                                      return RefreshIndicator(
                                        key: Key('RefreshIndicator_u81mhu1p'),
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                        onRefresh: () async {
                                          safeSetState(() {
                                            FFAppState().clearFeaturedCache();
                                            _model.apiRequestCompleted = false;
                                          });
                                          await _model
                                              .waitForApiRequestCompleted();
                                        },
                                        child: ListView.separated(
                                          padding: EdgeInsets.fromLTRB(
                                            0,
                                            12.0,
                                            0,
                                            12.0,
                                          ),
                                          scrollDirection: Axis.vertical,
                                          itemCount: quizzes.length,
                                          separatorBuilder: (_, __) =>
                                              SizedBox(height: 10.0),
                                          itemBuilder: (context, quizzesIndex) {
                                            final quizzesItem =
                                                quizzes[quizzesIndex];
                                            return _buildQuizCard(
                                              quizzesItem,
                                              quizzesIndex,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  /*if (FFAppState().isBannerAd == 1)
                    custom_widgets.Bannerwidget(
                      width: double.infinity,
                      height: 50.0,
                    ),*/
                ],
              );
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
    );
  }
}
