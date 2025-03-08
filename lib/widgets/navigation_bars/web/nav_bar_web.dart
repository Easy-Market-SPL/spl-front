import 'package:flutter/material.dart';
import 'package:spl_front/models/logic/user_type.dart';
import 'package:spl_front/theme/colors/primary_colors.dart';
import 'package:spl_front/utils/ui/ui_user_type_helper.dart';
import 'package:spl_front/widgets/navigation_bars/user_types_navbar_items.dart';

class AppBarWeb extends StatelessWidget implements PreferredSizeWidget {
  final UserType userType;
  final BuildContext context;

  const AppBarWeb({
    super.key,
    required this.userType,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final items = navbarItemsByUserTypeWeb[userType]!;
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    
    return AppBar(
      automaticallyImplyLeading: false,
      actions: <Widget>[Container()],
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          // Logo or App Title
          Text(
            'Easy Market',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: PrimaryColors.darkBlue,
            ),
          ),
          const SizedBox(width: 30),
          // Menu items: show if there's enough space
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: items.map((item) {
                        final bool isActive = currentRoute == item.route;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: _NavbarItem(
                            item: item,
                            isActive: isActive,
                            onTap: () {
                              Navigator.pushNamed(context, item.route);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );
                } else {
                  // For smaller widths
                  return const SizedBox.shrink();
                }
              },
            ),
          ),

          // Avatar that opens the drawer
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[300],
                radius: 20,
                child: Text(
                  UIUserTypeHelper.getAvatarTextFromUserType(userType),
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Internal widget for navbar item with hover effect.
class _NavbarItem extends StatefulWidget {
  final NavbarItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavbarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavbarItem> createState() => _NavbarItemState();
}

class _NavbarItemState extends State<_NavbarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final bool showUnderline = _isHovering || widget.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: widget.onTap,
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.isActive ? Colors.blueAccent : Colors.grey[800],
                  fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: double.infinity,
                color: showUnderline ? Colors.blueAccent : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
