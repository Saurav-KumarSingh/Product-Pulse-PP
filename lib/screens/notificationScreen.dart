import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../const/colors.dart';
import '../widgets/customNavBar.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = "/notificationScreen";

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('New'),
                  _buildNotificationItem(
                    'assets/images/dummy/img.png',
                    'karennne liked your photo.',
                    '1h',
                    NotificationType.like,
                    'assets/images/dummy/img.png',
                  ),
                  _buildDivider(),
                  
                  _buildSectionTitle('Today'),
                  _buildNotificationItem(
                    'assets/images/dummy/img.png',
                    'kiero_d, zackjohn and 26 others liked your photo.',
                    '3h',
                    NotificationType.like,
                    'assets/images/dummy/img.png',
                  ),
                  _buildDivider(),
                  
                  _buildSectionTitle('This Week'),
                  _buildNotificationItem(
                    'assets/images/dummy/img.png',
                    'craig_love mentioned you in a comment: @jacob_w exactly..',
                    '2d',
                    NotificationType.comment,
                    'assets/images/dummy/img.png',
                  ),
                  _buildNotificationItem(
                    'assets/images/dummy/img.png',
                    'martini_rond started following you.',
                    '3d',
                    NotificationType.follow,
                    null,
                  ),
                  _buildNotificationItem(
                    'assets/images/dummy/img.png',
                    'maxjacobson started following you.',
                    '3d',
                    NotificationType.follow,
                    null,
                  ),
                ],
              ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String userImage,
    String message,
    String time,
    NotificationType type,
    String? contentImage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(userImage),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(text: message),
                      TextSpan(
                        text: ' • $time',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (type == NotificationType.follow)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text('Message'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (contentImage != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  contentImage,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade200,
      thickness: 0.5,
    );
  }
}

enum NotificationType {
  like,
  comment,
  follow,
}

class NotificationItem {
  final String userImage;
  final String userName;
  final String message;
  final String time;
  final NotificationType type;
  final String? contentImage;

  NotificationItem({
    required this.userImage,
    required this.userName,
    required this.message,
    required this.time,
    required this.type,
    this.contentImage,
  });
}
