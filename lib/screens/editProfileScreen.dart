import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/customTextInput.dart';
import '../widgets/uploadFile.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = "/editProfilePage";

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _mobile = '';
  String _address = '';
  String _email = '';
  String? _profileImageUrl; // Store profile picture URL

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch the current user's data from Firestore
  Future<void> _fetchUserData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        setState(() {
          _email = currentUser.email ?? '';
          _name = userDoc['name'] ?? '';
          _mobile = userDoc['mobile'] ?? '';
          _address = userDoc['address'] ?? '';
          _profileImageUrl = userDoc['profileImage'] ?? ''; // Fetch profile image URL

          _nameController.text = _name;
          _mobileController.text = _mobile;
          _addressController.text = _address;
          _emailController.text = _email;
        });
      }
    }
  }

  // Update user profile in Firestore
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'name': _nameController.text,
          'mobile': _mobileController.text,
          'address': _addressController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Pick an image and upload it to Cloudinary
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      setState(() => _isLoading = true);

      try {
        // Upload to Cloudinary
        String imageUrl = await UploadService.uploadImageToCloudinary(imageFile);

        // Update Firestore with the new profile image URL
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          await _firestore.collection('users').doc(currentUser.uid).update({
            'profileImage': imageUrl,
          });

          setState(() {
            _profileImageUrl = imageUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile image updated successfully!')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),

              // Profile Image with Upload Button
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                      : null,
                ),
              ),

              SizedBox(height: 20),

              // Email (Read-only)
              CustomTextInput(controller: _emailController, hintText: 'Email: $_email', enabled: false),

              SizedBox(height: 20),

              // Name Field
              CustomTextInput(controller: _nameController, hintText: 'Enter your name', enabled: true),

              SizedBox(height: 20),

              // Mobile Field
              CustomTextInput(controller: _mobileController, hintText: 'Enter your mobile number', enabled: true),

              SizedBox(height: 20),

              // Address Field
              CustomTextInput(controller: _addressController, hintText: 'Enter your address', enabled: true),

              SizedBox(height: 40),

              // Update Button
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text("Update Profile"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
