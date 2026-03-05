import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/medicine_model.dart';
import '../theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final TextEditingController searchController = TextEditingController();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 100), // Espacio para el botón flotante
          
          // Buscador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: searchController,
              onChanged: (value) => provider.search(value),
              decoration: InputDecoration(
                hintText: "Buscar medicina o principio...",
                prefixIcon: const Icon(Icons.search, color: MoeTheme.primaryBlue),
                filled: true,
                fillColor: MoeTheme.lightBlue.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filtros Rápidos
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _filterButton("Todos", provider.showAll, provider),
                const SizedBox(width: 20),
                _filterButton("Pendientes", provider.filterPendientes, provider),
              ],
            ),
          ),

          // Lista de Medicamentos
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: provider.medicines.length,
                    itemBuilder: (context, index) {
                      final med = provider.medicines[index];
                      return _medicineTile(context, med);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Celda de la lista según tus requerimientos
  Widget _medicineTile(BuildContext context, Medicine med) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        onTap: () => _mostrarDetalles(context, med),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                med.name.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Text(
              "Bloque: ${med.block ?? 'N/A'}",
              style: const TextStyle(fontSize: 12, color: MoeTheme.primaryBlue, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${med.unitPrice} | Pack: \$${med.packagePrice ?? '0'}",
                style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: med.stock > 5 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Stock: ${med.stock}",
                  style: TextStyle(
                    color: med.stock > 5 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterButton(String label, VoidCallback onTap, InventoryProvider provider) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(color: MoeTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  // Ventana de Detalles (BottomSheet)
  void _mostrarDetalles(BuildContext context, Medicine med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text(med.name.toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue)),
            Text(med.activePrinciple ?? "Sin principio activo", style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic)),
            const Divider(height: 40),
            
            Expanded(
              child: ListView(
                children: [
                  _detailRow("Código", med.code),
                  _detailRow("Bloque", med.block ?? "No asignado"),
                  _detailRow("Stock", med.stock.toString()),
                  _detailRow("Vencimiento", med.expirationDate?.toString().split(' ')[0] ?? "N/A"),
                  _detailRow("Precio Compra", "\$${med.buyPrice ?? 0}"),
                  _detailRow("Precio Unitario", "\$${med.unitPrice}"),
                  _detailRow("Precio Pack", "\$${med.packagePrice ?? 0}"),
                  _detailRow("Cantidad Pack", med.quantityPack?.toString() ?? "N/A"),
                  const SizedBox(height: 20),
                  const Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(med.description ?? "Sin descripción", style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(Icons.shopping_basket, "Vender", Colors.green, () {}),
                _actionButton(Icons.edit, "Editar", Colors.orange, () {}),
                _actionButton(Icons.delete, "Borrar", Colors.red, () {}),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(onPressed: onTap, icon: Icon(icon, color: color, size: 30)),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}