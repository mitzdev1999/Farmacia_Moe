// lib/screens/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return Column(
      children: [
        const SizedBox(height: 60), // Espacio para el botón flotante
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            onChanged: provider.search,
            decoration: InputDecoration(
              hintText: "Buscar por nombre o principio activo...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: MoeTheme.lightBlue.withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: provider.showAll, child: const Text("Todos")),
            const Text("|"),
            TextButton(onPressed: provider.filterPendientes, child: const Text("Pendientes")),
          ],
        ),
        Expanded(
          child: provider.isLoading 
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: provider.medicines.length,
                itemBuilder: (context, index) {
                  final med = provider.medicines[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(med.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("Bloque: ${med.block ?? 'N/A'}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("\$${med.unitPrice} | Pack: \$${med.packagePrice ?? '0'}"),
                          Text("Stock: ${med.stock}", style: TextStyle(
                            color: med.stock < 5 ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold
                          )),
                        ],
                      ),
                      onTap: () {
                        // Aquí abriremos la ventana de detalles
                      },
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
}