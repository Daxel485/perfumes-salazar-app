import '/backend/backend.dart';
import '/components/button/button_widget.dart';
import '/components/note_tag/note_tag_widget.dart';
import '/components/size_chip/size_chip_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'detalle_de_producto_widget.dart' show DetalleDeProductoWidget;
import 'package:cloud_firestore/cloud_firestore.dart' hide Type;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DetalleDeProductoModel extends FlutterFlowModel<DetalleDeProductoWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for NoteTag.
  late NoteTagModel noteTagModel;
  // Model for SizeChip.
  late SizeChipModel sizeChipModel1;
  // Model for SizeChip.
  late SizeChipModel sizeChipModel2;
  // Model for SizeChip.
  late SizeChipModel sizeChipModel3;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    noteTagModel = createModel(context, () => NoteTagModel());
    sizeChipModel1 = createModel(context, () => SizeChipModel());
    sizeChipModel2 = createModel(context, () => SizeChipModel());
    sizeChipModel3 = createModel(context, () => SizeChipModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    noteTagModel.dispose();
    sizeChipModel1.dispose();
    sizeChipModel2.dispose();
    sizeChipModel3.dispose();
    buttonModel.dispose();
  }
}
