import '';
import '/backend/api_requests/api_calls.dart';
import '/componants/app_bar/app_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'user_verification_screen_model.dart';
export 'user_verification_screen_model.dart';

class UserVerificationScreenWidget extends StatefulWidget {
  const UserVerificationScreenWidget({
    super.key,
    this.useremail,
    required this.password,
  });

  final String? useremail;
  final String? password;

  static String routeName = 'user_verification_screen';
  static String routePath = '/userVerificationScreen';

  @override
  State<UserVerificationScreenWidget> createState() =>
      _UserVerificationScreenWidgetState();
}

class _UserVerificationScreenWidgetState
    extends State<UserVerificationScreenWidget> {
  late UserVerificationScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserVerificationScreenModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.timerController.onResetTimer();

      _model.timerController.onStartTimer();
    });

    _model.pinCodeFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
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
                      title: 'Verification',
                      backIcon: false,
                    ),
                  ),
                  Flexible(
                    child: Form(
                      key: _model.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(
                            0,
                            24.0,
                            0,
                            0,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 26.0),
                              child: Text(
                                'We will send you a 4 digit one time password in your email address check now',
                                textAlign: TextAlign.center,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Roboto',
                                      fontSize: 17.0,
                                      letterSpacing: 0.0,
                                      useGoogleFonts: false,
                                      lineHeight: 1.2,
                                    ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: RichText(
                                  textScaler: MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Code sent to ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Roboto',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .black,
                                              fontSize: 17.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.normal,
                                              useGoogleFonts: false,
                                            ),
                                      ),
                                      TextSpan(
                                        text: widget.useremail!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17.0,
                                        ),
                                      )
                                    ],
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Roboto',
                                          letterSpacing: 0.0,
                                          useGoogleFonts: false,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 20.0, 0.0, 0.0),
                              child: PinCodeTextField(
                                autoDisposeControllers: false,
                                appContext: context,
                                length: 4,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .override(
                                      fontFamily: 'Roboto',
                                      letterSpacing: 0.0,
                                      useGoogleFonts: false,
                                    ),
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                enableActiveFill: false,
                                autoFocus: true,
                                focusNode: _model.pinCodeFocusNode,
                                enablePinAutofill: false,
                                errorTextSpace: 16.0,
                                showCursor: true,
                                cursorColor:
                                    FlutterFlowTheme.of(context).primary,
                                obscureText: false,
                                hintCharacter: '●',
                                keyboardType: TextInputType.number,
                                pinTheme: PinTheme(
                                  fieldHeight: 50.0,
                                  fieldWidth: 50.0,
                                  borderWidth: 1.0,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12.0),
                                    bottomRight: Radius.circular(12.0),
                                    topLeft: Radius.circular(12.0),
                                    topRight: Radius.circular(12.0),
                                  ),
                                  shape: PinCodeFieldShape.box,
                                  activeColor:
                                      FlutterFlowTheme.of(context).black,
                                  inactiveColor:
                                      FlutterFlowTheme.of(context).black20,
                                  selectedColor:
                                      FlutterFlowTheme.of(context).primary,
                                ),
                                controller: _model.pinCodeController,
                                onChanged: (_) {},
                                autovalidateMode: AutovalidateMode.disabled,
                                validator: _model.pinCodeControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 30.0, 0.0, 0.0),
                              child: FFButtonWidget(
                                onPressed: () async {
                                  if (_model.formKey.currentState == null ||
                                      !_model.formKey.currentState!
                                          .validate()) {
                                    return;
                                  }
                                  _model.message = await QuizGroup
                                      .userverificationApiCall
                                      .call(
                                    email: widget.useremail,
                                    otp: int.tryParse(
                                        _model.pinCodeController!.text),
                                    deviceId: FFAppState().deviceId,
                                    registrationToken: FFAppState().tokenFcm,
                                  );

                                  if (QuizGroup.userverificationApiCall.success(
                                        (_model.message?.jsonBody ?? ''),
                                      ) ==
                                      2) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          QuizGroup.userverificationApiCall
                                              .message(
                                            (_model.message?.jsonBody ?? ''),
                                          )!,
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(context)
                                                .primaryText,
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 2000),
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondary,
                                      ),
                                    );
                                  } else {
                                    if (QuizGroup.userverificationApiCall
                                            .success(
                                          (_model.message?.jsonBody ?? ''),
                                        ) ==
                                        1) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            QuizGroup.userverificationApiCall
                                                .message(
                                              (_model.message?.jsonBody ?? ''),
                                            )!,
                                            style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                            ),
                                          ),
                                          duration:
                                              Duration(milliseconds: 4000),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondary,
                                        ),
                                      );
                                      _model.loginRes = await QuizGroup
                                          .usersigninApiCall
                                          .call(
                                        email: widget.useremail,
                                        password: widget.password,
                                        deviceId: FFAppState().deviceId,
                                        registrationToken:
                                            FFAppState().tokenFcm,
                                      );

                                      if (QuizGroup.usersigninApiCall.success(
                                            (_model.loginRes?.jsonBody ?? ''),
                                          ) ==
                                          2) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              QuizGroup.usersigninApiCall
                                                  .message(
                                                (_model.loginRes?.jsonBody ??
                                                    ''),
                                              )!,
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                            ),
                                            duration:
                                                Duration(milliseconds: 2000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      } else {
                                        if (QuizGroup.usersigninApiCall.success(
                                              (_model.loginRes?.jsonBody ?? ''),
                                            ) ==
                                            1) {
                                          _model.userRes = await QuizGroup
                                              .getuserApiCall
                                              .call(
                                            userId: getJsonField(
                                              QuizGroup.usersigninApiCall
                                                  .userDetails(
                                                (_model.loginRes?.jsonBody ??
                                                    ''),
                                              ),
                                              r'''$.id''',
                                            ).toString(),
                                            token: QuizGroup.usersigninApiCall
                                                .token(
                                              (_model.loginRes?.jsonBody ?? ''),
                                            ),
                                          );

                                          if (QuizGroup.getuserApiCall.success(
                                                (_model.userRes?.jsonBody ??
                                                    ''),
                                              ) ==
                                              2) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  QuizGroup.getuserApiCall
                                                      .message(
                                                    (_model.userRes?.jsonBody ??
                                                        ''),
                                                  )!,
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryText,
                                                  ),
                                                ),
                                                duration: Duration(
                                                    milliseconds: 2000),
                                                backgroundColor:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                              ),
                                            );
                                          } else {
                                            if (QuizGroup.getuserApiCall
                                                    .success(
                                                  (_model.userRes?.jsonBody ??
                                                      ''),
                                                ) ==
                                                1) {
                                              FFAppState().isLogin = true;
                                              FFAppState().userId =
                                                  getJsonField(
                                                QuizGroup.usersigninApiCall
                                                    .userDetails(
                                                  (_model.loginRes?.jsonBody ??
                                                      ''),
                                                ),
                                                r'''$.id''',
                                              ).toString();
                                              FFAppState().userDetils =
                                                  QuizGroup.getuserApiCall
                                                      .userCred(
                                                (_model.userRes?.jsonBody ??
                                                    ''),
                                              );
                                              FFAppState().currentPassword =
                                                  widget.password!;
                                              FFAppState().loginToken =
                                                  QuizGroup.usersigninApiCall
                                                      .token(
                                                (_model.loginRes?.jsonBody ??
                                                    ''),
                                              )!;
                                              FFAppState().update(() {});
                                              safeSetState(() {
                                                _model.pinCodeController
                                                    ?.clear();
                                              });

                                              context.goNamed(
                                                  HomeScreenWidget.routeName);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    QuizGroup.getuserApiCall
                                                        .message(
                                                      (_model.userRes
                                                              ?.jsonBody ??
                                                          ''),
                                                    )!,
                                                    style: TextStyle(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primaryText,
                                                    ),
                                                  ),
                                                  duration: Duration(
                                                      milliseconds: 2000),
                                                  backgroundColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            QuizGroup.userverificationApiCall
                                                .message(
                                              (_model.message?.jsonBody ?? ''),
                                            )!,
                                            style: TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                            ),
                                          ),
                                          duration:
                                              Duration(milliseconds: 2000),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context)
                                                  .secondary,
                                        ),
                                      );
                                    }
                                  }

                                  safeSetState(() {});
                                },
                                text: 'Verify',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 56.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  color: FlutterFlowTheme.of(context).primary,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Roboto',
                                        color:
                                            FlutterFlowTheme.of(context).white,
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        useGoogleFonts: false,
                                        lineHeight: 1.2,
                                      ),
                                  elevation: 0.0,
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 30.0, 0.0, 16.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    if (_model.show) {
                                      _model.apiResultdb9 =
                                          await QuizGroup.resendOTPCall.call(
                                        email: widget.useremail,
                                      );

                                      if (QuizGroup.resendOTPCall.success(
                                            (_model.apiResultdb9?.jsonBody ??
                                                ''),
                                          ) ==
                                          2) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              QuizGroup.resendOTPCall.message(
                                                (_model.apiResultdb9
                                                        ?.jsonBody ??
                                                    ''),
                                              )!,
                                              style: TextStyle(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                            ),
                                            duration:
                                                Duration(milliseconds: 2000),
                                            backgroundColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondary,
                                          ),
                                        );
                                      } else {
                                        if (QuizGroup.resendOTPCall.success(
                                              (_model.apiResultdb9?.jsonBody ??
                                                  ''),
                                            ) ==
                                            1) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                QuizGroup.resendOTPCall.message(
                                                  (_model.apiResultdb9
                                                          ?.jsonBody ??
                                                      ''),
                                                )!,
                                                style: TextStyle(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                ),
                                              ),
                                              duration:
                                                  Duration(milliseconds: 2000),
                                              backgroundColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                            ),
                                          );
                                          _model.timerController.onResetTimer();

                                          _model.timerController.onStartTimer();
                                          _model.show = false;
                                          safeSetState(() {});
                                        }
                                      }
                                    }

                                    safeSetState(() {});
                                  },
                                  child: RichText(
                                    textScaler:
                                        MediaQuery.of(context).textScaler,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Don\'t get code? ',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Roboto',
                                                color: _model.show
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .black
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .black10,
                                                fontSize: 17.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                useGoogleFonts: false,
                                              ),
                                        ),
                                        TextSpan(
                                          text: ' Resend code',
                                          style: TextStyle(
                                            color: _model.show
                                                ? FlutterFlowTheme.of(context)
                                                    .warning
                                                : FlutterFlowTheme.of(context)
                                                    .black10,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17.0,
                                          ),
                                        )
                                      ],
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Roboto',
                                            fontSize: 17.0,
                                            letterSpacing: 0.0,
                                            useGoogleFonts: false,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: FlutterFlowTimer(
                                initialTime: _model.timerInitialTimeMs,
                                getDisplayTime: (value) =>
                                    StopWatchTimer.getDisplayTime(
                                  value,
                                  hours: false,
                                  milliSecond: false,
                                ),
                                controller: _model.timerController,
                                updateStateInterval:
                                    Duration(milliseconds: 1000),
                                onChanged: (value, displayTime, shouldUpdate) {
                                  _model.timerMilliseconds = value;
                                  _model.timerValue = displayTime;
                                  if (shouldUpdate) safeSetState(() {});
                                },
                                onEnded: () async {
                                  _model.show = true;
                                  safeSetState(() {});
                                  _model.timerController.onStopTimer();
                                },
                                textAlign: TextAlign.start,
                                style: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .override(
                                      fontFamily: 'Roboto',
                                      color:
                                          FlutterFlowTheme.of(context).warning,
                                      fontSize: 20.0,
                                      letterSpacing: 0.0,
                                      useGoogleFonts: false,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
