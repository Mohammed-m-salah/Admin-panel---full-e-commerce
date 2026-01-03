import 'package:core_dashboard/pages/authentication/register_page.dart';
import 'package:core_dashboard/pages/authentication/sign_in_page.dart';
import 'package:core_dashboard/pages/banner/data/repository/banner_repository.dart';
import 'package:core_dashboard/pages/banner/logic/cubit/banner_cubit.dart';
import 'package:core_dashboard/pages/banner/view/banner_page.dart';
import 'package:core_dashboard/pages/categories/categories_page.dart';
import 'package:core_dashboard/pages/categories/data/repositories/category_repository.dart';
import 'package:core_dashboard/pages/categories/logic/cubit/category_cubit.dart';
import 'package:core_dashboard/pages/customer/view/customers_page.dart';
import 'package:core_dashboard/pages/customer/data/repositories/customer_repository.dart';
import 'package:core_dashboard/pages/customer/logic/cubit/customer_cubit.dart';
import 'package:core_dashboard/pages/dashboard/dashboard_page.dart';
import 'package:core_dashboard/pages/entry_point.dart';
import 'package:core_dashboard/pages/inventory/view/inventory_page.dart';
import 'package:core_dashboard/pages/notifications/view/notifications_page.dart';
import 'package:core_dashboard/pages/offers/view/offers_page.dart';
import 'package:core_dashboard/pages/offers/data/repositories/offer_repository.dart';
import 'package:core_dashboard/pages/offers/logic/cubit/offer_cubit.dart';
import 'package:core_dashboard/pages/orders/view/orders_page.dart';
import 'package:core_dashboard/pages/orders/data/repositories/order_repository.dart';
import 'package:core_dashboard/pages/orders/logic/cubit/order_cubit.dart';
import 'package:core_dashboard/pages/products/data/repositories/product_repositories.dart';
import 'package:core_dashboard/pages/products/logic/cubit/product_cubit.dart';
import 'package:core_dashboard/pages/products/view/products_page.dart';
import 'package:core_dashboard/pages/reports/view/reports_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final routerConfig = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/entry-point',
      builder: (context, state) => const EntryPoint(),
    ),
    GoRoute(
      path: '/dahsboard-page',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => BlocProvider(
        create: (context) =>
            CategoryCubit(CategoryRepository())..fetchCategories(),
        child: const CategoriesPage(),
      ),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => BlocProvider(
        create: (context) => ProductCubit(ProductRepository())..fetchProducts(),
        child: const ProductsPage(),
      ),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => BlocProvider(
        create: (context) =>
            CustomerCubit(CustomerRepository())..fetchCustomers(),
        child: const CustomersPage(),
      ),
    ),
    GoRoute(
      path: '/offers',
      builder: (context, state) => BlocProvider(
        create: (context) => OfferCubit(OfferRepository())..fetchOffers(),
        child: const OffersPage(),
      ),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => BlocProvider(
        create: (context) => OrderCubit(OrderRepository())..fetchOrders(),
        child: const OrdersPage(),
      ),
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryPage(),
    ),
    GoRoute(
      path: '/banners',
      builder: (context, state) => BlocProvider(
        create: (context) => BannerCubit(BannerRepository())..loadBanners(),
        child: const BannerPage(),
      ),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsPage(),
    ),

    // GoRoute(
    //   path: '/forgot-password',
    //   builder: (context, state) => const ForgotPasswordScreen(),
    // ),
    // GoRoute(
    //   path: '/password-confirmation/:email',
    //   builder: (context, state) {
    //     final email = state.pathParameters['email'];
    //     if (email == null) {
    //       throw Exception('Recipe ID is missing');
    //     }
    //     return PasswordConfirmationForm(email: email);
    //   },
    // ),
    // GoRoute(
    //   path: '/resend-email-verification',
    //   builder: (context, state) => const EmailResendScreen(),
    // ),
    // GoRoute(
    //   path: '/user-confirmation/:email',
    //   builder: (context, state) {
    //     final email = state.pathParameters['email'];
    //     if (email == null) {
    //       throw Exception('Recipe ID is missing');
    //     }
    //     return UserConfirmationForm(email: email);
    //   },
    // ),
    // GoRoute(
    //   path: '/favorite',
    //   builder: (context, state) => const FavoriteScreen(),
    // ),
    // GoRoute(
    //   path: '/recipe/:id',
    //   builder: (context, state) {
    //     final id = state.pathParameters['id'];
    //     if (id == null) {
    //       throw Exception('Recipe ID or Favorite state is missing');
    //     }
    //     return RecipeDetailsScreen(
    //       id: id,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: '/profile',
    //   builder: (context, state) => const ProfileScreen(),
    // ),
    // GoRoute(
    //   path: '/edit-profile',
    //   builder: (context, state) => const EditProfileScreen(),
    // ),
    // GoRoute(
    //   path: '/all-recipes',
    //   builder: (context, state) => const AllRecipesScreen(),
    // ),
    // GoRoute(
    //   path: '/search-recipes',
    //   builder: (context, state) => const SearchScreen(),
    // ),
    // GoRoute(
    //   path: '/notifications',
    //   builder: (context, state) => const NotificationsScreen(),
    // ),
  ],
);
