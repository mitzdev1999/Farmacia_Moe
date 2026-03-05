import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'widgets/moe_sidebar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FarmaciaMoeApp());
}

class FarmaciaMoeApp extends StatelessWidget {
  const FarmaciaMoeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Farmacia de Moe',
      debugShowCheckedModeBanner: false,
      theme: MoeTheme.light,
      home: const MainLayout(), // Luego pondremos el Login aquí
    );
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Eliminamos la AppBar para maximizar el espacio
      drawer: MoeSidebar(),
      body: Stack(
        children: [
          // El contenido principal de la ventana (Inventario, etc.)
          const Center(child: Text("Contenido del Inventario")),

          // Botón flotante para abrir el Sidebar
          Positioned(
            top: 40, // Margen para no chocar con la barra de estado del celular
            left: 10,
            child: FloatingActionButton(
              mini: true, // Lo hacemos pequeño para que sea minimalista
              backgroundColor: MoeTheme.primaryBlue,
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}