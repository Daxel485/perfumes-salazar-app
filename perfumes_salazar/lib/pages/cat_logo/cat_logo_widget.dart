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
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'cat_logo_model.dart';
export 'cat_logo_model.dart';

class CatLogoWidget extends StatefulWidget {
  const CatLogoWidget({super.key});

  static String routeName = 'CatLogo';
  static String routePath = '/catLogo';

  @override
  State<CatLogoWidget> createState() => _CatLogoWidgetState();
}

class _CatLogoWidgetState extends State<CatLogoWidget> {
  late CatLogoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CatLogoModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                shape: BoxShape.rectangle,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 16.0),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: Colors.transparent,
                            icon: Icon(
                              Icons.menu_rounded,
                              color: FlutterFlowTheme.of(context).secondary,
                              size: 24.0,
                            ),
                            onPressed: () {
                              print('IconButton pressed ...');
                            },
                          ),
                          Text(
                            'PERFUMES SALAZAR',
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                  font: GoogleFonts.poiretOne(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).secondary,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontStyle,
                                  decoration: TextDecoration.underline,
                                  lineHeight: 1.3,
                                ),
                          ),
                          FlutterFlowIconButton(
                            borderRadius: 8.0,
                            buttonSize: 40.0,
                            fillColor: Colors.transparent,
                            icon: Icon(
                              Icons.shopping_cart_rounded,
                              color: FlutterFlowTheme.of(context).secondary,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              context.goNamed(CarritoDeComprasWidget.routeName);
                            },
                          ),
                        ],
                      ),
                      wrapWithModel(
                        model: _model.textFieldModel,
                        updateCallback: () => safeSetState(() {}),
                        child: TextFieldWidget(
                          label: '',
                          labelPresent: false,
                          helper: '',
                          helperPresent: false,
                          leadingIcon: Icon(
                            Icons.search,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          leadingIconPresent: true,
                          trailingIconPresent: false,
                          hint: 'Buscar por nombre, marca o aroma...',
                          value: '',
                          onChange: '',
                          onSubmit: '',
                          variant: 'outlined',
                          error: false,
                        ),
                      ),
                    ].divide(SizedBox(height: 16.0)),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                shape: BoxShape.rectangle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                wrapWithModel(
                                  model: _model.filterTagModel1,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterTagWidget(
                                    label: 'TODOS',
                                    active: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.filterTagModel2,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterTagWidget(
                                    label: 'HOMBRE',
                                    active: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.filterTagModel3,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterTagWidget(
                                    label: 'MUJER',
                                    active: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.filterTagModel4,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterTagWidget(
                                    label: 'UNISEX',
                                    active: true,
                                  ),
                                ),
                                wrapWithModel(
                                  model: _model.filterTagModel5,
                                  updateCallback: () => safeSetState(() {}),
                                  child: FilterTagWidget(
                                    label: 'ÁRABES',
                                    active: true,
                                  ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'ORDENAR POR PRECIO',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      font: GoogleFonts.josefinSans(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondary80,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                      lineHeight: 1.2,
                                    ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.swap_vert_rounded,
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    size: 16.0,
                                  ),
                                  Text(
                                    'MENOR A MAYOR',
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          font: GoogleFonts.josefinSans(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondary,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                          lineHeight: 1.2,
                                        ),
                                  ),
                                ].divide(SizedBox(width: 4.0)),
                              ),
                            ],
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                    ),
                  ),
                  Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondary,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GridView(
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  childAspectRatio: 1.0,
                                ),
                                primary: false,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                children: [
                                  wrapWithModel(
                                    model: _model.productCardModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ProductCardWidget(
                                      brand: 'DIOR',
                                      imageDesc:
                                          'https://dimg.dreamflow.cloud/v1/image/luxury%20blue%20perfume%20bottle%20on%20dark%20background',
                                      name: 'Sauvage Elixir',
                                      outOfStock: 'Out Of Stock',
                                      outOfStockPresent: true,
                                      price: '95000',
                                      target: 'Target',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.productCardModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ProductCardWidget(
                                      brand: 'LATTAFA',
                                      imageDesc:
                                          'https://dimg.dreamflow.cloud/v1/image/amber%20liquid%20perfume%20bottle%20with%20crystal%20cap',
                                      name: 'Khamrah',
                                      outOfStock: 'Out Of Stock',
                                      outOfStockPresent: true,
                                      price: '35000',
                                      target: 'Target',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.productCardModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ProductCardWidget(
                                      brand: 'CHANEL',
                                      imageDesc:
                                          'https://dimg.dreamflow.cloud/v1/image/minimalist%20navy%20square%20perfume%20bottle',
                                      name: 'Bleu de Chanel',
                                      outOfStock: 'true',
                                      outOfStockPresent: true,
                                      price: '88000',
                                      target: 'Target',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.productCardModel4,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ProductCardWidget(
                                      brand: 'ARMANI',
                                      imageDesc:
                                          'https://dimg.dreamflow.cloud/v1/image/frosted%20glass%20perfume%20bottle',
                                      name: 'Acqua di Gio',
                                      outOfStock: 'Out Of Stock',
                                      outOfStockPresent: true,
                                      price: '72000',
                                      target: 'Target',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.productCardModel5,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ProductCardWidget(
                                      brand: 'YSL',
                                      imageDesc:
                                          'https://dimg.dreamflow.cloud/v1/image/elegant%20gold%20and%20black%20perfume%20bottle',
                                      name: 'Libre Intense',
                                      outOfStock: 'Out Of Stock',
                                      outOfStockPresent: true,
                                      price: '78000',
                                      target: 'Target',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.productCardModel6,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ProductCardWidget(
                                      brand: 'VERSACE',
                                      imageDesc:
                                          'https://dimg.dreamflow.cloud/v1/image/red%20textured%20perfume%20bottle%20with%20gold%20medusa',
                                      name: 'Eros Flame',
                                      outOfStock: 'Out Of Stock',
                                      outOfStockPresent: true,
                                      price: '55000',
                                      target: 'Target',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.productCardModel7,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ProductCardWidget(
                                      brand: 'PARFUMS DE MARLY',
                                      imageDesc:
                                          'https://dimg.dreamflow.cloud/v1/image/matte%20blue%20luxury%20perfume%20bottle',
                                      name: 'Layton',
                                      outOfStock: 'Out Of Stock',
                                      outOfStockPresent: true,
                                      price: '145000',
                                      target: 'Target',
                                    ),
                                  ),
                                  wrapWithModel(
                                    model: _model.productCardModel8,
                                    updateCallback: () => safeSetState(() {}),
                                    child: ProductCardWidget(
                                      brand: 'AFNAN',
                                      imageDesc:
                                          'https://dimg.dreamflow.cloud/v1/image/sleek%20black%20and%20purple%20bottle',
                                      name: '9PM',
                                      outOfStock: 'Out Of Stock',
                                      outOfStockPresent: true,
                                      price: '32000',
                                      target: 'Target',
                                    ),
                                  ),
                                ],
                              ),
                            ].divide(SizedBox(height: 16.0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: Container(
                child: wrapWithModel(
                  model: _model.bottomNavModel,
                  updateCallback: () => safeSetState(() {}),
                  child: BottomNavWidget(
                    child: () => BottomNavChild2Widget(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
