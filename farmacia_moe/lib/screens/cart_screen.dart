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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Text("Carrito de Venta", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue)),
          ),
          
          Expanded(
            child: cartProvider.items.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return _buildCartCard(context, item, index, cartProvider);
                    },
                  ),
          ),

          if (cartProvider.items.isNotEmpty) _buildBottomPanel(context, cartProvider),
        ],
      ),
    );
  }

  Widget _buildCartCard(BuildContext context, CartItem item, int index, CartProvider provider) {
    // Calculamos para el texto informativo
    int paks = 0;
    int units = item.quantity;
    if (item.medicine.quantityPack != null && item.medicine.quantityPack! > 0) {
      paks = item.quantity ~/ item.medicine.quantityPack!;
      units = item.quantity % item.medicine.quantityPack!;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Cantidad principal
              Container(
                height: 45, width: 45,
                decoration: BoxDecoration(color: MoeTheme.lightBlue, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue, fontSize: 18)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.medicine.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Bloque: ${item.medicine.block}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    // DESGLOSE DE PAQUETES (Solo si aplica)
                    if (paks > 0)
                      Text("Contiene: $paks Pack + $units Unid.", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
              Text("\$${item.total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const Divider(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _btnAccion(Icons.edit, "Cant.", Colors.blue, () => _editQty(context, provider, index, item)),
              const SizedBox(width: 8),
              _btnAccion(Icons.discount, "Precio", Colors.orange, () => _editPrice(context, provider, index)),
              const SizedBox(width: 8),
              _btnAccion(Icons.delete_forever, "Quitar", Colors.red, () => provider.removeItem(index)),
            ],
          )
        ],
      ),
    );
  }

  Widget _btnAccion(IconData icon, String txt, Color color, VoidCallback tap) {
    return InkWell(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(txt, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  void _editQty(BuildContext context, CartProvider p, int i, CartItem item) {
    final c = TextEditingController(text: item.quantity.toString());
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Cambiar Cantidad"),
      content: TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "Stock: ${item.medicine.stock}")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        ElevatedButton(onPressed: () { p.updateQuantity(i, int.tryParse(c.text) ?? 1); Navigator.pop(context); }, child: const Text("Cambiar")),
      ],
    ));
  }

  void _editPrice(BuildContext context, CartProvider p, int i) {
    final c = TextEditingController();
    showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text("Precio Especial"),
      content: TextField(controller: c, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: "\$")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
        ElevatedButton(onPressed: () { p.updateCustomPrice(i, double.tryParse(c.text) ?? 0.0); Navigator.pop(context); }, child: const Text("Aplicar")),
      ],
    ));
  }

  Widget _buildBottomPanel(BuildContext context, CartProvider provider) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -4))], borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        // CONTADOR DE ÍTEMS ÚNICOS
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("PRODUCTOS DIFERENTES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
          Text("${provider.items.length}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
        ]),
        const SizedBox(height: 5),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("TOTAL DE VENTA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text("\$${provider.totalCart.toStringAsFixed(0)}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue)),
        ]),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: MoeTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          onPressed: provider.isSaving ? null : () => _pagar(context, provider),
          child: provider.isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("FINALIZAR Y COBRAR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ))
      ])),
    );
  }

  void _pagar(BuildContext context, CartProvider p) async {
    final res = await p.finalizeSale();
    if (res == "SUCCESS" && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Venta Guardada"), backgroundColor: Colors.green));
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ $res"), backgroundColor: Colors.red));
    }
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Agrega productos desde el Inventario", style: TextStyle(color: Colors.grey)));
  }
}