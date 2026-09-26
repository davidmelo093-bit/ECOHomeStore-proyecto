import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_app/screens/chat_screen.dart';
import 'package:store_app/screens/products_screen.dart';

void main() {
  group('ProductsScreen Tests', () {
    testWidgets('Renderiza estado inicial y campo de búsqueda', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProductsScreen(
            token: 'fake-token',
            username: 'testuser',
            onLogout: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Debe mostrar el título del usuario
      expect(find.textContaining('testuser'), findsOneWidget);
    });
  });

  group('ChatScreen Tests', () {
    testWidgets('Renderiza estado inicial del chat', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChatScreen(
            token: 'fake-token',
            username: 'testuser',
          ),
        ),
      );

      expect(find.text('Chat'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
