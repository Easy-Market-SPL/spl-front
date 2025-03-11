import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/utils/strings/payment_strings.dart';

import '../../../bloc/ui_management/payment/payment_bloc.dart';

class PaymentMethodCard extends StatelessWidget {
  final String details;
  final String iconPath;
  final int index;

  const PaymentMethodCard({
    super.key,
    required this.details,
    required this.iconPath,
    required this.index,
  });

  void _showDeleteDialog(BuildContext context, String lastFourDigits) {
    double mediaQueryWidth = MediaQuery.of(context).size.width / 2.5;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Center(
            child: Text(
              PaymentStrings.confirmDeleteCard,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PaymentStrings.deleteAnnouncement(lastFourDigits),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(mediaQueryWidth, 50),
                      side: const BorderSide(color: Colors.blue),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      PaymentStrings.cancelDelete,
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<PaymentBloc>(context)
                          .add(DeleteCardEvent(index));
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(mediaQueryWidth, 50),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      PaymentStrings.delete,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(index),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        String lastFourDigits = details.substring(details.length - 4);
        _showDeleteDialog(context, lastFourDigits);
        return false;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: SizedBox(
            height: 40,
            width: 40,
            child: Image.asset(
              iconPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 30,
                );
              },
            ),
          ),
          title: Text(
            details,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
