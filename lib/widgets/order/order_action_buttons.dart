import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_bloc.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_event.dart';
import 'package:spl_front/bloc/ui_management/order_tracking/order_tracking_state.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/utils/strings/order_strings.dart';

class OrderActionButtons extends StatelessWidget {
  final String selectedStatus;
  final bool showDetailsButton;
  final bool showConfirmButton;
  final UserType userType;

  const OrderActionButtons({
    super.key,
    required this.selectedStatus,
    this.showDetailsButton = true,
    this.showConfirmButton = true,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDetailsButton)
          ElevatedButton(
            onPressed: () {
              _navigateToDetails(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 37, 139, 217),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(OrderStrings.orderDetailsTitle, style: TextStyle(color: Colors.white)),
          ),
        if (showDetailsButton) const SizedBox(height: 8.0),
        if (showConfirmButton)
          BlocBuilder<OrderStatusBloc, OrderStatusState>(
            builder: (context, state) {
              if (state is OrderStatusLoaded) {
                return ElevatedButton(
                  onPressed: selectedStatus != state.currentStatus ? () {
                    _confirmStatusChange(context);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedStatus != state.currentStatus ? const Color.fromARGB(255, 37, 139, 217) : Colors.grey[350],
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(OrderStrings.confirm, style: TextStyle(color: selectedStatus != state.currentStatus ?  Colors.white : Colors.black)),
                );
              } else {
                return Container();
              }
            },
          ),
      ],
    );
  }

  // Navigate to the appropriate details page based on userType
  void _navigateToDetails(BuildContext context) {
    // TODO: Pass the order ID to the details page
    if (userType == UserType.customer) {
      Navigator.of(context).pushNamed('customer_user_order_details');
    } else if (userType == UserType.business) {
      Navigator.of(context).pushNamed('business_user_order_details');
    }
  }

  // Confirm status change dialog
  void _confirmStatusChange(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(OrderStrings.confirmStatusChangeTitle),
          content: Text(OrderStrings.confirmStatusChangeContent(selectedStatus)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog without doing anything
              },
              child: const Text(OrderStrings.cancel, style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                // Emit the event only after the user confirms
                context.read<OrderStatusBloc>().add(ChangeOrderStatusEvent(selectedStatus));
                Navigator.of(context).pop();  // Close the dialog after confirming
              },
              child: const Text(OrderStrings.accept, style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}