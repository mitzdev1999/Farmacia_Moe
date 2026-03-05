// lib/widgets/moe_sidebar.dart
import 'package:flutter/material.dart';
import '../theme.dart';

class MoeSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Stack(
        children: [
          Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: MoeTheme.primaryBlue),
                child: Center(
                  child: Text("La Farmacia de Moe", 
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              _item(context, Icons.inventory, "Inventario", 0),
              _item(context, Icons.add_box, "Registrar Medicina", 1),
              _item(context, Icons.shopping_cart, "Carrito", 2),
              _item(context, Icons.receipt_long, "Ventas", 3),
              _item(context, Icons.analytics, "Estadísticas", 4),
              _item(context, Icons.monetization_on, "Ganancias", 5),
            ],
          ),
          // El botón de flecha para cerrar en el borde derecho
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 50,
                width: 30,
                decoration: BoxDecoration(
                  color: MoeTheme.primaryBlue,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))
                ),
                child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 15),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: MoeTheme.primaryBlue),
      title: Text(title),
      onTap: () {
        // Aquí manejaremos el cambio de pantalla con Provider
      },
    );
  }
}