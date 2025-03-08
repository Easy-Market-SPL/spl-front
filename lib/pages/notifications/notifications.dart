import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/dates/date_helper.dart';
import 'package:spl_front/utils/times/time_helper.dart';
import 'package:spl_front/widgets/menu/menu_header.dart';
import 'package:spl_front/widgets/navigation_bars/nav_bar.dart';

class NotificationsScreen extends StatelessWidget {
  final UserType userType;

  const NotificationsScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MenuHeader(userType: userType),
          Expanded(
            child: ListView(
              children: _notificationItems(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(userType: userType, context: context,),
    );
  }

  //TODO: Replace with real data
  List<Widget> _notificationItems() {
    return [
      _notificationItem(
        icon: Icons.notifications,
        title: "Nueva orden disponible",
        description: "Hay una nueva orden lista para entrega",
        dateTime: DateTime(2025, 2, 26, 14, 0),
      ),
      _notificationItem(
        icon: Icons.notifications,
        title: "Orden entregada",
        description: "Se ha confirmado la entrega de la orden #123456",
        dateTime: DateTime(2025, 2, 26, 15, 0),
      ),
    ];
  }

  Widget _notificationItem({required IconData icon, required String title, required String description, required DateTime dateTime}) {
    final formattedDate = DateHelper.formatDate(dateTime);
    final formattedTime = TimeHelper.getFormattedTime(dateTime, is24HourFormat: false);

    return ListTile(
      leading: Icon(icon, size: 35),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text('$formattedDate $formattedTime', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
      subtitle: Text(description),
      isThreeLine: true,
    );
  }
}