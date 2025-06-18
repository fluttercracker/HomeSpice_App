/// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homespice/screens/edit_profile.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userProfile;
  final ImagePicker _picker = ImagePicker();
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      loadProfileImage(uid);
    }

    loadUserProfileData().then((data) {
      if (mounted && data != null) {
        setState(() {
          userProfile = data;
        });
      }
    });
  }

  Future<void> refreshData() async {
    await loadUserProfileData(); // Refresh
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;

        // Save logout timestamp to Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'lastLogout': FieldValue.serverTimestamp(),
        });
      }

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('loggedIn');

      // Navigate to login screen
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logout failed: ${e.toString()}")),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose any controllers/focus nodes if used
    super.dispose();
  }

  Future<Map<String, dynamic>?> loadUserProfileData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        return {
          'username': data?['username'] ?? '',
          'email': data?['email'] ?? '',
          'bio': data?['bio'] ?? '',
          'createdAt': data?['createdAt']?.toDate()?.toString() ?? '',
        };
      }
      return null;
    } catch (e) {
      SnackBar(
        content: Text('Error loading profile data: $e'),
        duration: const Duration(seconds: 2),
      );
      return null;
    }
  }

  Future<void> loadProfileImage(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          profileImageUrl = doc.data()!['profileImageUrl'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        profileImageUrl = null;
      });
    }
  }

  Future<File?> pickImage() async {
    var status = await Permission.photos.request();

    if (status.isGranted) {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      } else {
        showSnackBar("No image selected", 'red');
      }
    } else {
      showSnackBar("Permission denied to access photos", 'red');
    }

    return null;
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dgzqsliok';
    const uploadPreset = 'my_datas';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);
      return data['secure_url'];
    } else {
      return null;
    }
  }

  Future<void> saveImageUrlToFirestore(String uid, String imageUrl) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profileImageUrl': imageUrl,
    });
  }

  Future<bool> pickUploadAndSaveProfileImage(String uid) async {
    final file = await pickImage();
    if (file == null) return false;

    final imageUrl = await uploadImageToCloudinary(file);
    if (imageUrl == null) return false;

    await saveImageUrlToFirestore(uid, imageUrl);
    return true;
  }

  Future<void> reloadProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final data = await loadUserProfileData();
    if (mounted && data != null) {
      setState(() {
        userProfile = data;
      });
    }

    await loadProfileImage(uid);
  }

  void showSnackBar(String message, String color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor:
            color == 'red'
                ? Colors.red
                : color == 'green'
                ? Colors.green
                : color == 'blue'
                ? Colors.blue
                : Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await loadUserProfileData();
            await loadProfileImage(FirebaseAuth.instance.currentUser!.uid);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Card(
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipOval(
                              child:
                                  profileImageUrl == null ||
                                          profileImageUrl!.isEmpty
                                      ? Image.asset(
                                        'assets/images/profile1.jpg',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.network(
                                        profileImageUrl!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                right: 0,
                                bottom: 0,
                              ),
                              height: 33,
                              width: 33,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                color: Colors.deepPurple,
                                onPressed: () async {
                                  final userId =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  bool success =
                                      await pickUploadAndSaveProfileImage(
                                        userId,
                                      );
                                  if (!mounted) return;
                                  if (success) {
                                    showSnackBar(
                                      'Profile image updated successfully',
                                      'green',
                                    );
                                    await loadProfileImage(userId);
                                  } else {
                                    showSnackBar(
                                      'Profile Image Not Uploaded. Error',
                                      'red',
                                    );
                                  }
                                },
                                icon: const Icon(Icons.add_a_photo),
                                tooltip: 'Upload Profile Image',
                                iconSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FontAwesomeIcons.at, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              userProfile?['username'] ?? 'Unknown User',
                              style: GoogleFonts.italiana(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                // color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              FontAwesomeIcons.commentDots,
                              color: Colors.deepPurple,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                userProfile?['bio'] ?? 'No bio added',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  // color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.teal,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              userProfile?['createdAt'] != null
                                  ? DateFormat('dd MMM yyyy').format(
                                    userProfile!['createdAt'] is String
                                        ? DateTime.parse(
                                          userProfile!['createdAt'],
                                        )
                                        : (userProfile!['createdAt']
                                                as Timestamp)
                                            .toDate(),
                                  )
                                  : 'Joined date unknown',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                // color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 340,
                  width: 360,
                  child: Card(
                    color: Colors.white,
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // Email Card
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'This is your registered email',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.blue,
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.withAlpha(
                                          (0.1 * 255).toInt(),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        FontAwesomeIcons.envelope,
                                        color: Colors.deepPurple,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${userProfile?['email'] ?? 'Not available'}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Edit Profile
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const EditProfileScreen(),
                                  ),
                                ).then((_) {
                                  reloadProfileData();
                                  // });
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.withAlpha(
                                          (0.1 * 255).toInt(),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        FontAwesomeIcons.penToSquare,
                                        color: Colors.deepPurple,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        "Edit Profile",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      FontAwesomeIcons.arrowRight,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Settings
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.pushNamed(context, '/settings');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.withAlpha(
                                          (0.1 * 255).toInt(),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        FontAwesomeIcons.gear,
                                        color: Colors.deepPurple,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        "Settings",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      FontAwesomeIcons.arrowRight,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Logout
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Confirm Logout'),
                                        content: const Text(
                                          'Are you sure you want to logout?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed:
                                                () => logoutUser(context),
                                            child: const Text('Logout'),
                                          ),
                                        ],
                                      ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.withAlpha(
                                          (0.1 * 255).toInt(),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        FontAwesomeIcons.rightFromBracket,
                                        color: Colors.deepPurple,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Logout",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      FontAwesomeIcons.arrowRight,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
