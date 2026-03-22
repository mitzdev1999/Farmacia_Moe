import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../theme.dart';

class MoeSidebar extends StatelessWidget {
  const MoeSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: MoeTheme.primaryBlue),
            child: Center(
              child: Text(
                "Farmacia Moe",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _drawerItem(Icons.inventory, "Inventario", 0, navProvider, context),
          _drawerItem(Icons.add_circle, "Registrar Medicina", 1, navProvider, context),
          _drawerItem(Icons.shopping_cart, "Carrito", 2, navProvider, context),
          _drawerItem(Icons.history, "Historial de Ventas", 3, navProvider, context),
          _drawerItem(Icons.bar_chart, "Estadísticas", 4, navProvider, context),
          _drawerItem(Icons.attach_money, "Ganancias", 5, navProvider, context),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index, NavigationProvider nav, BuildContext context) {
    bool isSelected = nav.currentIndex == index;

    return ListTile(
      leading: Icon(icon, color: isSelected ? MoeTheme.primaryBlue : Colors.grey),
      title: Text(
        title, 
        style: TextStyle(
          color: isSelected ? MoeTheme.primaryBlue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        )
      ),
      onTap: () {
        nav.setIndex(index);
        Navigator.pop(context); // Cierra el Drawer
      },
    );
  }
}