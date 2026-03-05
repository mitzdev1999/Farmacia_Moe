// lib/widgets/moe_sidebar.dart
import 'package:flutter/material.dart';
import '../theme.dart';

class MoeSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          SafeArea( // Para que los items no queden debajo del notch
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // Espacio inicial estético
                _item(context, Icons.inventory_2_outlined, "Inventario", 0),
                _item(context, Icons.add_circle_outline, "Registrar Medicina", 1),
                _item(context, Icons.shopping_cart_outlined, "Carrito", 2),
                _item(context, Icons.history_outlined, "Ventas Registradas", 3),
                _item(context, Icons.bar_chart_rounded, "Estadísticas", 4),
                _item(context, Icons.attach_money_rounded, "Ganancias", 5),
              ],
            ),
          ),
          
          // Botón de cierre en el borde derecho central
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 60,
                width: 35,
                decoration: const BoxDecoration(
                  color: MoeTheme.primaryBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25), 
                    bottomLeft: Radius.circular(25)
                  )
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
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
      title: Text(  
        title, 
        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)
      ),
      onTap: () {
        // Implementaremos la navegación con Provider aquí
        Navigator.pop(context);
      },
    );
  }
}