/// Consistent spacing scale for the application
/// Use these values instead of hardcoded numbers for consistent UI
class AppSpacing {
  AppSpacing._();

  // Base spacing unit (4px)
  static const double unit = 4.0;

  // Spacing Scale
  static const double xs = unit; // 4px
  static const double sm = unit * 2; // 8px
  static const double md = unit * 4; // 16px
  static const double lg = unit * 6; // 24px
  static const double xl = unit * 8; // 32px
  static const double xxl = unit * 12; // 48px
  static const double xxxl = unit * 16; // 64px

  // Common padding values
  static const double screenPadding = md; // 16px
  static const double cardPadding = md; // 16px
  static const double buttonPadding = md; // 16px
  static const double listItemPadding = sm; // 8px

  // Common margin values
  static const double sectionMargin = lg; // 24px
  static const double cardMargin = md; // 16px
  static const double itemMargin = sm; // 8px

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 999.0; // For circular elements

  // Elevation (shadows)
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;
}
