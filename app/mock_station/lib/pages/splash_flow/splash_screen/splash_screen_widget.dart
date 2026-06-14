import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'splash_screen_model.dart';
export 'splash_screen_model.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({super.key});

  static String routeName = 'splash_screen';
  static String routePath = '/splashScreen';

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget>
    with TickerProviderStateMixin {
  late SplashScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SplashScreenModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {

        // Add a timeout for the entire initialization process
        await Future.delayed(const Duration(milliseconds: 3000));
        
        try {
          await actions.getDeviceId();
        } catch (e) {
        }
        
        try {
          await actions.getFCM();
        } catch (e) {
        }
        
        try {
          await actions.counterAdAction();
        } catch (e) {
        }

        
        if (FFAppState().isInite == true) {
          if (FFAppState().isLogin == true && FFAppState().loginToken.isNotEmpty) {
            // Skip ad validation and set default values
            FFAppState().isBannerAd = 0;
            FFAppState().isInterstialAd = 0;
            FFAppState().isRewardedVideoAd = 0;
            FFAppState().rewardedPoints = 0;
            FFAppState().update(() {});
            context.goNamed(HomeScreenWidget.routeName);
          } else {
            context.goNamed(LoginScreenWidget.routeName);
          }
        } else {
          try {
            _model.introRes = await QuizGroup.getIntroAPICall.call().timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                return ApiCallResponse(
                  '{"success":0,"message":"Timeout getting intro data"}',
                  {'content-type': 'application/json'},
                  -1,
                );
              },
            );
            

            if (_model.introRes == null) {
              FFAppState().isInite = true;
              FFAppState().update(() {});
              context.goNamed(LoginScreenWidget.routeName);
              return;
            }

            if (_model.introRes?.statusCode == -1) {
              print('Intro API call failed with status code -1, proceeding to login...');
              FFAppState().isInite = true;
              FFAppState().update(() {});
              context.goNamed(LoginScreenWidget.routeName);
              return;
            }

            final success = QuizGroup.getIntroAPICall.success(
              (_model.introRes?.jsonBody ?? ''),
            );

            if (success == 1) {
              context.goNamed(
                OnBordingScreenWidget.routeName,
                queryParameters: {
                  'introsList': serializeParam(
                    QuizGroup.getIntroAPICall.introDetailsList(
                      (_model.introRes?.jsonBody ?? ''),
                    ),
                    ParamType.JSON,
                    isList: true,
                  ),
                }.withoutNulls,
              );
            } else {
              if (FFAppState().isLogin == true) {
                _model.getAds = await QuizGroup.getadssettingsApiCall.call(
                  token: FFAppState().loginToken,
                ).timeout(
                  const Duration(seconds: 10),
                  onTimeout: () {
                    print('Ad settings API call timed out after 10 seconds');
                    return ApiCallResponse(
                      '{"success":0,"message":"Timeout getting ad settings"}',
                      {'content-type': 'application/json'},
                      -1,
                    );
                  },
                );

                print('Ad Settings Response: ${_model.getAds?.jsonBody}');

                if (QuizGroup.getadssettingsApiCall.success(
                      (_model.getAds?.jsonBody ?? ''),
                    ) == 1) {
                  print('Ad settings successful, updating app state...');
                  FFAppState().isBannerAd = (QuizGroup.getadssettingsApiCall.banner(
                    (_model.getAds?.jsonBody ?? ''),
                  ) as int?) ?? 0;
                  FFAppState().isInterstialAd = (QuizGroup.getadssettingsApiCall.interstial(
                    (_model.getAds?.jsonBody ?? ''),
                  ) as int?) ?? 0;
                  FFAppState().isRewardedVideoAd = (QuizGroup.getadssettingsApiCall.rewarded(
                    (_model.getAds?.jsonBody ?? ''),
                  ) as int?) ?? 0;
                  FFAppState().rewardedPoints = (QuizGroup.getadssettingsApiCall.points(
                    (_model.getAds?.jsonBody ?? ''),
                  ) as int?) ?? 0;
                  FFAppState().update(() {});
                }

                print('Proceeding to home screen...');
                context.goNamed(HomeScreenWidget.routeName);
              } else {
                print('User is not logged in, proceeding to login screen...');
                FFAppState().isInite = true;
                FFAppState().update(() {});

                context.goNamed(LoginScreenWidget.routeName);
              }
            }
          } catch (e, stackTrace) {
            print('Error in intro API call: $e');
            print('Stack trace: $stackTrace');
            FFAppState().isInite = true;
            FFAppState().update(() {});
            context.goNamed(LoginScreenWidget.routeName);
          }
        }
      } catch (e) {
        print('Error in splash screen initialization: $e');
        // If anything fails, proceed to login screen
        FFAppState().isInite = true;
        FFAppState().update(() {});
        context.goNamed(LoginScreenWidget.routeName);
      }
    });

    animationsMap.addAll({
      'columnOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeIn,
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
        body: SafeArea(
          top: true,
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Image.asset(
                'assets/images/mock_test_horizontal_logo.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
