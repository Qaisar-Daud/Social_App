import 'package:flutter/material.dart';

import '../helpers/constants.dart';


/// A custom tab bar widget that includes a TabBar and TabBarView.
class DavineTabBar extends StatelessWidget {
  /// The controller that manages the state of the TabBar and TabBarView.
  final TabController tabController;

  /// A list of widgets representing the tabs' names.
  final List<Widget> tabsName;

  /// A list of widgets representing the content of each tab.
  final List<Widget> tabScreens;

  /// Constructor for the DavineTabBar widget.
  const DavineTabBar(
      {super.key,
      required this.tabController,
      required this.tabsName,
      required this.tabScreens});

  @override
  Widget build(BuildContext context) {
    // Get the screen width to use for responsive padding and sizing.
    final double sw = MediaQuery.sizeOf(context).width;

    return Expanded(
      // The Expanded widget makes the DavineTabBar take up the remaining space in its parent widget.
      child: Column(
        // The Column widget arranges its children (TabBar and TabBarView) vertically.
        children: [
          Container(
            height: sw * 0.09,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(sw * 0.1),
              color: AppColors.containerdarkmode,
            ),
            child: TabBar(
              // The controller that manages the state of the TabBar.
              controller: tabController,
              // The color of the divider between tabs.
              dividerColor: AppColors.white,
              indicatorAnimation: TabIndicatorAnimation.elastic,
              // Physics for the TabBar's scroll behavior.
              physics: const BouncingScrollPhysics(),
              // Automatically adjust the indicator color based on the tab's state.
              automaticIndicatorColorAdjustment: true,
              // Height of the divider between tabs.
              dividerHeight: 0,
              // Thickness of the tab indicator.
              indicatorWeight: 0,
              // Padding around the tab labels for spacing.
              labelPadding: EdgeInsets.only(
                top: sw * 0.01,
                bottom: sw * 0.01,
              ),
              // Style for the tab labels.
              labelStyle: TextStyle(
                fontFamily: 'Serif',
                fontSize: sw * 0.03,
                color: AppColors.white
              ),
              // Overlay color for the tab's splash effect.
              overlayColor: WidgetStatePropertyAll(AppColors.white),
              // Size of the tab indicator.
              indicatorSize: TabBarIndicatorSize.tab,
              // Color of the unselected tab labels.
              unselectedLabelColor: AppColors.white,
              // Style for the unselected tab labels.
              unselectedLabelStyle: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: sw * 0.038,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold),
              // Color of the selected tab labels.
              labelColor: AppColors.white,
              // Decoration for the tab indicator.
              indicator: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(sw * 0.1),
              ),
              // List of widgets representing the tabs.
              tabs: tabsName,
            ),
          ),
          Expanded(
              // The TabBarView widget displays the content of each tab.
              child: TabBarView(controller: tabController, children: tabScreens))
        ],
      ),
    );
  }
}
