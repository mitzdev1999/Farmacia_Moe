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
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text("La Farmacia de Moe", style: TextStyle(color: Colors.white)),
      ),
      drawer: MoeSidebar(),
      body: const Center(child: Text("Bienvenido al Inventario")),
    );
  }
}