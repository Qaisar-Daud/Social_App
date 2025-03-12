
// Preview or Watch Uploaded Images
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';

Future<Dialog?> previewFullImage(BuildContext context,String? imgUrl) async {
  final imageProvider = Image.network(imgUrl!).image;
  return showImageViewer(
    context,
    imageProvider,
    useSafeArea: true,
    onViewerDismissed: () => debugPrint("dismissed"),
  );
}