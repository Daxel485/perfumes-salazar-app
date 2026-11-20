import '/components/bottom_nav/bottom_nav_widget.dart';
import '/components/bottom_nav_child3/bottom_nav_child3_widget.dart';
import '/components/button/button_widget.dart';
import '/components/favorite_card/favorite_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'favoritos_widget.dart' show FavoritosWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FavoritosModel extends FlutterFlowModel<FavoritosWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for FavoriteCard.
  late FavoriteCardModel favoriteCardModel1;
  // Model for FavoriteCard.
  late FavoriteCardModel favoriteCardModel2;
  // Model for FavoriteCard.
  late FavoriteCardModel favoriteCardModel3;
  // Model for FavoriteCard.
  late FavoriteCardModel favoriteCardModel4;
  // Model for Button.
  late ButtonModel buttonModel1;
  // Model for Button.
  late ButtonModel buttonModel2;
  // Model for BottomNav.
  late BottomNavModel bottomNavModel;

  @override
  void initState(BuildContext context) {
    favoriteCardModel1 = createModel(context, () => FavoriteCardModel());
    favoriteCardModel2 = createModel(context, () => FavoriteCardModel());
    favoriteCardModel3 = createModel(context, () => FavoriteCardModel());
    favoriteCardModel4 = createModel(context, () => FavoriteCardModel());
    buttonModel1 = createModel(context, () => ButtonModel());
    buttonModel2 = createModel(context, () => ButtonModel());
    bottomNavModel = createModel(context, () => BottomNavModel());
  }

  @override
  void dispose() {
    favoriteCardModel1.dispose();
    favoriteCardModel2.dispose();
    favoriteCardModel3.dispose();
    favoriteCardModel4.dispose();
    buttonModel1.dispose();
    buttonModel2.dispose();
    bottomNavModel.dispose();
  }
}
