import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

        
        // Logged-in users go straight to the home screen. Everyone else goes
        // straight to the login screen - the onboarding slides are no longer
        // shown (promos are handled by the app-open poster popup instead).
        if (FFAppState().isLogin == true && FFAppState().loginToken.isNotEmpty) {
          // Skip ad validation and set default values
          FFAppState().isBannerAd = 0;
          FFAppState().isInterstialAd = 0;
          FFAppState().isRewardedVideoAd = 0;
          FFAppState().rewardedPoints = 0;
          FFAppState().update(() {});
          context.goNamed(HomeScreenWidget.routeName);
        } else {
          FFAppState().isInite = true;
          FFAppState().update(() {});
          context.goNamed(LoginScreenWidget.routeName);
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
