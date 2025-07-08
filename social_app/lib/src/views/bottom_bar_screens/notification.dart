import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/src/helpers/empty_space.dart';
import '../../helpers/constants.dart';
import '../../providers/data_search_provider.dart';
import '../../widgets/custom_txt.dart';
import '../chat_screen/chatroom_screen.dart';
import '../profile_screen/other_users_info.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: sw * 0.04, right: sw * 0.04, top: sw * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TODO: all friends request are will be shown in new screen
              // Friend Requests
              CustomText(txt: 'Friend Requests', fontSize: sw * 0.036,),
              10.height,
              // TODO: show all notification according to time periods (yesterday, 2 days ago, 1 week ago, 1 month ago etc)
              CustomText(txt: 'Notification', fontSize: sw * 0.036,),
              10.height,
              CustomText(txt: 'All notification are here', fontSize: sw * 0.036,),
            ],
          ),
        ),
      ),
    );
  }
}