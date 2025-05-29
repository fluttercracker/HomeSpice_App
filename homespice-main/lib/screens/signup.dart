import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homespice/screens/auth_service.dart';
import 'package:homespice/screens/otp_verify.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;

  // Email Validation
  bool _isValidEmail(String email) {
    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  // Password Validation
  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color.fromARGB(255, 168, 13, 2),
      duration: const Duration(seconds: 2),
    ),
  );
}

final strongPasswordRegex = RegExp(
  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'
);


  void _handleSignup() async {
    if (_isLoading) return; 
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;


    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    if (strongPasswordRegex.hasMatch(password)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Password is strong'),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '❌ Password must be at least 8 characters, include upper, lower, digit & special character.',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }


    if(username.contains(' ')) {
      _showError("Username cannot contain spaces");
      return;
    }
    if (password != confirmPasswordController.text.trim()) {
      _showError("Passwords do not match");
      return;
    }
    if (username.length < 8) {
      _showError("Username must be at least 8 characters");
      return;
    }


    if (!_isValidEmail(email)) {
      _showError("Please enter a valid email address");
      return;
    }

    if (!_isValidPassword(password)) {
      _showError("password must be at least 8 characters");
      return;
    }

    setState(() => _isLoading = true);

    final isAvailable =
        await AuthService.checkUsernameAndEmailAvailable(username, email);

    if (!isAvailable) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError("Username or Email already in use");
      return;
    }

    try {
      final otpSent = await AuthService.sendOtpToEmail(email);
      setState(() => _isLoading = false);

      if (otpSent) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              username: username,
              email: email,
              password: password,
              isLogin: false,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        _showError("Failed to send OTP. Please try again.");
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError("Error: ${error.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(), 
    child:Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/back4.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Container(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.3),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(color: Colors.transparent),
                ),
              ),
              const SizedBox(height: 45),
              Center(
                child: Image.asset('assets/images/HomeSpice1.png', height: 220),
              ),
              //const SizedBox(height: 5),
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Username
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: "Username",
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email
                      SizedBox(
                        width: 320,
                        child: TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Password
                      SizedBox(
                        width: 320,
                        child: TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            labelText: "Password",
                            border: const OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Confirm Password
                      SizedBox(
                        width: 320,
                        child: TextField(
                          controller: confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            labelText: "Confirm Password",
                            border: const OutlineInputBorder(),
                            fillColor: Colors.white,
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Sign Up Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                          shadowColor: Colors.deepPurpleAccent,
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Already have an account
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Column(
                          children: [
                            Text(
                              "Already have an account?",
                              style: GoogleFonts.aBeeZee(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.only(bottom: 2),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.deepPurple,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                "Login",
                                style: GoogleFonts.aBeeZee(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.deepPurpleAccent
                                      // ignore: deprecated_member_use
                                      .withOpacity(0.4),
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
