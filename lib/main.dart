import 'package:flutter/material.dart';
import 'pages/product_catalog_page.dart';
import 'services/payment_service.dart';

Future<void> main() async {
  // Asegurar la inicialización de bindings para plugins de Flutter (Firebase, SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el servicio de pagos (intentará conectar a Firebase Firestore, o usará fallback local)
  final paymentService = PaymentService();
  await paymentService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulación de Pagos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E6AD2),
          primary: const Color(0xFF5E6AD2),
          secondary: const Color(0xFF1E1E2C),
        ),
        useMaterial3: true,
        fontFamily: 'Inter', // Utiliza una fuente limpia y moderna si está disponible
      ),
      home: const ProductCatalogPage(),
    );
  }
}
