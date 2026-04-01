import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Heading Styles
  static TextStyle h1({Color? color}) => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.2,
  );

  static TextStyle h2({Color? color}) => GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.25,
  );

  static TextStyle h3({Color? color}) => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.3,
  );

  static TextStyle h4({Color? color}) => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.35,
  );

  static TextStyle h5({Color? color}) => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
  );

  // Body Styles
  static TextStyle bodyLarge({Color? color, FontWeight? fontWeight}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium({Color? color, FontWeight? fontWeight}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodySmall({Color? color, FontWeight? fontWeight}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color,
        height: 1.5,
      );

  // Label Styles
  static TextStyle labelLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
    letterSpacing: 0.3,
  );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
    letterSpacing: 0.3,
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // Button Text
  static TextStyle button({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // Caption
  static TextStyle caption({Color? color}) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: color,
    height: 1.4,
    letterSpacing: 0.3,
  );
}
