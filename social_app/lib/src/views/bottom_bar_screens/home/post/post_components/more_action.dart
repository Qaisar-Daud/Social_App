
import 'package:flutter/material.dart';

import '../../../../../widgets/custom_txt.dart';

Widget moreActionForPost({required double sw, required List<PopupMenuItem> menuButtons}){
  return PopupMenuButton(
    tooltip: 'Other Actions',
    constraints: BoxConstraints(
      maxWidth: sw * 0.34,
    ),
    popUpAnimationStyle: AnimationStyle(
      duration: const Duration(seconds: 1),
      reverseDuration: const Duration(milliseconds: 200),
    ),
    itemBuilder: (context) => menuButtons,
  );
}

Widget menuButton(
    {required double sw, required VoidCallback onTap, required Map<String, IconData> buttonMap}){
  return PopupMenuItem(
    onTap: onTap,
    height: sw * 0.06,
    padding: EdgeInsets.symmetric(
      horizontal: sw * 0.02,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomText(
          txt: buttonMap.keys.first,
          fontSize: sw * 0.036,
        ),
        Icon(
          buttonMap.values.first,
          size: sw * 0.05,
        ),
      ],
    ),
  );
}