// ignore_for_file: avoid_print

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailSender {
  // Private credentials - consider moving these to secure storage or environment variables
  static const String _username = 'homespiceapp@gmail.com';
  static const String _appPassword = 'qnhothcbymxyncxz'; // 16-digit app password
  static final SmtpServer _smtpServer = gmail(_username, _appPassword);

  /// Sends an OTP email to the recipient with expiry info
  static Future<bool> sendOtpEmail({
    required String recipientEmail,
    required String otpCode,
    required int otpExpiryMinutes,
  }) async {
    const subject = 'Your OTP for HomeSpice App';
    final body = '''
Hello,

Your One-Time Password (OTP) for authentication is:

$otpCode

This OTP is valid for $otpExpiryMinutes minutes. Please do not share it with anyone.

If you didn't request this OTP, please ignore this email.

Best regards,
Home Spice Team!
''';

    return _sendEmail(
      recipientEmail: recipientEmail,
      subject: subject,
      body: body,
    );
  }

  /// Private helper to send an email
  static Future<bool> _sendEmail({
    required String recipientEmail,
    required String subject,
    required String body,
  }) async {
    final message = Message()
      ..from = const Address(_username, 'HomeSpice App')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = body;

    try {
      print('[EmailSender] Attempting to send email to $recipientEmail...');
      final sendReport = await send(message, _smtpServer);
      print('[EmailSender] Email sent successfully.');
      print('[EmailSender] Send report: $sendReport');
      return true;
    } on MailerException catch (e) {
      print('[EmailSender] Failed to send email: ${e.toString()}');
      for (final problem in e.problems) {
        print('[EmailSender] SMTP Problem: Code=${problem.code}, Msg=${problem.msg}');
      }
      return false;
    } catch (e) {
      print('[EmailSender] Unexpected error: ${e.toString()}');
      return false;
    }
  }
}
