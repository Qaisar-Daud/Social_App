
import 'package:flutter/material.dart';

import '../../helpers/constants.dart';

// Here Is A Two Type Of App Theme 🎨 Light and Dark
class AppThemes {
  // Light Theme 🎨
  static final ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: AppColors.scaffoldlight,
      brightness: Brightness.light,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonlightmode)
      ),

      textTheme: const TextTheme(
          bodySmall: TextStyle(color: AppColors.textlightmode, fontFamily: 'mulish', fontSize: 14),
          bodyLarge: TextStyle(color: AppColors.textlightmode, fontFamily: 'mulish_bold', fontSize: 20)),
  );

  // Dark Theme 🎨
  static final ThemeData darkTheme= ThemeData(
      scaffoldBackgroundColor: AppColors.scaffolddark,
      brightness: Brightness.dark,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttondarkmode,
          )
      ),
      textTheme: const TextTheme(
          bodySmall: TextStyle(color: AppColors.textdarkmode, fontFamily: 'mulish_bold', fontSize: 14),
          bodyLarge: TextStyle(color: AppColors.textdarkmode, fontFamily: 'mulish_bold', fontSize: 20)
      )
  );
}
