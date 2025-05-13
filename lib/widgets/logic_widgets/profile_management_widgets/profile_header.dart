import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userRoleTitle;
  final String userRoleDescription;
  const ProfileHeader(
      {super.key,
      required this.userName,
      required this.userRoleTitle,
      required this.userRoleDescription});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Information Icon
        CircleAvatar(
          backgroundColor: Colors.grey[300],
          radius: 40,
          child: Text(
            // Manage the user name
            _subStringUserName(userName),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Title and Subtitle of the Header
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userRoleTitle,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                userRoleDescription,
                style: TextStyle(fontSize: 14, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _subStringUserName(String userName) {
    return userName.substring(0, 2).toUpperCase();
  }
}
