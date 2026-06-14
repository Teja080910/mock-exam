import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'shimmer_ad_model.dart';
export 'shimmer_ad_model.dart';

class ShimmerAdWidget extends StatefulWidget {
  const ShimmerAdWidget({super.key});

  @override
  State<ShimmerAdWidget> createState() => _ShimmerAdWidgetState();
}

class _ShimmerAdWidgetState extends State<ShimmerAdWidget> {
  late ShimmerAdModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ShimmerAdModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        0,
        10.0,
        0,
        10.0,
      ),
      primary: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ].divide(SizedBox(height: 16.0)),
    );
  }
}
