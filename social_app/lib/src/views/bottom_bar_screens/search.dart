import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_app/src/helpers/empty_space.dart';

import '../../helpers/constants.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/shimmer_loader.dart';
import 'home_screens/home.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For Screen Resolution
    final double sw = MediaQuery.sizeOf(context).width;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(left: sw * 0.04, right: sw * 0.04, top: sw * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                  height: sw * 0.13,
                  width: double.infinity,
                  child: SearchBar(
                    hintText: 'Searching',
                    hintStyle: WidgetStatePropertyAll(TextStyle(
                        fontSize: sw * 0.04,
                        color: AppColors.grey.withOpacity(0.6))),
                    leading: Icon(
                      Icons.search,
                      size: sw * 0.07,
                      color: AppColors.grey.withOpacity(0.4),
                    ),
                  )),
            ),
            10.height,
            // Suggestion Text
            CustomText(
              txt: 'Suggestions',
              fontSize: sw * 0.036,
            ),
            10.height,
            // Other All App Users
            Expanded(
              child: StreamBuilder(
                stream: firestore.collection('Users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      // All Other App Users
                      var data = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: data.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Card(
                            color: AppColors.containerlightmode,
                            child: ListTile(
                              onTap: () {},
                              style: ListTileStyle.drawer,
                              isThreeLine: true,
                              // Other Users Profile
                              leading: Container(
                                width: sw * 0.15,
                                height: sw * 0.15,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    color: AppColors.black,
                                    shape: BoxShape.circle),
                                child: (data[index]['imgUrl'] != '')
                                    ? Image.network(
                                        data[index]['imgUrl'],
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/2.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              // Other Users Names
                              title: SizedBox(
                                width: sw * 0.21,
                                child: Text(
                                  "${data[index]['fullName']}",
                                  style: TextStyle(fontSize: sw * 0.036),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Other Users Bio
                              subtitle: Text(
                                "${data[index]['bio']}",
                                style: TextStyle(fontSize: sw * 0.028),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Icon(
                                CupertinoIcons.chat_bubble_text,
                                size: sw * 0.06,
                                color: AppColors.green,
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return CustomText(
                        txt: '${snapshot.hasError}',
                        fontSize: sw * 0.04,
                      );
                    } else {
                      return CustomText(
                        txt: 'No User Found',
                        fontSize: sw * 0.04,
                      );
                    }
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return buildShimmerLoader();
                  } else if (snapshot.connectionState == ConnectionState.none) {
                    return Align(
                        alignment: Alignment.topLeft,
                        child: CustomText(
                          txt: 'Please check your internet connection...',
                          fontSize: sw * 0.03,
                        ));
                  } else {
                    return Align(
                        alignment: Alignment.topLeft,
                        child: CustomText(
                          txt:
                              'Please wait your internet connection is slow...',
                          fontSize: sw * 0.03,
                        ));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
