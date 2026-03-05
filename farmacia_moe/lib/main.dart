import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/inventory_screen.dart'; // Crearemos esta ahora
// import 'providers/inventory_provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    // Aquí envolveremos la app con MultiProvider más adelante
    const FarmaciaMoeApp(),
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
      // Definimos la ruta inicial
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/inventory': (context) => const InventoryScreen(),
      },
    );
  }
}