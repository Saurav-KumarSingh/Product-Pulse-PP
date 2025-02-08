import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../const/colors.dart';
import '../widgets/customNavBar.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = "/notificationScreen";

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<NotificationItem>>? _notificationsStream;

  @override
  void initState() {
    super.initState();
    _setupNotificationsStream();
  }

  void _setupNotificationsStream() {
    final user = _auth.currentUser;
    if (user != null) {
      _notificationsStream = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .snapshots()
          .map((snapshot) {
        List<NotificationItem> notifications = [];
        DateTime now = DateTime.now();

        for (var doc in snapshot.docs) {
          try {
            String expiryDateStr = doc['expiryDate'] ?? '';
            String productName = doc['productName'] ?? 'Unknown Product';
            String imageUrl = doc['imageUrl'] ?? 'assets/images/dummy/img.png';

            DateTime? expiryDate = _parseExpiryDate(expiryDateStr);
            
            if (expiryDate != null) {
              // Set time to end of day for more accurate comparison
              expiryDate = DateTime(expiryDate.year, expiryDate.month, expiryDate.day, 23, 59, 59);
              now = DateTime(now.year, now.month, now.day);
              
              Duration difference = expiryDate.difference(now);
              int daysRemaining = difference.inDays;

              // Check if product is expired or expiring soon
              if (daysRemaining < 0) {
                // Product is expired
                notifications.add(
                  NotificationItem(
                    title: 'Product Expired',
                    message: '$productName has expired on ${_formatDate(expiryDate)}',
                    time: _getTimeAgo(expiryDate),
                    imageUrl: imageUrl,
                    isExpired: true,
                  ),
                );
              } else if (daysRemaining <= 7) {
                // Product will expire within a week
                String daysText = daysRemaining == 0 
                    ? 'today'
                    : daysRemaining == 1 
                        ? 'tomorrow'
                        : 'in $daysRemaining days';
                
                notifications.add(
                  NotificationItem(
                    title: 'Expiring Soon',
                    message: '$productName will expire $daysText',
                    time: _getTimeAgo(expiryDate),
                    imageUrl: imageUrl,
                    isExpired: false,
                  ),
                );
              }
            }
          } catch (e) {
            print('Error processing notification: $e');
          }
        }

        // Sort notifications by urgency (expired first, then by days remaining)
        notifications.sort((a, b) {
          if (a.isExpired && !b.isExpired) return -1;
          if (!a.isExpired && b.isExpired) return 1;
          return a.time.compareTo(b.time);
        });
        
        return notifications;
      });
    }
  }

  DateTime? _parseExpiryDate(String dateStr) {
    try {
      List<String> parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTimeAgo(DateTime date) {
    Duration difference = DateTime.now().difference(date);
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

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
          StreamBuilder<List<NotificationItem>>(
            stream: _notificationsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No notifications'));
              }

              List<NotificationItem> notifications = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 100),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(notification);
                },
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: notification.imageUrl.startsWith('http') || notification.imageUrl.startsWith('https')
              ? Image.network(
                  notification.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/dummy/img.png'),
                )
              : Image.asset(
                  notification.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: notification.isExpired ? Colors.red : Colors.orange,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            SizedBox(height: 4),
            Text(
              notification.time,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final String imageUrl;
  final bool isExpired;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.imageUrl,
    required this.isExpired,
  });
}
