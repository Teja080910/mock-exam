import '/backend/api_requests/api_calls.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'helpline_center_screen_model.dart';
export 'helpline_center_screen_model.dart';

class HelplineCenterScreenWidget extends StatefulWidget {
  const HelplineCenterScreenWidget({super.key});

  static String routeName = 'helpline_center_screen';
  static String routePath = '/helplineCenterScreen';

  @override
  State<HelplineCenterScreenWidget> createState() =>
      _HelplineCenterScreenWidgetState();
}

class _HelplineCenterScreenWidgetState extends State<HelplineCenterScreenWidget>
    with TickerProviderStateMixin {
  late HelplineCenterScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HelplineCenterScreenModel());

    animationsMap.addAll({
      'listViewOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
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
                      title: 'About us ',
                      backIcon: true,
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<ApiCallResponse>(
                      future: (_model.apiRequestCompleter ??=
                              Completer<ApiCallResponse>()
                                ..complete(QuizGroup.getAllPagesCall.call()))
                          .future,
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
                        final containerGetAllPagesResponse = snapshot.data!;

                        return Container(
                          decoration: BoxDecoration(),
                          child: Builder(
                            builder: (context) {
                              if (QuizGroup.getAllPagesCall.success(
                                    containerGetAllPagesResponse.jsonBody,
                                  ) ==
                                  2) {
                                return Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: Text(
                                      valueOrDefault<String>(
                                        QuizGroup.getAllPagesCall.message(
                                          containerGetAllPagesResponse.jsonBody,
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
                                    key: Key('RefreshIndicator_bz8up3qe'),
                                    color: FlutterFlowTheme.of(context).primary,
                                    backgroundColor:
                                        FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    onRefresh: () async {
                                      safeSetState(() =>
                                          _model.apiRequestCompleter = null);
                                      await _model.waitForApiRequestCompleted();
                                    },
                                    child: ListView(
                                      padding: EdgeInsets.fromLTRB(
                                        0,
                                        16.0,
                                        0,
                                        16.0,
                                      ),
                                      primary: false,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      children: [
                                        custom_widgets.HtmlConverterExp(
                                          width: double.infinity,
                                          height: 50.0,
                                          text:
                                              QuizGroup.getAllPagesCall.aboutUs(
                                            containerGetAllPagesResponse
                                                .jsonBody,
                                          ) ?? '',
                                        ),
                                        const SizedBox(height: 24.0),
                                        Container(
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(color: const Color(0xFFE5E7EB)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Contact Support',
                                                style: TextStyle(
                                                  fontSize: FFFont.f16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              const Text(
                                                'If you have any questions, feedback, or need assistance, please feel free to contact us at:',
                                                style: TextStyle(
                                                  fontSize: FFFont.f14,
                                                  color: Colors.black54,
                                                  height: 1.4,
                                                ),
                                              ),
                                              const SizedBox(height: 16.0),
                                              InkWell(
                                                onTap: () {
                                                  launchURL('mailto:freshersfind@gmail.com');
                                                },
                                                borderRadius: BorderRadius.circular(8.0),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFEFF6FF),
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    border: Border.all(color: const Color(0xFFBFDBFE)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.mail_outline_rounded,
                                                        color: Color(0xFF2563EB),
                                                        size: 18.0,
                                                      ),
                                                      const SizedBox(width: 8.0),
                                                      const Text(
                                                        'freshersfind@gmail.com',
                                                        style: TextStyle(
                                                          color: Color(0xFF2563EB),
                                                          fontSize: FFFont.f14,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animateOnPageLoad(animationsMap[
                                      'listViewOnPageLoadAnimation']!),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
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
