import 'package:core_dashboard/responsive.dart';
import 'package:core_dashboard/shared/constants/defaults.dart';
import 'package:core_dashboard/shared/widgets/sidemenu/sidebar.dart';
import 'package:core_dashboard/shared/widgets/sidemenu/tab_sidebar.dart';
import 'package:flutter/material.dart';

import 'header.dart';

final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

/// Wrapper widget that includes Sidebar and Header for inner pages
class PageWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const PageWrapper({
    super.key,
    required this.child,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      drawer: Responsive.isMobile(context) ? const Sidebar() : null,
      body: Row(
        children: [
          if (Responsive.isDesktop(context)) const Sidebar(),
          if (Responsive.isTablet(context)) const TabSidebar(),
          Expanded(
            child: Column(
              children: [
                Header(drawerKey: _drawerKey),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1360),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDefaults.padding *
                            (Responsive.isMobile(context) ? 1 : 1.5),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
