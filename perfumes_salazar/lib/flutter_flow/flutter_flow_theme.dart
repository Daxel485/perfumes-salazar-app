// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';

SharedPreferences? _prefs;

abstract class FlutterFlowTheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static FlutterFlowTheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkModeTheme()
        : LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late Color onPrimary;
  late Color primaryContainer;
  late Color onPrimaryContainer;
  late Color onSecondary;
  late Color secondaryContainer;
  late Color onSecondaryContainer;
  late Color onAccent;
  late Color accentContainer;
  late Color onAccentContainer;
  late Color onBackground;
  late Color onSurface;
  late Color surfaceVariant;
  late Color onSurfaceVariant;
  late Color onSuccess;
  late Color onWarning;
  late Color onError;
  late Color onInfo;
  late Color transparent;
  late Color fullContrast;
  late Color secondary40;
  late Color primary70;
  late Color secondary30;
  late Color secondary80;
  late Color primary40;
  late Color accent40;
  late Color primary60;
  late Color accent20;
  late Color primary5;
  late Color primary80;
  late Color accent30;
  late Color success10;
  late Color error10;
  late Color secondary20;
  late Color primary10;
  late Color background80;
  late Color secondary5;
  late Color secondary10;
  late Color background70;

  FFDesignTokens get designToken => FFDesignTokens(this);

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF1B1714);
  late Color secondary = const Color(0xFFB8893B);
  late Color tertiary = const Color(0xFFD4AF37);
  late Color alternate = const Color(0xFFD4AF37);
  late Color primaryText = const Color(0xFF1B1714);
  late Color secondaryText = const Color(0xFF5C4B37);
  late Color primaryBackground = const Color(0xFFF7E7CE);
  late Color secondaryBackground = const Color(0xFFFFFFFF);
  late Color accent1 = const Color(0x4C4B39EF);
  late Color accent2 = const Color(0x4D39D2C0);
  late Color accent3 = const Color(0xFFA6937C);
  late Color accent4 = const Color(0xCCFFFFFF);
  late Color success = const Color(0xFF046A38);
  late Color warning = const Color(0xFFC5A021);
  late Color error = const Color(0xFF8B0000);
  late Color info = const Color(0xFF1B2838);

  late Color onPrimary = const Color(0xFFFFFFFF);
  late Color primaryContainer = const Color(0x1A1B1714);
  late Color onPrimaryContainer = const Color(0xFF1B1714);
  late Color onSecondary = const Color(0xFFFFFFFF);
  late Color secondaryContainer = const Color(0x1AB8893B);
  late Color onSecondaryContainer = const Color(0xFF1B1714);
  late Color onAccent = const Color(0xFFFFFFFF);
  late Color accentContainer = const Color(0x1AD4AF37);
  late Color onAccentContainer = const Color(0xFF1B1714);
  late Color onBackground = const Color(0xFF1B1714);
  late Color onSurface = const Color(0xFF1B1714);
  late Color surfaceVariant = const Color(0xFFE8D8C3);
  late Color onSurfaceVariant = const Color(0xFF5C4B37);
  late Color onSuccess = const Color(0xFFFFFFFF);
  late Color onWarning = const Color(0xFFFFFFFF);
  late Color onError = const Color(0xFFFFFFFF);
  late Color onInfo = const Color(0xFFFFFFFF);
  late Color transparent = const Color(0x00000000);
  late Color fullContrast = const Color(0xFF000000);
  late Color secondary40 = const Color(0x66B8893B);
  late Color primary70 = const Color(0xB31B1714);
  late Color secondary30 = const Color(0x4DB8893B);
  late Color secondary80 = const Color(0xCCB8893B);
  late Color primary40 = const Color(0x661B1714);
  late Color accent40 = const Color(0x66D4AF37);
  late Color primary60 = const Color(0x991B1714);
  late Color accent20 = const Color(0x33D4AF37);
  late Color primary5 = const Color(0x0D1B1714);
  late Color primary80 = const Color(0xCC1B1714);
  late Color accent30 = const Color(0x4DD4AF37);
  late Color success10 = const Color(0x1A046A38);
  late Color error10 = const Color(0x1A8B0000);
  late Color secondary20 = const Color(0x33B8893B);
  late Color primary10 = const Color(0x1A1B1714);
  late Color background80 = const Color(0xCCF7E7CE);
  late Color secondary5 = const Color(0x0DB8893B);
  late Color secondary10 = const Color(0x1AB8893B);
  late Color background70 = const Color(0xB3F7E7CE);
}

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Poiret One';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => GoogleFonts.poiretOne(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 58.0,
        height: 1.1,
      );
  String get displayMediumFamily => 'Poiret One';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => GoogleFonts.poiretOne(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 46.0,
        height: 1.15,
      );
  String get displaySmallFamily => 'Poiret One';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => GoogleFonts.poiretOne(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 38.0,
        height: 1.2,
      );
  String get headlineLargeFamily => 'Poiret One';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => GoogleFonts.poiretOne(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 34.0,
        height: 1.2,
      );
  String get headlineMediumFamily => 'Poiret One';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => GoogleFonts.poiretOne(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 28.0,
        height: 1.25,
      );
  String get headlineSmallFamily => 'Poiret One';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.poiretOne(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
        height: 1.3,
      );
  String get titleLargeFamily => 'Josefin Sans';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => GoogleFonts.josefinSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 22.0,
        height: 1.3,
      );
  String get titleMediumFamily => 'Josefin Sans';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => GoogleFonts.josefinSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 17.0,
        height: 1.4,
      );
  String get titleSmallFamily => 'Josefin Sans';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.josefinSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        height: 1.4,
      );
  String get labelLargeFamily => 'Josefin Sans';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => GoogleFonts.josefinSans(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        height: 1.3,
      );
  String get labelMediumFamily => 'Josefin Sans';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => GoogleFonts.josefinSans(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 12.0,
        height: 1.3,
      );
  String get labelSmallFamily => 'Josefin Sans';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => GoogleFonts.josefinSans(
        color: theme.secondaryText,
        fontWeight: FontWeight.bold,
        fontSize: 10.0,
        height: 1.2,
      );
  String get bodyLargeFamily => 'Josefin Sans';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => GoogleFonts.josefinSans(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
        height: 1.6,
      );
  String get bodyMediumFamily => 'Josefin Sans';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => GoogleFonts.josefinSans(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
        height: 1.5,
      );
  String get bodySmallFamily => 'Josefin Sans';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.josefinSans(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 12.0,
        height: 1.4,
      );
}

class DarkModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFFB8893B);
  late Color secondary = const Color(0xFFF7E7CE);
  late Color tertiary = const Color(0xFFD4AF37);
  late Color alternate = const Color(0xFF4D4033);
  late Color primaryText = const Color(0xFFF7E7CE);
  late Color secondaryText = const Color(0xFFD4AF37);
  late Color primaryBackground = const Color(0xFF1B1714);
  late Color secondaryBackground = const Color(0xFF26211E);
  late Color accent1 = const Color(0x4C4B39EF);
  late Color accent2 = const Color(0x4D39D2C0);
  late Color accent3 = const Color(0xFF8C7A65);
  late Color accent4 = const Color(0xB2262D34);
  late Color success = const Color(0xFF2E7D32);
  late Color warning = const Color(0xFFFFD700);
  late Color error = const Color(0xFFD32F2F);
  late Color info = const Color(0xFF4FC3F7);

  late Color onPrimary = const Color(0xFFFFFFFF);
  late Color primaryContainer = const Color(0x24B8893B);
  late Color onPrimaryContainer = const Color(0xFFF7E7CE);
  late Color onSecondary = const Color(0xFF000000);
  late Color secondaryContainer = const Color(0x24F7E7CE);
  late Color onSecondaryContainer = const Color(0xFFF7E7CE);
  late Color onAccent = const Color(0xFFFFFFFF);
  late Color accentContainer = const Color(0x24D4AF37);
  late Color onAccentContainer = const Color(0xFFF7E7CE);
  late Color onBackground = const Color(0xFFF7E7CE);
  late Color onSurface = const Color(0xFFF7E7CE);
  late Color surfaceVariant = const Color(0xFF3D342E);
  late Color onSurfaceVariant = const Color(0xFFD4AF37);
  late Color onSuccess = const Color(0xFFFFFFFF);
  late Color onWarning = const Color(0xFF000000);
  late Color onError = const Color(0xFFFFFFFF);
  late Color onInfo = const Color(0xFFFFFFFF);
  late Color transparent = const Color(0x00000000);
  late Color fullContrast = const Color(0xFFFFFFFF);
  late Color secondary40 = const Color(0x66F7E7CE);
  late Color primary70 = const Color(0xB3B8893B);
  late Color secondary30 = const Color(0x4DF7E7CE);
  late Color secondary80 = const Color(0xCCF7E7CE);
  late Color primary40 = const Color(0x66B8893B);
  late Color accent40 = const Color(0x66D4AF37);
  late Color primary60 = const Color(0x99B8893B);
  late Color accent20 = const Color(0x33D4AF37);
  late Color primary5 = const Color(0x0DB8893B);
  late Color primary80 = const Color(0xCCB8893B);
  late Color accent30 = const Color(0x4DD4AF37);
  late Color success10 = const Color(0x1A2E7D32);
  late Color error10 = const Color(0x1AD32F2F);
  late Color secondary20 = const Color(0x33F7E7CE);
  late Color primary10 = const Color(0x1AB8893B);
  late Color background80 = const Color(0xCC1B1714);
  late Color secondary5 = const Color(0x0DF7E7CE);
  late Color secondary10 = const Color(0x1AF7E7CE);
  late Color background70 = const Color(0xB31B1714);
}

