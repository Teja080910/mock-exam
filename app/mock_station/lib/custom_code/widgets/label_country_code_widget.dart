// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/services.dart';

class LabelCountryCodeWidget extends StatefulWidget {
  const LabelCountryCodeWidget({
    super.key,
    this.width,
    this.height,
    this.initialValue,
    required this.borderRadiuos,
    this.code,
  });

  final double? width;
  final double? height;
  final String? initialValue;
  final double borderRadiuos;
  final String? code;

  @override
  State<LabelCountryCodeWidget> createState() => _LabelCountryCodeWidgetState();
}

class _LabelCountryCodeWidgetState extends State<LabelCountryCodeWidget> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Add a form key

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: IntlPhoneField(
        showCountryFlag: false,
        dropdownIcon: Icon(
          Icons.keyboard_arrow_down,
          size: 24,
          color: FlutterFlowTheme.of(context).primaryText,
        ),
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Display',
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 17,
              fontWeight: FontWeight.normal,
              useGoogleFonts: false,
              lineHeight: 1.5,
            ),
        dropdownIconPosition: IconPosition.trailing,
        dropdownTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF Pro Display',
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w400,
              useGoogleFonts: false,
              lineHeight: 1.5,
            ),
        dropdownDecoration:
            BoxDecoration(borderRadius: BorderRadius.circular(12)),
        initialValue: widget.initialValue ?? '',
        flagsButtonMargin: EdgeInsets.only(left: 16),
        keyboardType: TextInputType.phone,
        cursorColor: FlutterFlowTheme.of(context).primaryText,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
        decoration: InputDecoration(
          // labelText: "Phone number",
          // labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
          //       fontFamily: 'SF Pro Display',
          //       color: FlutterFlowTheme.of(context).grey400,
          //       fontSize: 13,
          //       useGoogleFonts: false,
          //     ),
          alignLabelWithHint: false,
          label: Text(
            "Phone number",
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  fontFamily: 'SF Pro Display',
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 15,
                  useGoogleFonts: false,
                  lineHeight: 1.2,
                ),
          ),
          hintText: 'Phone number',
          hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                fontFamily: 'SF Pro Display',
                color: FlutterFlowTheme.of(context).black40,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                useGoogleFonts: false,
                lineHeight: 1.5,
              ),
          counterText: '',
          errorStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Roboto',
                color: FlutterFlowTheme.of(context).error,
                fontSize: 15.0,
                letterSpacing: 0.0,
                useGoogleFonts: false,
              ),
          contentPadding:
              EdgeInsets.only(right: 16, top: 16, bottom: 16, left: 16),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadiuos),
              borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary, width: 1)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadiuos),
              borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).black20, width: 1)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadiuos),
              borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).error, width: 1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadiuos),
              borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).black20, width: 1)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadiuos),
              borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).black20, width: 1)),
        ),
        initialCountryCode: widget.code ?? 'IN',
        validator: (num) {
          if (num == "") {
            return "Please enter valid number ";
          } else {
            return "Please enter valid number ";
          }
        },
        invalidNumberMessage: "Please enter valid phone number",
        onChanged: (value) {
          FFAppState().update(() {
            FFAppState().phone = value.number;
          });
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onCountryChanged: (value) {
          FFAppState().update(() {
            FFAppState().countryCode = value.dialCode.toString();
            FFAppState().country = value.code.toString();
            FFAppState().countryName = value.code.toString();
          });
        },
      ),
    );
  }
}
