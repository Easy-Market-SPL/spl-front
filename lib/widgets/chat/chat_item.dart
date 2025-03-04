import 'package:flutter/material.dart';

Widget chatItem(String name, String message, String date) {
  return Column(
    children: [
      ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          radius: 25,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        tileColor: Colors.white,
        hoverColor: Colors.blueGrey,
        splashColor: Colors.blueGrey,
        selectedColor: Colors.blueGrey,
      ),
      const Divider(),
    ],
  );
}