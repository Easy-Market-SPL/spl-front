import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/widgets/navigation_bars/web/nav_bar_web.dart';
import 'package:spl_front/widgets/navigation_bars/web/side_bar_web.dart';

class WebScaffold extends StatelessWidget {
  final UserType userType;
  final Widget body;

  const WebScaffold({
    super.key,
    required this.userType,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? AppBarWeb(userType: userType, context: context,)
          : null,
      
      endDrawer: kIsWeb ? CustomSidebar(userType: userType) : null,
      body: body,
    );
  }
}