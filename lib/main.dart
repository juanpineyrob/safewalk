import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/caminata_viewmodel.dart';
import 'viewmodels/mapa_viewmodel.dart';
import 'viewmodels/notificacion_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MapaViewModel()),
        ChangeNotifierProvider(create: (_) => CaminataViewModel()),
        ChangeNotifierProvider(create: (_) => NotificacionViewModel()),
      ],
      child: const SafeWalkApp(),
    ),
  );
}
