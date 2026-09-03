import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'code_verification_dialog_model.dart';
import '/componants/app_dialog_shell/app_dialog_shell.dart';
export 'code_verification_dialog_model.dart';

class CodeVerificationDialogWidget extends StatefulWidget {
  const CodeVerificationDialogWidget({super.key});

  @override
  State<CodeVerificationDialogWidget> createState() =>
      _CodeVerificationDialogWidgetState();
}

class _CodeVerificationDialogWidgetState
    extends State<CodeVerificationDialogWidget> {
  late CodeVerificationDialogModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CodeVerificationDialogModel());

    _model.pinCodeFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return AppDialogShell(
    child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter your verification code',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Roboto',
                        fontSize: FFFont.f20,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                        useGoogleFonts: false,
                        lineHeight: 1.5,
                      ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                  child: Text(
                    'Please enter the OTP sent to your registered email address',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Roboto',
                          fontSize: FFFont.f18,
                          letterSpacing: 0.0,
                          useGoogleFonts: false,
                          lineHeight: 1.5,
                        ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
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
                                  color: FlutterFlowTheme.of(context).black,
                                  fontSize: FFFont.f18,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  useGoogleFonts: false,
                                ),
                          ),
                          TextSpan(
                            text: getJsonField(
                              FFAppState().userDetils,
                              r'''$.email''',
                            ).toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: FFFont.f18,
                            ),
                          )
                        ],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Roboto',
                              letterSpacing: 0.0,
                              useGoogleFonts: false,
                            ),
                      ),
                    ),
                  ),
                ),
                Form(
                  key: _model.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                    child: PinCodeTextField(
                      autoDisposeControllers: false,
                      appContext: context,
                      length: 4,
                      textStyle:
                          FlutterFlowTheme.of(context).bodyLarge.override(
                                fontFamily: 'Roboto',
                                letterSpacing: 0.0,
                                useGoogleFonts: false,
                              ),
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      enableActiveFill: false,
                      autoFocus: true,
                      focusNode: _model.pinCodeFocusNode,
                      enablePinAutofill: false,
                      errorTextSpace: 16.0,
                      showCursor: true,
                      cursorColor: FlutterFlowTheme.of(context).primary,
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
                        activeColor: FlutterFlowTheme.of(context).black,
                        inactiveColor: FlutterFlowTheme.of(context).black20,
                        selectedColor: FlutterFlowTheme.of(context).primary,
                      ),
                      controller: _model.pinCodeController,
                      onChanged: (_) {},
                      autovalidateMode: AutovalidateMode.disabled,
                      validator: _model.pinCodeControllerValidator
                          .asValidator(context),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (_model.formKey.currentState == null ||
                          !_model.formKey.currentState!.validate()) {
                        return;
                      }
                      _model.userVerifyRes =
                          await QuizGroup.userverificationApiCall.call(
                        email: getJsonField(
                          FFAppState().userDetils,
                          r'''$.email''',
                        ).toString(),
                        otp: int.tryParse(_model.pinCodeController!.text),
                        deviceId: FFAppState().deviceId,
                        registrationToken: FFAppState().tokenFcm,
                      );

                      if (QuizGroup.userverificationApiCall.success(
                            (_model.userVerifyRes?.jsonBody ?? ''),
                          ) ==
                          1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              QuizGroup.userverificationApiCall.message(
                                (_model.userVerifyRes?.jsonBody ?? ''),
                              )!,
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                            duration: Duration(milliseconds: 4000),
                            backgroundColor:
                                FlutterFlowTheme.of(context).secondary,
                          ),
                        );
                        _model.userLoginRes =
                            await QuizGroup.usersigninApiCall.call(
                          email: getJsonField(
                            FFAppState().userDetils,
                            r'''$.email''',
                          ).toString(),
                          password: FFAppState().currentPassword,
                          registrationToken: FFAppState().tokenFcm,
                          deviceId: FFAppState().deviceId,
                        );

                        if (QuizGroup.usersigninApiCall.success(
                              (_model.userLoginRes?.jsonBody ?? ''),
                            ) ==
                            1) {
                          FFAppState().loginToken =
                              QuizGroup.usersigninApiCall.token(
                            (_model.userLoginRes?.jsonBody ?? ''),
                          )!;
                          FFAppState().update(() {});
                        }
                        FFAppState().clearCoinsCache();
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              QuizGroup.userverificationApiCall.message(
                                (_model.userVerifyRes?.jsonBody ?? ''),
                              )!,
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                            duration: Duration(milliseconds: 4000),
                            backgroundColor:
                                FlutterFlowTheme.of(context).secondary,
                          ),
                        );
                      }

                      safeSetState(() {});
                    },
                    text: 'Verify',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Roboto',
                                color: FlutterFlowTheme.of(context).white,
                                fontSize: FFFont.f18,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                useGoogleFonts: false,
                                lineHeight: 1.2,
                              ),
                      elevation: 0.0,
                      borderSide: BorderSide(
                        color: const Color.fromARGB(0, 206, 178, 178),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
