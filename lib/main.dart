import 'package:core_dashboard/pages/authentication/logic/cubit/auth_cubit.dart';
import 'package:core_dashboard/pages/authentication/repositories/auth_repository.dart';
import 'package:core_dashboard/pages/categories/data/repositories/category_repository.dart';
import 'package:core_dashboard/pages/categories/logic/cubit/category_cubit.dart';
import 'package:core_dashboard/shared/navigation/routes.dart';
import 'package:core_dashboard/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
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
