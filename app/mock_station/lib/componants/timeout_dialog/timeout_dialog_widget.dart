import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'timeout_dialog_model.dart';
export 'timeout_dialog_model.dart';

class TimeoutDialogWidget extends StatefulWidget {
  const TimeoutDialogWidget({
    super.key,
    this.istimeout,
  });

  final Future Function()? istimeout;

  @override
  State<TimeoutDialogWidget> createState() => _TimeoutDialogWidgetState();
}

class _TimeoutDialogWidgetState extends State<TimeoutDialogWidget> {
  late TimeoutDialogModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TimeoutDialogModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Widget _buildConfettiDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            elevation: 8,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 104,
                        height: 96,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/Group_1171274967.svg',
                              width: 82.0,
                              height: 82.0,
                              fit: BoxFit.contain,
                            ),
                            Positioned(top: 4, left: 6, child: _buildConfettiDot(const Color(0xFF7C3AED), 8)), // purple
                            Positioned(top: 8, right: 8, child: _buildConfettiDot(const Color(0xFFF59E0B), 7)), // orange
                            Positioned(bottom: 6, left: 10, child: _buildConfettiDot(const Color(0xFFEC4899), 7)), // pink
                            Positioned(bottom: 10, right: 12, child: _buildConfettiDot(const Color(0xFF7C3AED), 6)), // purple
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        "Time's Up!",
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Roboto',
                              color: const Color(0xFF111827),
                              fontSize: FFFont.f24,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              useGoogleFonts: false,
                            ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 28.0, 0.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () async {
                              await widget.istimeout?.call();
                            },
                            text: 'View Test Result',
                            iconData: Icons.emoji_events_rounded,
                            options: FFButtonOptions(
                              height: 52.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 0.0, 24.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 8.0, 0.0),
                              iconSize: 20.0,
                              color: const Color(0xFF2563EB),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Roboto',
                                    color: Colors.white,
                                    fontSize: FFFont.f16,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    useGoogleFonts: false,
                                  ),
                              elevation: 2.0,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
