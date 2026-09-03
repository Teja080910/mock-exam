import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class AppDialogShell extends StatelessWidget {
  const AppDialogShell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 16.0),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24.0),
      elevation: 8,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
