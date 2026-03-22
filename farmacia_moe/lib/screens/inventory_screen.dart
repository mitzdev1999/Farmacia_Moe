import 'package:farmacia_moe/providers/cart_provider.dart';
import 'package:farmacia_moe/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/inventory_provider.dart';
import '../models/medicine_model.dart';
import '../theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargamos los datos al iniciar, pero sin disparar streams infinitos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).init();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Este botón abre el Drawer del MainLayout
        leading: IconButton(
          icon: const Icon(Icons.menu, color: MoeTheme.primaryBlue),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text(
          "Inventario",
          style: TextStyle(color: MoeTheme.primaryBlue, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => provider.refreshInventory(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Actualizar datos",
          ),
          const SizedBox(width: 10),
        ],
      ),

      // BOTÓN FLOTANTE: Ahora cambia el índice del NavigationProvider
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              FloatingActionButton(
                backgroundColor: MoeTheme.primaryBlue,
                onPressed: () => navProvider.setIndex(2), // Índice del Carrito
                child: const Icon(Icons.shopping_cart, color: Colors.white),
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '${cart.items.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: searchController,
              onChanged: (value) => provider.search(value),
              decoration: InputDecoration(
                hintText: "Buscar medicina...",
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _filterButton("Todos", provider.showAll),
                const SizedBox(width: 20),
                _filterButton("Pendientes", provider.filterPendientes),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 80),
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

  // --- WIDGETS DE LA LISTA ---

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

  Widget _filterButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(color: MoeTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  // --- MODALES Y DIÁLOGOS ---

  void _mostrarDetalles(BuildContext context, Medicine med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
                _actionButton(Icons.shopping_basket, "Vender", Colors.green, () {
                  Navigator.pop(context);
                  _showQuantityDialog(context, med);
                }),
                _actionButton(Icons.edit, "Editar", MoeTheme.primaryBlue, () {
                  Navigator.pop(context);
                  _showEditForm(context, med);
                }),
                _actionButton(Icons.delete, "Borrar", Colors.red, () {
                  _confirmarBorrado(context, med);
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showEditForm(BuildContext context, Medicine med) {
    final nameController = TextEditingController(text: med.name);
    final principleController = TextEditingController(text: med.activePrinciple);
    final blockController = TextEditingController(text: med.block);
    final descController = TextEditingController(text: med.description);
    final unitPriceController = TextEditingController(text: med.unitPrice.toString());
    final packPriceController = TextEditingController(text: med.packagePrice?.toString() ?? "0");
    final qtyPackController = TextEditingController(text: med.quantityPack?.toString() ?? "0");
    final stockController = TextEditingController(text: med.stock.toString());
    DateTime? tempDate = med.expirationDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25, right: 25, top: 25
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Editar Medicina", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue)),
                const SizedBox(height: 20),
                _buildEditInput(nameController, "Nombre", Icons.medication),
                _buildEditInput(principleController, "Principio Activo", Icons.science),
                Row(
                  children: [
                    Expanded(child: _buildEditInput(unitPriceController, "Precio Unit.", Icons.attach_money, isNum: true)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildEditInput(stockController, "Stock", Icons.inventory, isNum: true)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildEditInput(packPriceController, "Precio Pack", Icons.auto_awesome_motion, isNum: true)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildEditInput(qtyPackController, "Cant. Pack", Icons.grid_view, isNum: true)),
                  ],
                ),
                _buildEditInput(blockController, "Bloque", Icons.grid_on),
                _buildEditInput(descController, "Descripción", Icons.description, maxLines: 2),
                
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tempDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setModalState(() => tempDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: MoeTheme.lightBlue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tempDate == null ? "Fecha Vencimiento" : DateFormat('dd/MM/yyyy').format(tempDate!),
                             style: const TextStyle(fontWeight: FontWeight.w500)),
                        const Icon(Icons.calendar_today, color: MoeTheme.primaryBlue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: MoeTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () {
                      Provider.of<InventoryProvider>(context, listen: false).updateMedicine(
                        id: med.id,
                        name: nameController.text,
                        activePrinciple: principleController.text,
                        block: blockController.text,
                        description: descController.text,
                        expirationDate: tempDate,
                        packagePrice: double.tryParse(packPriceController.text) ?? 0.0,
                        quantityPack: int.tryParse(qtyPackController.text) ?? 0,
                        stock: int.tryParse(stockController.text) ?? 0,
                        unitPrice: double.tryParse(unitPriceController.text) ?? 0.0,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text("Guardar Cambios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, Medicine med) {
    final TextEditingController qtyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Vender ${med.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Disponible: ${med.stock}"),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Cantidad a vender"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              int qty = int.tryParse(qtyController.text) ?? 0;
              if (qty > 0 && qty <= med.stock) {
                Provider.of<CartProvider>(context, listen: false).addToCart(med, qty);
                searchController.clear();
                Provider.of<InventoryProvider>(context, listen: false).showAll();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agregado al carrito")));
              }
            }, 
            child: const Text("Agregar")
          ),
        ],
      ),
    );
  }

  void _confirmarBorrado(BuildContext context, Medicine med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar producto"),
        content: Text("¿Estás seguro de eliminar ${med.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('medicines').doc(med.id).delete();
              Navigator.pop(context);
              Navigator.pop(context);
            }, 
            child: const Text("Eliminar", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  // --- COMPONENTES VISUALES ---

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

  Widget _buildEditInput(TextEditingController controller, String label, IconData icon, {bool isNum = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: MoeTheme.primaryBlue, size: 20),
          filled: true,
          fillColor: MoeTheme.lightBlue.withOpacity(0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}