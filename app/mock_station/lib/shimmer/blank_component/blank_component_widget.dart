import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'blank_component_model.dart';
export 'blank_component_model.dart';

class BlankComponentWidget extends StatefulWidget {
  const BlankComponentWidget({super.key});

  @override
  State<BlankComponentWidget> createState() => _BlankComponentWidgetState();
}

class _BlankComponentWidgetState extends State<BlankComponentWidget> {
  late BlankComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BlankComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.0,
      height: 0.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
    );
  }
}
