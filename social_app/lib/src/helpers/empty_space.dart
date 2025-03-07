import 'package:flutter/material.dart';

extension EmptySpace on num {
  SizedBox get width => SizedBox(
    width: toDouble(),
  );

  SizedBox get height => SizedBox(
    height: toDouble(),
  );
}
