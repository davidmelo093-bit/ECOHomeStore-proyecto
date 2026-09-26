import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/screens/login_screen.dart';

void main() {
  Widget buildSubject({required void Function(String token, String username) onLoginSuccess}) {
    return MaterialApp(
      home: LoginScreen(onLoginSuccess: onLoginSuccess),
    );
  }

  testWidgets('Renderiza campos de email, password y botón de ingresar', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(onLoginSuccess: (_, _) {}));

    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Correo electrónico'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Contraseña'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Ingresar'), findsOneWidget);
  });

  testWidgets('Muestra mensaje de error si se presiona ingresar con campos vacíos', (WidgetTester tester) async {
    await tester.pumpWidget(buildSubject(onLoginSuccess: (_, _) {}));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
    await tester.pump();

    expect(find.text('Email y contraseña son obligatorios'), findsOneWidget);
  });
}
