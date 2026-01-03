import 'package:core_dashboard/pages/authentication/logic/cubit/auth_cubit.dart';
import 'package:core_dashboard/pages/authentication/logic/cubit/auth_state.dart';
import 'package:core_dashboard/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../constants/defaults.dart';
import '../constants/ghaps.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.drawerKey});

  final GlobalKey<ScaffoldState> drawerKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDefaults.padding, vertical: AppDefaults.padding),
      color: AppColors.bgSecondayLight,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (Responsive.isMobile(context))
              IconButton(
                onPressed: () {
                  drawerKey.currentState!.openDrawer();
                },
                icon: Badge(
                  isLabelVisible: false,
                  child: SvgPicture.asset(
                    "assets/icons/menu_light.svg",
                  ),
                ),
              ),
            if (Responsive.isMobile(context))
              IconButton(
                onPressed: () {},
                icon: Badge(
                  isLabelVisible: false,
                  child: SvgPicture.asset("assets/icons/search_filled.svg"),
                ),
              ),
            if (!Responsive.isMobile(context))
              Expanded(
                flex: 1,
                child: TextFormField(
                  // style: Theme.of(context).textTheme.labelLarge,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                          left: AppDefaults.padding,
                          right: AppDefaults.padding / 2),
                      child: SvgPicture.asset("assets/icons/search_light.svg"),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: AppDefaults.outlineInputBorder,
                    focusedBorder: AppDefaults.focusedOutlineInputBorder,
                  ),
                ),
              ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!Responsive.isMobile(context))
                    IconButton(
                      onPressed: () => context.go('/support-chat'),
                      tooltip: 'Support Chat',
                      icon: Badge(
                        isLabelVisible: true,
                        label: const Text('5'),
                        child:
                            SvgPicture.asset("assets/icons/message_light.svg"),
                      ),
                    ),
                  if (!Responsive.isMobile(context)) gapW16,
                  if (!Responsive.isMobile(context))
                    IconButton(
                      onPressed: () {},
                      icon: Badge(
                        isLabelVisible: true,
                        child: SvgPicture.asset(
                            "assets/icons/notification_light.svg"),
                      ),
                    ),
                  if (!Responsive.isMobile(context)) gapW16,
                  // صورة الأدمن من Supabase
                  if (!Responsive.isMobile(context))
                    BlocBuilder<AuthCubit, myAuthState>(
                      builder: (context, state) {
                        String? avatarUrl;
                        String adminName = 'Admin';

                        if (state is Authenticated) {
                          avatarUrl = state.admin.avatar_url;
                          adminName = state.admin.name;
                        }

                        return CircleAvatar(
                          backgroundImage:
                              avatarUrl != null && avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : null,
                          child: avatarUrl == null || avatarUrl.isEmpty
                              ? Text(adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A')
                              : null,
                        );
                      },
                    ),
                  if (!Responsive.isMobile(context)) gapW16,
                  // زر Logout - فقط في Desktop
                  if (!Responsive.isMobile(context))
                    BlocBuilder<AuthCubit, myAuthState>(
                      builder: (context, state) {
                        if (state is Authenticated) {
                          return TextButton.icon(
                            onPressed: () {
                              context.read<AuthCubit>().logout();
                              context.go('/sign-in');
                            },
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text("Logout"),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
