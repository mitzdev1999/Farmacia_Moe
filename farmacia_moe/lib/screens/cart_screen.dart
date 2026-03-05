import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 100),
          const Text("Resumen de Venta", 
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue)),
          
          Expanded(
            child: cartProvider.items.isEmpty
                ? const Center(child: Text("Carrito vacío"))
                : ListView.builder(
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Badge de Cantidad
                                CircleAvatar(
                                  backgroundColor: MoeTheme.primaryBlue,
                                  radius: 18,
                                  child: Text("${item.quantity}", style: const TextStyle(color: Colors.white, fontSize: 14)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.medicine.name.toUpperCase(), 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      // MOSTRAR EL BLOQUE AQUÍ
                                      Text("Ubicación: ${item.medicine.block ?? 'S/N'}", 
                                        style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                Text("\$${item.total.toStringAsFixed(0)}", 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                              ],
                            ),
                            const Divider(height: 20),
                            // BOTONES DE ACCIÓN
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _actionIconButton(Icons.edit_note, "Cant.", Colors.blue, () => _showEditQty(context, cartProvider, index, item)),
                                const SizedBox(width: 10),
                                _actionIconButton(Icons.sell_outlined, "Desc.", Colors.orange, () => _showEditPrice(context, cartProvider, index)),
                                const SizedBox(width: 10),
                                _actionIconButton(Icons.delete_sweep, "Quitar", Colors.red, () => cartProvider.removeItem(index)),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
          _buildBottomSummary(context, cartProvider),
        ],
      ),
    );
  }

  Widget _actionIconButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // DIÁLOGO PARA EDITAR CANTIDAD
  void _showEditQty(BuildContext context, CartProvider provider, int index, dynamic item) {
    final controller = TextEditingController(text: item.quantity.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Cantidad"),
        content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "Máximo: ${item.medicine.stock}")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
          ElevatedButton(onPressed: () {
            provider.updateQuantity(index, int.tryParse(controller.text) ?? 1);
            Navigator.pop(context);
          }, child: const Text("Actualizar")),
        ],
      ),
    );
  }

  // DIÁLOGO PARA DESCUENTO (PRECIO A GUSTO)
  void _showEditPrice(BuildContext context, CartProvider provider, int index) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Precio Especial"),
        content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: "\$", hintText: "Nuevo precio total")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
          ElevatedButton(onPressed: () {
            provider.updateCustomPrice(index, double.tryParse(controller.text) ?? 0.0);
            Navigator.pop(context);
          }, child: const Text("Aplicar")),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, CartProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("TOTAL:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("\$${provider.totalCart.toStringAsFixed(0)}", 
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue)),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity, 
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: MoeTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: provider.isSaving ? null : () => _finalizar(context, provider),
                child: provider.isSaving 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("COBRAR AHORA", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _finalizar(BuildContext context, CartProvider provider) async {
    final res = await provider.finalizeSale();
    if (res == "SUCCESS") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Venta Exitosa"), backgroundColor: Colors.green));
    }
  }
}