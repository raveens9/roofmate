import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SendEmailPage extends StatelessWidget {
  final String email = "support@roofmate.com"; // Replace with your email
  final String subject = "Booking Confirmation";
  final String body = "Thank you for booking with us. Your payment has been processed successfully.";

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not open the email app';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Booking Confirmation'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _sendEmail,
          child: Text('Send Confirmation Email'),
        ),
      ),
    );
  }
}
