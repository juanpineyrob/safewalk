import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';

class SafeWalkApp extends StatelessWidget {
  const SafeWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    return MaterialApp.router(
      title: 'SafeWalk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema,
      routerConfig: AppRouter.build(auth),
    );
  }
}
