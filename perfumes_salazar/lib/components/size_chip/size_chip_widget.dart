import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'size_chip_model.dart';
export 'size_chip_model.dart';

class SizeChipWidget extends StatefulWidget {
  const SizeChipWidget({
    super.key,
    String? ml,
    bool? selected,
  })  : this.ml = ml ?? '60 ml',
        this.selected = selected ?? false;

  final String ml;
  final bool selected;

  @override
  State<SizeChipWidget> createState() => _SizeChipWidgetState();
}

class _SizeChipWidgetState extends State<SizeChipWidget> {
  late SizeChipModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SizeChipModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: valueOrDefault<Color>(
          valueOrDefault<bool>(
            widget!.selected,
            false,
          )
              ? FlutterFlowTheme.of(context).secondary
              : Colors.transparent,
          Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(4.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: valueOrDefault<Color>(
            valueOrDefault<bool>(
              widget!.selected,
              false,
            )
                ? FlutterFlowTheme.of(context).secondary
                : FlutterFlowTheme.of(context).accent30,
            FlutterFlowTheme.of(context).accent30,
          ),
          width: valueOrDefault<double>(
            valueOrDefault<bool>(
              widget!.selected,
              false,
            )
                ? 1.0
                : 1.0,
            1.0,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 12.0),
        child: Container(
          child: Text(
            valueOrDefault<String>(
              widget!.ml,
              '60 ml',
            ),
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.josefinSans(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  ),
                  color: valueOrDefault<Color>(
                    valueOrDefault<bool>(
                      widget!.selected,
                      false,
                    )
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).secondary,
                    FlutterFlowTheme.of(context).secondary,
                  ),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  lineHeight: 1.3,
                ),
          ),
        ),
      ),
    );
  }
}
