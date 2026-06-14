import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'shimmer_container_model.dart';
export 'shimmer_container_model.dart';

class ShimmerContainerWidget extends StatefulWidget {
  const ShimmerContainerWidget({super.key});

  @override
  State<ShimmerContainerWidget> createState() => _ShimmerContainerWidgetState();
}

class _ShimmerContainerWidgetState extends State<ShimmerContainerWidget>
    with TickerProviderStateMixin {
  late ShimmerContainerModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ShimmerContainerModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).black20,
            angle: 0.524,
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        loop: true,
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            color: FlutterFlowTheme.of(context).black20,
            angle: 0.524,
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Visibility(
      visible: FFAppState().isLogin == true,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.bounceOut,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(24.0),
          shape: BoxShape.rectangle,
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20.0,
                height: 20.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).lightGrey,
                  shape: BoxShape.circle,
                ),
              ).animateOnPageLoad(
                  animationsMap['containerOnPageLoadAnimation1']!),
              Container(
                width: 50.0,
                height: 20.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).lightGrey,
                  borderRadius: BorderRadius.circular(4.0),
                  shape: BoxShape.rectangle,
                ),
              ).animateOnPageLoad(
                  animationsMap['containerOnPageLoadAnimation2']!),
            ].divide(SizedBox(width: 4.0)).addToStart(SizedBox(width: 2.0)),
          ),
        ),
      ),
    );
  }
}
