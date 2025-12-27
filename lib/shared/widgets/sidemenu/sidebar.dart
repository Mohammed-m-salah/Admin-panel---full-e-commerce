import 'package:core_dashboard/pages/authentication/logic/cubit/auth_cubit.dart';
import 'package:core_dashboard/pages/authentication/logic/cubit/auth_state.dart';
import 'package:core_dashboard/pages/customer/data/repositories/customer_repository.dart';
import 'package:core_dashboard/pages/customer/logic/cubit/customer_cubit.dart';
import 'package:core_dashboard/pages/customer/view/customers_page.dart';
import 'package:core_dashboard/pages/dashboard/widgets/theme_tabs.dart';
import 'package:core_dashboard/responsive.dart';
import 'package:core_dashboard/shared/constants/defaults.dart';
import 'package:core_dashboard/shared/constants/ghaps.dart';
import 'package:core_dashboard/shared/widgets/sidemenu/customer_info.dart';
import 'package:core_dashboard/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../constants/config.dart';
import 'menu_tile.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // width: Responsive.isMobile(context) ? double.infinity : null,
      // width: MediaQuery.of(context).size.width < 1300 ? 260 : null,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (Responsive.isMobile(context))
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDefaults.padding,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: SvgPicture.asset('assets/icons/close_filled.svg'),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDefaults.padding,
                    vertical: AppDefaults.padding * 1.5,
                  ),
                  child: SvgPicture.asset(AppConfig.logo),
                ),
              ],
            ),
            const Divider(),
            gapH16,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.padding,
                ),
                child: ListView(
                  children: [
                    MenuTile(
                      isActive: true,
                      title: "Home",
                      activeIconSrc: "assets/icons/home_filled.svg",
                      inactiveIconSrc: "assets/icons/home_light.svg",
                      onPressed: () {},
                    ),
                    ExpansionTile(
                      leading:
                          SvgPicture.asset("assets/icons/diamond_light.svg"),
                      title: Text(
                        "Products",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                      children: [
                        MenuTile(
                          isSubmenu: true,
                          title: "Products",
                          count: 16,
                          onPressed: () => context.go('/products'),
                        ),
                        MenuTile(
                          isSubmenu: true,
                          title: "Categories",
                          onPressed: () => context.go('/categories'),
                        ),
                      ],
                    ),

                    // Customers
                    ExpansionTile(
                      leading: SvgPicture.asset(
                          "assets/icons/profile_circled_light.svg"),
                      title: Text(
                        "Customers",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                      children: [
                        MenuTile(
                          isSubmenu: true,
                          title: "All Customers",
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) =>
                                    CustomerCubit(CustomerRepository())
                                      ..fetchCustomers(),
                                child: const CustomersPage(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    MenuTile(
                      title: "Shop",
                      activeIconSrc: "assets/icons/store_light.svg",
                      inactiveIconSrc: "assets/icons/store_filled.svg",
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                children: [
                  // عرض بيانات الأدمن من Supabase
                  BlocBuilder<AuthCubit, myAuthState>(
                    builder: (context, state) {
                      if (state is Authenticated) {
                        return CustomerInfo(
                          name: state.admin.name,
                          designation: state.admin.role ? 'Admin' : 'User',
                          imageSrc: state.admin.avatar_url ?? '',
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  gapH8,
                  const Divider(),
                  gapH8,
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/help_light.svg',
                        height: 24,
                        width: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textLight,
                          BlendMode.srcIn,
                        ),
                      ),
                      gapW8,
                      Text(
                        'Help & getting started',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Chip(
                        backgroundColor: AppColors.secondaryLavender,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 0.5),
                        label: Text(
                          "8",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  gapH20,
                  const ThemeTabs(),
                  gapH8,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
