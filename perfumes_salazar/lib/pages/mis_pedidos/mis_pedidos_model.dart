import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/bottom_nav_child5/bottom_nav_child5_widget.dart';
import '/components/order_card/order_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'mis_pedidos_widget.dart' show MisPedidosWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MisPedidosModel extends FlutterFlowModel<MisPedidosWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for OrderCard.
  late OrderCardModel orderCardModel1;
  // Model for OrderCard.
  late OrderCardModel orderCardModel2;
  // Model for OrderCard.
  late OrderCardModel orderCardModel3;
  // Model for OrderCard.
  late OrderCardModel orderCardModel4;
  // Model for BottomNav.
  late BottomNavModel bottomNavModel;

  @override
  void initState(BuildContext context) {
    orderCardModel1 = createModel(context, () => OrderCardModel());
    orderCardModel2 = createModel(context, () => OrderCardModel());
    orderCardModel3 = createModel(context, () => OrderCardModel());
    orderCardModel4 = createModel(context, () => OrderCardModel());
    bottomNavModel = createModel(context, () => BottomNavModel());
  }

  @override
  void dispose() {
    orderCardModel1.dispose();
    orderCardModel2.dispose();
    orderCardModel3.dispose();
    orderCardModel4.dispose();
    bottomNavModel.dispose();
  }
}
