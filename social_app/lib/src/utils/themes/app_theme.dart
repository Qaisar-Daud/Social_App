
import 'package:flutter/material.dart';

import '../../helpers/constants.dart';

// Here Is A Two Type Of App Theme 🎨 Light and Dark
class AppThemes {
  // Light Theme 🎨
  static final ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: AppColors.scaffoldlight,
      brightness: Brightness.light,
      actionIconTheme: ActionIconThemeData(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.scaffoldlight,
      ),
      cardTheme: CardThemeData(
        color: AppColors.containerlightmode,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonlightmode)
      ),

    searchBarTheme: SearchBarThemeData(
      hintStyle: WidgetStatePropertyAll(TextStyle(fontFamily: 'Poppins', color: AppColors.grey.withAlpha(200))),
      textStyle: WidgetStatePropertyAll(TextStyle(fontFamily: 'Poppins', color: AppColors.black)),
      padding: WidgetStatePropertyAll(EdgeInsets.only(left: 10))
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.yellow,
      selectedIconTheme: IconThemeData(
        color: AppColors.white,
      ),
      unselectedIconTheme: IconThemeData(
        color: AppColors.grey,
      ),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedLabelStyle: TextStyle(fontFamily: 'poppins'),
      unselectedLabelStyle: TextStyle(fontFamily: 'poppins'),
      type: BottomNavigationBarType.shifting,
      elevation: 0,
    ),

    listTileTheme: ListTileThemeData(
      iconColor: AppColors.black,
      textColor: AppColors.black,
      subtitleTextStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.black),
      tileColor: AppColors.containerlightmode,
      titleTextStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.black),
    ),
      iconTheme: IconThemeData(
        color: AppColors.black
      ),

      textTheme: TextTheme(
          bodySmall: TextStyle(color: AppColors.black, fontFamily: 'Poppins', fontSize: 14),
          bodyLarge: TextStyle(color: AppColors.black, fontFamily: 'Poppins', fontSize: 20)),
  );

  // Dark Theme 🎨
  static final ThemeData darkTheme= ThemeData(
      scaffoldBackgroundColor: AppColors.scaffolddark,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.scaffolddark,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.white,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.white,
        )
      ),
      iconTheme: IconThemeData(color: AppColors.white,),
      dataTableTheme: DataTableThemeData(),
      tabBarTheme: TabBarTheme(
        data: TabBarThemeData(
          dividerColor: AppColors.white,
          indicatorAnimation: TabIndicatorAnimation.elastic,
          // Height of the divider between tabs.
          dividerHeight: 0,
          labelStyle: TextStyle(
              fontFamily: 'Serif',
              color: AppColors.white
          ),
          overlayColor: WidgetStatePropertyAll(AppColors.white),
          // Size of the tab indicator.
          indicatorSize: TabBarIndicatorSize.tab,
          // Color of the unselected tab labels.
          unselectedLabelColor: AppColors.white,
          // Style for the unselected tab labels.
          unselectedLabelStyle: TextStyle(
              fontFamily: 'Serif',
              color: AppColors.white,
              fontWeight: FontWeight.bold),
          // Color of the selected tab labels.
          labelColor: AppColors.white,
          // Decoration for the tab indicator.
          indicator: BoxDecoration(
            color: AppColors.containerdarkmode,
          ),
        ),
      ),
      cardTheme: CardTheme(
        data: CardThemeData(
          color: AppColors.containerdarkmode,
        ),
      ),
      fontFamily: 'Poppins',
      switchTheme: SwitchThemeData(),
      useMaterial3: true,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.yellow,
        selectedIconTheme: IconThemeData(
          color: AppColors.white,
        ),
        unselectedIconTheme: IconThemeData(
          color: AppColors.grey,
        ),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedLabelStyle: TextStyle(fontFamily: 'poppins'),
        unselectedLabelStyle: TextStyle(fontFamily: 'poppins'),
        type: BottomNavigationBarType.shifting,
        elevation: 0,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.white,
        textColor: AppColors.white,
        subtitleTextStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.white),
        tileColor: AppColors.containerdarkmode,
        titleTextStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttondarkmode,
          )
      ),

      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(AppColors.containerdarkmode),
        hintStyle: WidgetStatePropertyAll(TextStyle(fontFamily: 'Poppins', color: AppColors.grey.withAlpha(200))),
        textStyle: WidgetStatePropertyAll(TextStyle(fontFamily: 'Poppins', color: AppColors.white)),
      ),

      textTheme: TextTheme(
          bodySmall: TextStyle(color: AppColors.white, fontFamily: 'Poppins', fontSize: 14),
          bodyLarge: TextStyle(color: AppColors.white, fontFamily: 'Poppins', fontSize: 20)
      )
  );
}