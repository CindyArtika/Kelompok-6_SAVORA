import 'package:flutter_test/flutter_test.dart';
import 'package:tubes_pemmob/main.dart';

void main() {
  testWidgets('Login page berhasil ditampilkan', (WidgetTester tester) async {
    await tester.pumpWidget(const SavoraApp());

    expect(find.text('Selamat Datang di SAVORA'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}