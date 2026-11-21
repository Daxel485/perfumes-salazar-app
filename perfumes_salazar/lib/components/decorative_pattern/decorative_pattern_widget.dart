import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'decorative_pattern_model.dart';
export 'decorative_pattern_model.dart';

class DecorativePatternWidget extends StatefulWidget {
  const DecorativePatternWidget({
    super.key,
    Color? color,
  }) : this.color = color ?? const Color(0x00000000);

  final Color color;

  @override
  State<DecorativePatternWidget> createState() =>
      _DecorativePatternWidgetState();
}

class _DecorativePatternWidgetState extends State<DecorativePatternWidget> {
  late DecorativePatternModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DecorativePatternModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.diamond_rounded,
            color: valueOrDefault<Color>(
              widget!.color,
              FlutterFlowTheme.of(context).secondary40,
            ),
            size: 12.0,
          ),
          Expanded(
            flex: 1,
            child: Divider(
              height: 16.0,
              thickness: 1.0,
              indent: 16.0,
              endIndent: 16.0,
              color: FlutterFlowTheme.of(context).alternate,
            ),
          ),
          Icon(
            Icons.diamond_rounded,
            color: valueOrDefault<Color>(
              widget!.color,
              FlutterFlowTheme.of(context).secondary40,
            ),
            size: 12.0,
          ),
        ],
      ),
    );
  }
}
