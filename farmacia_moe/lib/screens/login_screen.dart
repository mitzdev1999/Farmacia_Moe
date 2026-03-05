import 'package:flutter/material.dart';
import '../theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_pharmacy, size: 80, color: MoeTheme.primaryBlue),
            const SizedBox(height: 20),
            const Text(
              "La Farmacia de Moe",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue),
            ),
            const SizedBox(height: 40),
            TextField(
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MoeTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  // Por ahora navega directo al MainLayout
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text("Entrar", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}