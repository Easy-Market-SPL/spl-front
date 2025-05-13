import 'package:flutter/material.dart';
import 'package:spl_front/models/chat_models/chat.dart';

Widget chatItem(Chat chat) {
  final fromCustomer = chat.sender == 'customer';

  return Column(
    children: [
      ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: fromCustomer ? Colors.blue[200] : Colors.grey[300],
          child: Icon(
            fromCustomer ? Icons.person : Icons.support_agent,
            color: Colors.white,
          ),
        ),
        title: Text(
          chat.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: fromCustomer ? Colors.blue[800] : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chat.message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontStyle: fromCustomer ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${chat.date} ${chat.time}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        tileColor: fromCustomer ? Colors.blue[50] : Colors.white,
        selectedTileColor: fromCustomer ? Colors.blue[100] : null,
      ),
      const Divider(height: 1),
    ],
  );
}