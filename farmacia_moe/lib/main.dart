import 'package:farmacia_moe/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/inventory_screen.dart';
import 'providers/inventory_provider.dart';
import 'widgets/moe_sidebar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicialización de Firebase con las opciones generadas por FlutterFire CLI
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    MultiProvider(
      providers: [
        // El operador ..init() asegura que las medicinas se carguen apenas inicie la app
        ChangeNotifierProvider(create: (_) => InventoryProvider()..init()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const FarmaciaMoeApp(),
    ),
  );
}

class FarmaciaMoeApp extends StatelessWidget {
  const FarmaciaMoeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Farmacia de Moe',
      debugShowCheckedModeBanner: false,
      theme: MoeTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const MainLayout(),
      },
    );
  }
}

// Estructura principal con el Sidebar y el Botón Flotante
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MoeSidebar(),
      body: Stack(
        children: [
          // Pantalla principal (Inventario por defecto)
          const InventoryScreen(),

          // Botón flotante minimalista para abrir el menú lateral
          Positioned(
            top: 50, 
            left: 15,
            child: Builder(
              builder: (context) => FloatingActionButton(
                mini: true,
                elevation: 2,
                backgroundColor: MoeTheme.primaryBlue,
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}