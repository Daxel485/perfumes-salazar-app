import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/bottom_nav_child2/bottom_nav_child2_widget.dart';
import '/components/filter_tag/filter_tag_widget.dart';
import '/components/product_card/product_card_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'cat_logo_widget.dart' show CatLogoWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CatLogoModel extends FlutterFlowModel<CatLogoWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for TextField.
  late TextFieldModel textFieldModel;
  // Model for FilterTag.
  late FilterTagModel filterTagModel1;
  // Model for FilterTag.
  late FilterTagModel filterTagModel2;
  // Model for FilterTag.
  late FilterTagModel filterTagModel3;
  // Model for FilterTag.
  late FilterTagModel filterTagModel4;
  // Model for FilterTag.
  late FilterTagModel filterTagModel5;
  // Model for ProductCard.
  late ProductCardModel productCardModel1;
  // Model for ProductCard.
  late ProductCardModel productCardModel2;
  // Model for ProductCard.
  late ProductCardModel productCardModel3;
  // Model for ProductCard.
  late ProductCardModel productCardModel4;
  // Model for ProductCard.
  late ProductCardModel productCardModel5;
  // Model for ProductCard.
  late ProductCardModel productCardModel6;
  // Model for ProductCard.
  late ProductCardModel productCardModel7;
  // Model for ProductCard.
  late ProductCardModel productCardModel8;
  // Model for BottomNav.
  late BottomNavModel bottomNavModel;

  @override
  void initState(BuildContext context) {
    textFieldModel = createModel(context, () => TextFieldModel());
    filterTagModel1 = createModel(context, () => FilterTagModel());
    filterTagModel2 = createModel(context, () => FilterTagModel());
    filterTagModel3 = createModel(context, () => FilterTagModel());
    filterTagModel4 = createModel(context, () => FilterTagModel());
    filterTagModel5 = createModel(context, () => FilterTagModel());
    productCardModel1 = createModel(context, () => ProductCardModel());
    productCardModel2 = createModel(context, () => ProductCardModel());
    productCardModel3 = createModel(context, () => ProductCardModel());
    productCardModel4 = createModel(context, () => ProductCardModel());
    productCardModel5 = createModel(context, () => ProductCardModel());
    productCardModel6 = createModel(context, () => ProductCardModel());
    productCardModel7 = createModel(context, () => ProductCardModel());
    productCardModel8 = createModel(context, () => ProductCardModel());
    bottomNavModel = createModel(context, () => BottomNavModel());
  }

  @override
  void dispose() {
    textFieldModel.dispose();
    filterTagModel1.dispose();
    filterTagModel2.dispose();
    filterTagModel3.dispose();
    filterTagModel4.dispose();
    filterTagModel5.dispose();
    productCardModel1.dispose();
    productCardModel2.dispose();
    productCardModel3.dispose();
    productCardModel4.dispose();
    productCardModel5.dispose();
    productCardModel6.dispose();
    productCardModel7.dispose();
    productCardModel8.dispose();
    bottomNavModel.dispose();
  }
}
