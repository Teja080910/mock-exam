import '/backend/api_requests/api_calls.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'detail_category_viewall_model.dart';
export 'detail_category_viewall_model.dart';

class DetailCategoryViewallWidget extends StatefulWidget {
  const DetailCategoryViewallWidget({super.key});

  static String routeName = 'detail_category_viewall';
  static String routePath = '/detailCategoryViewall';

  @override
  State<DetailCategoryViewallWidget> createState() =>
      _DetailCategoryViewallWidgetState();
}

class _DetailCategoryViewallWidgetState
    extends State<DetailCategoryViewallWidget> with TickerProviderStateMixin {
  late DetailCategoryViewallModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetailCategoryViewallModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: 0.15,
            end: 1.0,
          ),
        ],
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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            wrapWithModel(
              model: _model.appBarModel,
              updateCallback: () => safeSetState(() {}),
              child: AppBarWidget(
                title: 'Category',
                backIcon: true,
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (FFAppState().connected == true) {
                    return FutureBuilder<ApiCallResponse>(
                      future: FFAppState()
                          .categoryViewall(
                        requestFn: () => QuizGroup.getAllCategoriesCall.call(
                          token: FFAppState().loginToken,
                        ),
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
                        final containerGetAllCategoriesResponse =
                            snapshot.data!;

                        return Container(
                          decoration: BoxDecoration(),
                          child: Builder(
                            builder: (context) {
                              if (QuizGroup.getAllCategoriesCall.success(
                                    containerGetAllCategoriesResponse.jsonBody,
                                  ) ==
                                  2) {
                                return Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: Text(
                                      valueOrDefault<String>(
                                        QuizGroup.getAllCategoriesCall.message(
                                          containerGetAllCategoriesResponse
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
                                      16.0, 0.0, 16.0, 0.0),
                                  child: RefreshIndicator(
                                    key: Key('RefreshIndicator_1h3shjlm'),
                                    color: FlutterFlowTheme.of(context).primary,
                                    backgroundColor:
                                        FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    onRefresh: () async {
                                      safeSetState(() {
                                        FFAppState()
                                            .clearCategoryViewallCache();
                                        _model.apiRequestCompleted = false;
                                      });
                                      await _model.waitForApiRequestCompleted();
                                    },
                                    child: ListView(
                                      padding: EdgeInsets.fromLTRB(
                                        0,
                                        24.0,
                                        0,
                                        24.0,
                                      ),
                                      scrollDirection: Axis.vertical,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            final categoryList =
                                                QuizGroup.getAllCategoriesCall
                                                        .category(
                                                          containerGetAllCategoriesResponse
                                                              .jsonBody,
                                                        )
                                                        ?.toList() ??
                                                    [];

                                            return Wrap(
                                              spacing: 16.0,
                                              runSpacing: 16.0,
                                              alignment: WrapAlignment.start,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.start,
                                              direction: Axis.horizontal,
                                              runAlignment: WrapAlignment.start,
                                              verticalDirection:
                                                  VerticalDirection.down,
                                              clipBehavior: Clip.none,
                                              children: List.generate(
                                                  categoryList.length,
                                                  (categoryListIndex) {
                                                final categoryListItem =
                                                    categoryList[
                                                        categoryListIndex];
                                                return InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                   onTap: () async {
                                                     context.pushNamed(
                                                       CategoryDetailPageWidget
                                                           .routeName,
                                                       queryParameters: {
                                                         'title': serializeParam(
                                                           getJsonField(
                                                             categoryListItem,
                                                             r'''$.name''',
                                                           ).toString(),
                                                           ParamType.String,
                                                         ),
                                                         'catId': serializeParam(
                                                           getJsonField(
                                                             categoryListItem,
                                                             r'''$._id''',
                                                           ).toString(),
                                                           ParamType.String,
                                                         ),
                                                       }.withoutNulls,
                                                     );
                                                   },
                                                  child: Container(
                                                    width: () {
                                                      if (MediaQuery.sizeOf(
                                                                  context)
                                                              .width <
                                                          810.0) {
                                                        return ((MediaQuery.sizeOf(
                                                                        context)
                                                                    .width -
                                                                64) *
                                                            1 /
                                                            3);
                                                      } else if ((MediaQuery
                                                                      .sizeOf(
                                                                          context)
                                                                  .width >=
                                                              810.0) &&
                                                          (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width <
                                                              1280.0)) {
                                                        return ((MediaQuery.sizeOf(
                                                                        context)
                                                                    .width -
                                                                96) *
                                                            1 /
                                                            5);
                                                      } else if (MediaQuery
                                                                  .sizeOf(
                                                                      context)
                                                              .width >=
                                                          1280.0) {
                                                        return ((MediaQuery.sizeOf(
                                                                        context)
                                                                    .width -
                                                                144) *
                                                            1 /
                                                            8);
                                                      } else {
                                                        return ((MediaQuery.sizeOf(
                                                                        context)
                                                                    .width -
                                                                144) *
                                                            1 /
                                                            8);
                                                      }
                                                    }(),
                                                    height: 142.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .secondaryBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  8.0,
                                                                  16.0,
                                                                  8.0,
                                                                  16.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        8.0),
                                                            child: Container(
                                                              width: 54.0,
                                                              height: 54.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .grey,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            0.0),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  fadeInDuration:
                                                                      Duration(
                                                                          milliseconds:
                                                                              200),
                                                                  fadeOutDuration:
                                                                      Duration(
                                                                          milliseconds:
                                                                              200),
                                                                  imageUrl:
                                                                      '${FFAppConstants.imageBaseURL}${getJsonField(
                                                                    categoryListItem,
                                                                    r'''$.image''',
                                                                  ).toString()}',
                                                                  width: 32.0,
                                                                  height: 32.0,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  alignment:
                                                                      Alignment(
                                                                          0.0,
                                                                          0.0),
                                                                  errorWidget: (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Image
                                                                          .asset(
                                                                    'assets/images/error_image.png',
                                                                    width: 32.0,
                                                                    height:
                                                                        32.0,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    alignment:
                                                                        Alignment(
                                                                            0.0,
                                                                            0.0),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0.0, 0.0),
                                                            child: Text(
                                                              getJsonField(
                                                                categoryListItem,
                                                                r'''$.name''',
                                                              ).toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Roboto',
                                                                    letterSpacing:
                                                                        0.0,
                                                                    useGoogleFonts:
                                                                        false,
                                                                  ),
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            height: 8.0)),
                                                      ),
                                                    ),
                                                  ),
                                                ).animateOnPageLoad(animationsMap[
                                                    'containerOnPageLoadAnimation']!);
                                              }),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
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
          ],
        ),
      ),
    );
  }
}
