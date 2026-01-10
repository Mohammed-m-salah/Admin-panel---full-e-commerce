import 'package:core_dashboard/pages/authentication/logic/cubit/auth_cubit.dart';
import 'package:core_dashboard/pages/authentication/repositories/auth_repository.dart';
import 'package:core_dashboard/pages/banner/data/repository/banner_repository.dart';
import 'package:core_dashboard/pages/banner/logic/cubit/banner_cubit.dart';
import 'package:core_dashboard/pages/categories/data/repositories/category_repository.dart';
import 'package:core_dashboard/pages/categories/logic/cubit/category_cubit.dart';
import 'package:core_dashboard/pages/customer/data/repositories/customer_repository.dart';
import 'package:core_dashboard/pages/customer/logic/cubit/customer_cubit.dart';
import 'package:core_dashboard/pages/inventory/data/repositories/inventory_repository.dart';
import 'package:core_dashboard/pages/inventory/logic/cubit/inventory_cubit.dart';
import 'package:core_dashboard/pages/offers/data/repositories/offer_repository.dart';
import 'package:core_dashboard/pages/products/data/repositories/product_repositories.dart';
import 'package:core_dashboard/pages/products/logic/cubit/product_cubit.dart';
import 'package:core_dashboard/shared/navigation/routes.dart';
import 'package:core_dashboard/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:core_dashboard/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notifications
  await NotificationService.initialize();

  await Supabase.initialize(
    url: 'https://blpirgrhytbjmapmjfnq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJscGlyZ3JoeXRiam1hcG1qZm5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU3OTIyODQsImV4cCI6MjA4MTM2ODI4NH0.dv9MbRJm_Yv903cr1709H2ypVbWYEUvGNwSUOBCSQTs',
  );
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => CategoryRepository()),
        RepositoryProvider(create: (_) => ProductRepository()),
        RepositoryProvider(create: (_) => CustomerRepository()),
        RepositoryProvider(create: (_) => OfferRepository()),
        RepositoryProvider(create: (_) => InventoryRepository()),
        RepositoryProvider(create: (_) => BannerRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthCubit(context.read<AuthRepository>())..checkStatus(),
          ),
          BlocProvider(
            create: (context) =>
                CategoryCubit(context.read<CategoryRepository>())
                  ..fetchCategories(),
          ),
          BlocProvider(
            create: (context) => ProductCubit(
              context.read<ProductRepository>(),
            )..fetchProducts(),
          ),
          BlocProvider(
            create: (context) => CustomerCubit(
              context.read<CustomerRepository>(),
            )..fetchCustomers(),
          ),
          BlocProvider(
            create: (context) => CustomerCubit(
              (context.read<OfferRepository>()..getAllOffers())
                  as CustomerRepository,
            ),
          ),
          BlocProvider(
            create: (context) => InventoryCubit(
                (context.read<InventoryRepository>()..getAllInventory())),
          ),
          BlocProvider(
            create: (context) => BannerCubit(
              context.read<BannerRepository>(),
            )..loadBanners(), // ← هنا نستدعي loadBanners() لجلب البانرات
          ),
        ],
        child: MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(context),
      routerConfig: routerConfig,
    );
  }
}
