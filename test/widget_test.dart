import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:safewalk/app.dart';
import 'package:safewalk/viewmodels/auth_viewmodel.dart';
import 'package:safewalk/viewmodels/caminata_viewmodel.dart';
import 'package:safewalk/viewmodels/mapa_viewmodel.dart';
import 'package:safewalk/viewmodels/notificacion_viewmodel.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
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

    expect(find.text('SafeWalk'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
