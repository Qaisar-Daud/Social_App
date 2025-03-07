// Loading Effect Style
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerLoader() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 100,
            height: 56,
            color: Colors.white,
          ),
          title: Container(
            width: double.infinity,
            height: 16,
            color: Colors.white,
          ),
          subtitle: Container(
            width: double.infinity,
            height: 14,
            color: Colors.white,
          ),
        );
      },
    ),
  );
}