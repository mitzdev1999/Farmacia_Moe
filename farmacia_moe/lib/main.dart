import 'package:farmacia_moe/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme.dart';

// Importación de Providers
import 'providers/inventory_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';

// Importación de Pantallas
import 'screens/login_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/register_medicine_screen.dart';
import 'widgets/moe_sidebar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider()..init()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
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

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el índice actual del provider de navegación
    final navProvider = Provider.of<NavigationProvider>(context);

    // Lista de pantallas ordenadas según el Sidebar
    final List<Widget> screens = [
      const InventoryScreen(),         // Índice 0
      const RegisterMedicineScreen(),  // Índice 1
      const CartScreen(),               // Índice 2
      const Center(child: Text("Ventas Registradas")), // Índice 3
      const Center(child: Text("Estadísticas")),      // Índice 4
      const Center(child: Text("Ganancias")),         // Índice 5
    ];

    return Scaffold(
      drawer: MoeSidebar(),
      body: Stack(
        children: [
          // IndexedStack mantiene el estado de las pantallas al cambiar entre ellas
          IndexedStack(
            index: navProvider.currentIndex,
            children: screens,
          ),

          // Botón flotante para abrir el Drawer
          Positioned(
            top: 50, 
            left: 15,
            child: Builder(
              builder: (context) => FloatingActionButton(
                mini: true,
                elevation: 4,
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