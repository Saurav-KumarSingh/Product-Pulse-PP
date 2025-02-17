import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:product_pulse/screens/help_support.dart';
import '../widgets/customNavBar.dart';
import 'editProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = "/profilePage";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = '';
  String _email = '';
  String _mobile = '';
  String _address = '';
  String? _profileImageUrl;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAuthenticatedUserDetails();
  }

  // Fetch authenticated user's details from Firebase Authentication
  Future<void> _fetchAuthenticatedUserDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _name = data['name'] ?? 'No name';
            _email = data['email'] ?? 'No email';
            _mobile = data['mobile'] ?? 'No mobile';
            _address = data['address'] ?? 'No address';
            _profileImageUrl = data['profileImage'] ?? '';
            _isLoading = false;
            _errorMessage = '';
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'User data not found.';
          });
        }
      } catch (error) {
        print('Error fetching user data: $error');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error fetching data: $error';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No user authenticated.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Custom App Bar with Gradient
                Container(
                  height: 270,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: _isLoading
                        ? CircularProgressIndicator() // Show loading spinner until data is fetched
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                              ? NetworkImage(_profileImageUrl!)
                              : AssetImage('assets/images/dummy/saurav.jpg') as ImageProvider,
                        ),
                        SizedBox(height: 10),
                        Text(
                          _name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      if (_errorMessage.isNotEmpty)
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      if (!_isLoading && _errorMessage.isEmpty)
                        Column(
                          children: [
                            _buildProfileDetail('Mobile:', _mobile),
                            _buildProfileDetail('Address:', _address),
                            SizedBox(height: 20),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Profile Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildProfileOption(
                        icon: Icons.person,
                        title: 'Edit Profile',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
                        },
                      ),
                      _buildProfileOption(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        onTap: () {
                          // Navigate to notifications screen
                        },
                      ),
                      _buildProfileOption(
                        icon: Icons.help,
                        title: 'Help & Support',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportScreen()));
                        },
                      ),
                      Divider(color: Colors.grey[300]),
                      _buildProfileOption(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: _signOut,
                        isLogout: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(),
          ),
        ],
      ),
    );
  }

  // Custom Profile Option Widget
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red[50] : Colors.orange[50],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isLogout ? Colors.red : Colors.orange,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.grey[800],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  // Helper function to display profile details
  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not Provided' : value,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to handle sign out
  Future<void> _signOut() async {
    // Show confirmation dialog
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // If user confirmed logout
    if (confirmLogout == true) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();

        // Close loading dialog
        Navigator.pop(context);

        if (mounted) {
          // Navigate to login screen and remove all previous routes
          Navigator.pushNamedAndRemoveUntil(
              context,
              '/loginScreen',
                  (route) => false
          );
        }
      } catch (e) {
        // Close loading dialog
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
}