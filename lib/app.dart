import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class SafeWalkApp extends StatelessWidget {
  const SafeWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SafeWalk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.tema,
      routerConfig: AppRouter.router,
    );
  }
}
