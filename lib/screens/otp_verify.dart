// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import 'package:homespice/screens/login.dart'; 
import 'package:homespice/screens/home.dart';
import 'package:homespice/screens/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final bool isLogin; // Flag to differentiate login or signu

  const OtpVerificationScreen({
    super.key,
    required this.username,
    required this.email,
    required this.password,
    required this.isLogin,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 180;
  bool _canResend = false;
  bool _isLoading = false; // Added loading state for better UX

  @override
  void initState() {
    super.initState();
    _sendOtp();
    startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodes[0]);
    });
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
    });

    bool sent = await AuthService.sendOtpToEmail(widget.email);
    if (!sent) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send OTP. Please try again.")),
        );
      }
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Otp sent to your email. Please check your inbox.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void startTimer() {
    _secondsRemaining = 120; // Reset to 120 seconds (2 minutes)
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      bool isValid = await AuthService.verifyOtp(widget.email, otp);
      if (isValid) {
        final prefs = await SharedPreferences.getInstance();
await prefs.setBool('loggedIn', true); // ✅ set only after OTP success

       const SnackBar(
          content: Text("OTP verified successfully!", style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        );
        if (widget.isLogin) {
          bool success = await AuthService.loginUser(widget.email, widget.password);
          if (success) {
            if (mounted) {
              const SnackBar(
                content: Text("Login successfull!",style: TextStyle(color: Colors.white),),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Home()),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Login failed. Please try again.")),
              );
            }
          }
        } else {
          await AuthService.registerUser(widget.username, widget.email, widget.password);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid OTP. Please try again.")),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter 6-digit OTP")),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Widget buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          } else if (index == 5 && value.isNotEmpty) {
            verifyOtp(); // Auto-submit
          }
        },
      ),
    );
  }

  void clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    FocusScope.of(context).requestFocus(focusNodes[0]);
  }

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  return Scaffold(
    backgroundColor: const Color(0xFFF2F6FF),
    appBar: AppBar(
      title: const Text(
        "OTP Verification",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF4F46E5),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ZoomIn(
              duration: const Duration(milliseconds: 1000),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeInDown(
              duration: const Duration(milliseconds: 1400),
              child: Text(
                "Enter Verification Code",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            FadeInDown(
              duration: const Duration(milliseconds: 1600),
              child: Text(
                "We’ve sent a 6-digit code to your email",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            SlideInUp(
              duration: const Duration(milliseconds: 1200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.05 * 255).toInt()),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => buildOtpBox(index)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeIn(
              duration: const Duration(milliseconds: 1500),
              child: Text(
                "Time left: $formattedTime",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SlideInUp(
              duration: const Duration(milliseconds: 1400),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : verifyOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    backgroundColor: const Color(0xFF4F46E5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Verify",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeIn(
              duration: const Duration(milliseconds: 1600),
              child: TextButton(
                onPressed: _canResend
                    ? () async {
                        await _sendOtp();
                        if (!mounted) return;
                        startTimer();
                        clearOtpFields();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("OTP Resent")),
                        );
                      }
                    : null,
                child: Text(
                  "Resend OTP",
                  style: TextStyle(
                    color: _canResend ? const Color(0xFF4F46E5) : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}