import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_manager_app/util/app_colors.dart';


class AppTextStyles {
  // Headings
  static TextStyle heading1 = GoogleFonts.oxygen(
    fontSize: 35.0,
    fontWeight: FontWeight.w700,
    textBaseline: TextBaseline.alphabetic,
  );

  static TextStyle heading3 = GoogleFonts.oxygen(
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    textBaseline: TextBaseline.alphabetic,
  );

  static TextStyle heading7 = GoogleFonts.oxygen(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    textBaseline: TextBaseline.alphabetic,
  );

  // Paragraphs
  static TextStyle para2 = GoogleFonts.manrope(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    height: 48.0 / 35.0,
    textBaseline: TextBaseline.alphabetic,
  );

  static TextStyle para5 = GoogleFonts.manrope(
    fontSize: 13.0,
    textBaseline: TextBaseline.alphabetic,
  );

  // Buttons
  static TextStyle button = GoogleFonts.oxygen(
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      textBaseline: TextBaseline.alphabetic,
      color: AppColors.neutral0);

  static TextStyle latoPara = GoogleFonts.lato(
    fontSize: 14.0,
    textBaseline: TextBaseline.alphabetic,
  );

  static TextStyle heeboHeading = GoogleFonts.heebo(
    fontSize: 18.0,
    textBaseline: TextBaseline.alphabetic,
  );
}
