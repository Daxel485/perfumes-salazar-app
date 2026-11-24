import '/components/button/button_widget.dart';
import '/components/checkout_section/checkout_section_widget.dart';
import '/components/order_item/order_item_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'confirmar_pedido_widget.dart' show ConfirmarPedidoWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ConfirmarPedidoModel extends FlutterFlowModel<ConfirmarPedidoWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for OrderItem.
  late OrderItemModel orderItemModel1;
  // Model for OrderItem.
  late OrderItemModel orderItemModel2;
  // Model for CheckoutSection.
  late CheckoutSectionModel checkoutSectionModel1;
  // Model for CheckoutSection.
  late CheckoutSectionModel checkoutSectionModel2;
  // Model for Button.
  late ButtonModel buttonModel;

  @override
  void initState(BuildContext context) {
    orderItemModel1 = createModel(context, () => OrderItemModel());
    orderItemModel2 = createModel(context, () => OrderItemModel());
    checkoutSectionModel1 = createModel(context, () => CheckoutSectionModel());
    checkoutSectionModel2 = createModel(context, () => CheckoutSectionModel());
    buttonModel = createModel(context, () => ButtonModel());
  }

  @override
  void dispose() {
    orderItemModel1.dispose();
    orderItemModel2.dispose();
    checkoutSectionModel1.dispose();
    checkoutSectionModel2.dispose();
    buttonModel.dispose();
  }
}
