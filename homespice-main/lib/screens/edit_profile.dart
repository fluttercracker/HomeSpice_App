import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() {
        usernameController.text = doc['username'] ?? '';
        bioController.text = doc['bio'] ?? '';
      });
    }
  }

  Future<void> saveProfile() async {
    final username = usernameController.text.trim();
    final bio = bioController.text.trim();
    if (username.length < 3) {
      showSnackBar("Username must be at least 3 characters", Colors.red);
      return;
    }
    if (bio.length > 200) {
      showSnackBar("Bio can't exceed 200 characters", Colors.red);
      return;
    }
    if(username.contains(' ')) {
      showSnackBar("Username can't contain spaces", Colors.red);
      return;
    }
    if (bio.isEmpty) {
      showSnackBar("Bio can't be empty", Colors.red);
      return;
    }

    if (username.isEmpty) {
      showSnackBar("Username can't be empty", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Update user profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'username': username,
        'bio': bio,
      });
      showSnackBar("Profile updated successfully", Colors.green);
    } catch (e) {
      showSnackBar("Failed to update profile", Colors.red);
    }

    setState(() => _isLoading = false);
  }

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 251, 251, 252),
        foregroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Update Your Info",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: bioController,
                      decoration: const InputDecoration(
                        labelText: "Bio",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : saveProfile,
                      icon: const Icon(Icons.save),
                      label: Text(_isLoading ? "Saving..." : "Save Changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
