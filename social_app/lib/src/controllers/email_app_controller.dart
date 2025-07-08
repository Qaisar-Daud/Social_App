
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailLauncher {
  static Future<void> openEmailApp(BuildContext context) async {
    final List<EmailApp> apps = [];

    if (await canLaunchUrl(Uri.parse('googlegmail://'))) {
      apps.add(EmailApp('Gmail', 'googlegmail://', 'https://mail.google.com/'));
    }

    if (await canLaunchUrl(Uri.parse('ms-outlook://'))) {
      apps.add(EmailApp('Outlook', 'ms-outlook://', 'https://outlook.live.com/'));
    }

    if (await canLaunchUrl(Uri.parse('yahoo://'))) {
      apps.add(EmailApp('Yahoo Mail', 'yahoo://', 'https://mail.yahoo.com/'));
    }

    if (apps.isEmpty) {
      // No native apps found, fallback to Gmail web
      final fallbackUri = Uri.parse('https://mail.google.com/');
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Show dialog to choose email app
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Choose an email app', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...apps.map((app) {
            return ListTile(
              leading: Icon(Icons.email),
              title: Text(app.name),
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse(app.scheme);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  await launchUrl(Uri.parse(app.web), mode: LaunchMode.externalApplication);
                }
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}

class EmailApp {
  final String name;
  final String scheme;
  final String web;

  EmailApp(this.name, this.scheme, this.web);
}
