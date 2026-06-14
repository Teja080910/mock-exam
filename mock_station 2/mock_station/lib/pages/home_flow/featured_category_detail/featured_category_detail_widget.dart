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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Builder(
          builder: (context) {
            if (FFAppState().connected == true) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  wrapWithModel(
                    model: _model.appBarModel,
                    updateCallback: () => safeSetState(() {}),
                    child: AppBarWidget(
                      title: widget.title!,
                      backIcon: false,
                    ),
                  ),
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
                                            fontSize: 18.0,
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
                                      16.0, 0.0, 16.0, 0.0),
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
                                            16.0,
                                            0,
                                            16.0,
                                          ),
                                          scrollDirection: Axis.vertical,
                                          itemCount: quizzes.length,
                                          separatorBuilder: (_, __) =>
                                              SizedBox(height: 16.0),
                                          itemBuilder: (context, quizzesIndex) {
                                            final quizzesItem =
                                                quizzes[quizzesIndex];
                                            return InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if (FFAppState().isLogin ==
                                                    true) {
                                                  context.pushNamed(
                                                    DetailScreenWidget
                                                        .routeName,
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
                                                        'https://quiz.templatevictory.com/assets/userImages/${getJsonField(
                                                          quizzesItem,
                                                          r'''$.image''',
                                                        ).toString()}',
                                                        ParamType.String,
                                                      ),
                                                      'quizTime':
                                                          serializeParam(
                                                        getJsonField(
                                                          quizzesItem,
                                                          r'''$.minutes_per_quiz''',
                                                        ).toString(),
                                                        ParamType.String,
                                                      ),
                                                      'description':
                                                          serializeParam(
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
                                                      'timerStatus':
                                                          serializeParam(
                                                        getJsonField(
                                                          quizzesItem,
                                                          r'''$.timer_status''',
                                                        ),
                                                        ParamType.int,
                                                      ),
                                                    }.withoutNulls,
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Please login first for View Content',
                                                        style: TextStyle(
                                                          fontFamily: 'Roboto',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryText,
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                      duration: Duration(
                                                          milliseconds: 2000),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondary,
                                                      action: SnackBarAction(
                                                        label: 'Login',
                                                        textColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        onPressed: () async {
                                                          context.goNamed(
                                                              LoginScreenWidget
                                                                  .routeName);
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                height: 118.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Builder(
                                                          builder: (context) {
                                                            if (getJsonField(
                                                                  quizzesItem,
                                                                  r'''$.image''',
                                                                ) !=
                                                                null) {
                                                              return ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fadeInDuration:
                                                                      Duration(
                                                                          milliseconds:
                                                                              500),
                                                                  fadeOutDuration:
                                                                      Duration(
                                                                          milliseconds:
                                                                              500),
                                                                  imageUrl:
                                                                      valueOrDefault<
                                                                          String>(
                                                                    '${FFAppConstants.imageBaseURL}${getJsonField(
                                                                      quizzesItem,
                                                                      r'''$.image''',
                                                                    ).toString()}',
                                                                    'https://picsum.photos/seed/223/600',
                                                                  ),
                                                                  width: 70.0,
                                                                  height: 70.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              );
                                                            } else {
                                                              return ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fadeInDuration:
                                                                      Duration(
                                                                          milliseconds:
                                                                              500),
                                                                  fadeOutDuration:
                                                                      Duration(
                                                                          milliseconds:
                                                                              500),
                                                                  imageUrl:
                                                                      'https://picsum.photos/seed/29/600',
                                                                  width: 70.0,
                                                                  height: 70.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    12.0,
                                                                    0.0,
                                                                    12.0,
                                                                    0.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              getJsonField(
                                                                quizzesItem,
                                                                r'''$.name''',
                                                              ).toString(),
                                                              maxLines: 2,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Roboto',
                                                                    fontSize:
                                                                        17.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    useGoogleFonts:
                                                                        false,
                                                                    lineHeight:
                                                                        1.2,
                                                                  ),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          12.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    '${getJsonField(
                                                                      quizzesItem,
                                                                      r'''$.total_questions''',
                                                                    ).toString()} questions',
                                                                    maxLines: 2,
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          fontSize:
                                                                              17.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                          useGoogleFonts:
                                                                              false,
                                                                          lineHeight:
                                                                              1.2,
                                                                        ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          12.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      Container(
                                                                    width: 5.0,
                                                                    height: 5.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .black,
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          12.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child:
                                                                      RichText(
                                                                    textScaler:
                                                                        MediaQuery.of(context)
                                                                            .textScaler,
                                                                    text:
                                                                        TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              getJsonField(
                                                                            quizzesItem,
                                                                            r'''$.minutes_per_quiz''',
                                                                          ).toString(),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .override(
                                                                                fontFamily: 'Roboto',
                                                                                fontSize: 17.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.normal,
                                                                                useGoogleFonts: false,
                                                                                lineHeight: 1.2,
                                                                              ),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ' min',
                                                                          style:
                                                                              TextStyle(),
                                                                        )
                                                                      ],
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            fontSize:
                                                                                17.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.normal,
                                                                            useGoogleFonts:
                                                                                false,
                                                                            lineHeight:
                                                                                1.2,
                                                                          ),
                                                                    ),
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                              ].divide(SizedBox(
                                                                  width: 5.0)),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ]
                                                      .addToStart(
                                                          SizedBox(width: 10.0))
                                                      .addToEnd(SizedBox(
                                                          width: 10.0)),
                                                ),
                                              ),
                                            ).animateOnPageLoad(
                                              animationsMap[
                                                  'containerOnPageLoadAnimation']!,
                                              effects: [
                                                MoveEffect(
                                                  curve: Curves.easeInOut,
                                                  delay: valueOrDefault<double>(
                                                    quizzesIndex * 111,
                                                    0.0,
                                                  ).ms,
                                                  duration: 400.0.ms,
                                                  begin: Offset(100.0, 0.0),
                                                  end: Offset(0.0, 0.0),
                                                ),
                                              ],
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
