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
import 'category_viewall_model.dart';
import '/flutter_flow/nav/serialization_util.dart';
export 'category_viewall_model.dart';

class CurrentAffairsWidget extends StatefulWidget {
  const CurrentAffairsWidget({super.key});

  static String routeName = 'current_affairs';
  static String routePath = '/currentAffairs';

  @override
  State<CurrentAffairsWidget> createState() => _CurrentAffairsWidgetState();
}

class _CurrentAffairsWidgetState extends State<CurrentAffairsWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};
  final String currentAffairsCategoryId = '68d67ba5d6d9bc79cbfe054a';

  @override
  void initState() {
    super.initState();
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
            AppBarWidget(
              title: 'Current Affairs',
              backIcon: true,
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (FFAppState().connected == true) {
                    return FutureBuilder<ApiCallResponse>(
                      future: GetquizbycategoryCall.call(
                        categoryId: currentAffairsCategoryId,
                        token: FFAppState().loginToken,
                      ),
                      builder: (context, snapshot) {
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
                        final quizResponse = snapshot.data!;
                        final quizList = GetquizbycategoryCall.quizDetailsList(
                              quizResponse.jsonBody,
                            )?.toList() ?? [];
                        if (quizList.isEmpty) {
                          return Center(
                            child: Text(
                              'No quizzes found for Current Affairs.',
                              style: FlutterFlowTheme.of(context).bodyMedium,
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: EdgeInsets.all(16.0),
                          itemCount: quizList.length,
                          separatorBuilder: (_, __) => SizedBox(height: 16.0),
                          itemBuilder: (context, index) {
                            final quiz = quizList[index];
                            return InkWell(
                              onTap: () {
                                context.pushNamed(
                                  QuizQuestionsScreenWidget.routeName,
                                  queryParameters: {
                                    'quizID': serializeParam(getJsonField(quiz, r'$._id').toString(), ParamType.String),
                                    'title': serializeParam(getJsonField(quiz, r'$.name').toString(), ParamType.String),
                                    'catId': serializeParam(currentAffairsCategoryId, ParamType.String),
                                    'image': serializeParam(getJsonField(quiz, r'$.image').toString(), ParamType.String),
                                    'quizTime': serializeParam(getJsonField(quiz, r'$.minutes_per_quiz').toString(), ParamType.String),
                                    'description': serializeParam(getJsonField(quiz, r'$.description').toString(), ParamType.String),
                                    'ques': serializeParam(getJsonField(quiz, r'$.total_questions'), ParamType.int),
                                    'timerStatus': serializeParam(getJsonField(quiz, r'$.timer_status'), ParamType.int),
                                  }.withoutNulls,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl: '${FFAppConstants.imageBaseURL}${getJsonField(quiz, r'$.image').toString()}',
                                        width: 54.0,
                                        height: 54.0,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, error, stackTrace) => Image.asset(
                                          'assets/images/error_image.png',
                                          width: 54.0,
                                          height: 54.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getJsonField(quiz, r'$.name').toString(),
                                            style: FlutterFlowTheme.of(context).titleLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0,
                                            ),
                                          ),
                                          SizedBox(height: 4.0),
                                          Text(
                                            'Questions: 0${getJsonField(quiz, r'$.total_questions')}',
                                            style: FlutterFlowTheme.of(context).bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, size: 20.0, color: FlutterFlowTheme.of(context).primary),
                                  ],
                                ),
                              ),
                            ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation']!);
                          },
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