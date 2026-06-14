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

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlConverter extends StatefulWidget {
  const HtmlConverter({super.key, this.width, this.height, required this.text});

  final double? width;
  final double? height;
  final String text;

  @override
  State<HtmlConverter> createState() => _HtmlConverterState();
}

class _HtmlConverterState extends State<HtmlConverter> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Html(
          data: widget.text.replaceAll("&quot;", '"'),
          onLinkTap: (url, attributes, element) {
            launchURL(url!);
          },
          style: {
            "p": Style(
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: FontSize(17),
              fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
              letterSpacing: 0.17,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w400,
            ),
          },
        ),
      ],
    );
  }
}
