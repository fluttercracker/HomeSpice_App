import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:async';
class OtpVerificationScreen extends StatefulWidget {

  const OtpVerificationScreen({Key? key, required this.emailOrPhone, required this.from}) : super(key: key);
  final String emailOrPhone;
  final String from; // 'signup' or 'login'

  // Removed redundant OtpVerifyScreen constructor
  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 120; // 2 minutes

  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void onOtpEntered() {
    String otp = _otpControllers.map((e) => e.text).join();
    if (otp.length == 6) {
      // Add OTP verification logic with Firebase
      if(widget.from=='signup'){
       Navigator.pushReplacementNamed(context, '/login');
      } else if(widget.from=='login'){
        Navigator.pushReplacementNamed(context, '/home');
      }
    
      // ignore: avoid_print
      print("Entered OTP: $otp");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 100, color: Colors.deepPurple),

                const SizedBox(height: 30),

                Text(
                  'Verify Your OTP',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Enter your 6-digit OTP sent to your Email',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 45,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: "",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.deepPurple),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                          onOtpEntered();
                        },
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                Text(
                  "Time left: $formattedTime",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.redAccent),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    onOtpEntered();
                    // Add OTP verification Firebase logic here to match and verify the OTP
                    // If successful, navigate to the next screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Verify',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: _isResendEnabled
                      ? () {
                          // Resend OTP Firebase logic here
                          setState(() {
                            _remainingSeconds = 120;
                            _isResendEnabled = false;
                          });
                          startTimer();
                        }
                      : null,
                  child: Text(
                    'Resend OTP',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _isResendEnabled ? Colors.deepPurple : Colors.grey,
                      decoration: _isResendEnabled ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
