
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/views/bottom_bar_screens/home/post/post_components/more_action.dart';

import '../../../../../helpers/constants.dart';
import '../../../../../myapp.dart';
import '../../../../../providers/post_provider.dart';
import '../../../../../widgets/custom_txt.dart';

// User Information and save post action
Widget userInfoTile({
  required double sw,
  required QueryDocumentSnapshot<Object?> postMap,
  required List<PopupMenuItem> menuItemButtons,
}) {
  return Consumer<PostProvider>(
    builder: (context, postProvider, child) {
      return ListTile(
        isThreeLine: true,
        contentPadding: EdgeInsets.only(top: sw * 0.02, left: sw * 0.04),
        horizontalTitleGap: sw * 0.02,
        minVerticalPadding: sw * 0.02,
        minLeadingWidth: sw * 0.16,
        minTileHeight: sw * 0.2,
        titleAlignment: ListTileTitleAlignment.threeLine,
        leading: Container(
          width: sw * 0.14,
          height: sw * 0.14,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.aqua,
          ),
          child: Image.network(
            (postMap['userProfilePic'] != null)
                ? postMap['userProfilePic']
                : defaultProfile,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: CircularProgressIndicator(strokeWidth: 0.6),
              );
            },
          ),
        ),
        title: CustomText(txt: postMap['userName'], fontSize: sw * 0.034),
        subtitle: CustomText(txt: postMap['userId'], fontSize: sw * 0.022),
        trailing: moreActionForPost(sw: sw, menuButtons: menuItemButtons),
      );
    },
  );
}