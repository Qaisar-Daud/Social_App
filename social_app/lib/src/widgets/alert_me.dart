import 'package:flutter/material.dart';

alertMe({required BuildContext context, required contentTxt}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        // Header
        title: const Text(
          'Please Alert⚠️',
          style: TextStyle(fontSize: 14, fontFamily: 'Serif'),
        ),
        // Content Text Where We Can Display The Data Which We Want To Show...
        content: Text(
          contentTxt,
          style: const TextStyle(fontSize: 10, fontFamily: 'Poppins'),
        ),
        // Button
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Okay')),
        ],
      );
    },
  );
}
