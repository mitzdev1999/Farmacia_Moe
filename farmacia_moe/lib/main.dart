import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Importaciones de Firebase (Asegúrate de que el archivo exista)
import 'firebase_options.dart';

// Importaciones de tu tema
import 'theme.dart';

// Importaciones de Providers
import 'providers/inventory_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/sales_provider.dart';

// Importaciones de Pantallas
import 'screens/inventory_screen.dart';
import 'screens/register_medicine_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/sales_history_screen.dart';
import 'screens/stats_screen.dart';

// Importación de Widgets
import 'widgets/moe_sidebar.dart';

// ... (Tus imports se mantienen igual)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
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
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    // CARGA PEREZOSA: Las pantallas pesadas solo existen si el índice es el correcto.
    // Esto evita que el initState de Historial se ejecute al abrir Inventario.
    final List<Widget> screens = [
      const InventoryScreen(),                // 0
      const RegisterMedicineScreen(),         // 1
      const CartScreen(),                     // 2
      navProvider.currentIndex == 3 
          ? const SalesHistoryScreen() 
          : const SizedBox.shrink(),          // 3 (Historial)
      navProvider.currentIndex == 4 
          ? const StatsScreen() 
          : const SizedBox.shrink(),          // 4 (Stats)
      const Center(child: Text("Ganancias")),  // 5
    ];

    return Scaffold(
      drawer: const MoeSidebar(),
      body: Stack(
        children: [
          IndexedStack(
            index: navProvider.currentIndex,
            children: screens,
          ),
          Positioned(
            top: 50, 
            left: 15,
            child: Builder(
              builder: (context) => FloatingActionButton(
                mini: true,
                elevation: 4,
                backgroundColor: MoeTheme.primaryBlue,
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}