class FFDesignTokens {
  const FFDesignTokens(this.theme);
  final FlutterFlowTheme theme;
  FFSpacing get spacing => const FFSpacing();
  FFRadius get radius => const FFRadius();
  FFShadows get shadow => FFShadows(theme);
}

class FFSpacing {
  const FFSpacing();
  double get none => 0.0;
  double get xs => 4.0;
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get xl => 32.0;
  double get xxl => 48.0;
  double get xxxl => 64.0;
}

class FFRadius {
  const FFRadius();
  double get none => 0.0;
  double get xs => 0.0;
  double get sm => 2.0;
  double get md => 4.0;
  double get lg => 8.0;
  double get xl => 12.0;
  double get xxl => 16.0;
  double get full => 9999.0;
}

class FFShadows {
  const FFShadows(this.theme);
  final FlutterFlowTheme theme;
  BoxShadow get none => const BoxShadow(
      blurRadius: 0.0,
      color: const Color(0x00000000),
      offset: const Offset(0.0, 0.0),
      spreadRadius: 0.0);
  BoxShadow get xs => const BoxShadow(
      blurRadius: 2.0,
      color: const Color(0x20B8893B),
      offset: const Offset(0.0, 1.0),
      spreadRadius: 0.0);
  BoxShadow get sm => const BoxShadow(
      blurRadius: 4.0,
      color: const Color(0x30B8893B),
      offset: const Offset(0.0, 2.0),
      spreadRadius: 0.0);
  BoxShadow get md => const BoxShadow(
      blurRadius: 8.0,
      color: const Color(0x30B8893B),
      offset: const Offset(0.0, 4.0),
      spreadRadius: 0.0);
  BoxShadow get lg => const BoxShadow(
      blurRadius: 16.0,
      color: const Color(0x40B8893B),
      offset: const Offset(0.0, 8.0),
      spreadRadius: 0.0);
  BoxShadow get xl => const BoxShadow(
      blurRadius: 24.0,
      color: const Color(0x40B8893B),
      offset: const Offset(0.0, 12.0),
      spreadRadius: 0.0);
  BoxShadow get xxl => const BoxShadow(
      blurRadius: 32.0,
      color: const Color(0x50B8893B),
      offset: const Offset(0.0, 16.0),
      spreadRadius: 0.0);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null && fontFamily.isNotEmpty) {
      font = GoogleFonts.getFont(fontFamily,
          fontWeight: fontWeight ?? this.fontWeight,
          fontStyle: fontStyle ?? this.fontStyle);
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}
