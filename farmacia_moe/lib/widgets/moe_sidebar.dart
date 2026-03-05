import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/navigation_provider.dart';

class MoeSidebar extends StatelessWidget {
  const MoeSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // Título opcional pequeño o logo si deseas
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "MENÚ PRINCIPAL",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12
                    ),
                  ),
                ),
                _item(context, Icons.inventory_2_outlined, "Inventario", 0),
                _item(context, Icons.add_circle_outline, "Registrar Medicina", 1),
                _item(context, Icons.shopping_cart_outlined, "Carrito", 2),
                _item(context, Icons.history_outlined, "Ventas Registradas", 3),
                _item(context, Icons.bar_chart_rounded, "Estadísticas", 4),
                _item(context, Icons.attach_money_rounded, "Ganancias", 5),
              ],
            ),
          ),
          
          // Botón de cierre con flecha en el centro del borde derecho
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
    // Usamos listen: false porque solo queremos ejecutar la función, no reconstruir el item aquí
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final isSelected = Provider.of<NavigationProvider>(context).currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? MoeTheme.lightBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon, 
          color: isSelected ? MoeTheme.primaryBlue : Colors.grey[700]
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
            color: isSelected ? MoeTheme.primaryBlue : Colors.black87
          )
        ),
        onTap: () {
          navProvider.setIndex(index); // Cambia la pantalla en el MainLayout
          Navigator.pop(context);      // Cierra el Sidebar
        },
      ),
    );
  }
}