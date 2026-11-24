import '/components/admin_stat/admin_stat_widget.dart';
import '/components/button/button_widget.dart';
import '/components/product_row/product_row_widget.dart';
import '/components/tab_group/tab_group_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'panel_de_administraci_n_widget.dart' show PanelDeAdministraciNWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PanelDeAdministraciNModel
    extends FlutterFlowModel<PanelDeAdministraciNWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for AdminStat.
  late AdminStatModel adminStatModel1;
  // Model for AdminStat.
  late AdminStatModel adminStatModel2;
  // Model for TabGroup.
  late TabGroupModel tabGroupModel;
  // Model for TextField.
  late TextFieldModel textFieldModel;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for ProductRow.
  late ProductRowModel productRowModel1;
  // Model for ProductRow.
  late ProductRowModel productRowModel2;
  // Model for ProductRow.
  late ProductRowModel productRowModel3;
  // Model for ProductRow.
  late ProductRowModel productRowModel4;
  // Model for ProductRow.
  late ProductRowModel productRowModel5;
  // Model for Button.
  late ButtonModel buttonModel2;
  // Model for Button.
  late ButtonModel buttonModel3;

  @override
  void initState(BuildContext context) {
    adminStatModel1 = createModel(context, () => AdminStatModel());
    adminStatModel2 = createModel(context, () => AdminStatModel());
    tabGroupModel = createModel(context, () => TabGroupModel());
    textFieldModel = createModel(context, () => TextFieldModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    productRowModel1 = createModel(context, () => ProductRowModel());
    productRowModel2 = createModel(context, () => ProductRowModel());
    productRowModel3 = createModel(context, () => ProductRowModel());
    productRowModel4 = createModel(context, () => ProductRowModel());
    productRowModel5 = createModel(context, () => ProductRowModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    buttonModel3 = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    adminStatModel1.dispose();
    adminStatModel2.dispose();
    tabGroupModel.dispose();
    textFieldModel.dispose();
    buttonModel1.dispose();
    productRowModel1.dispose();
    productRowModel2.dispose();
    productRowModel3.dispose();
    productRowModel4.dispose();
    productRowModel5.dispose();
    buttonModel2.dispose();
    buttonModel3.dispose();
  }
}
