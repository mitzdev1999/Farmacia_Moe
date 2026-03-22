import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sales_provider.dart';
import '../theme.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Se ejecuta una sola vez al entrar, y el Provider decidirá si lee o no.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final bool isFiltered = salesProvider.selectedDate != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Historial", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue)),
                    Text(
                      isFiltered 
                        ? "Ventas del ${DateFormat('dd/MM/yyyy').format(salesProvider.selectedDate!)}"
                        : "Todas las ventas registradas",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // BOTÓN REFRESH MANUAL
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.green),
                      tooltip: "Actualizar",
                      onPressed: () => salesProvider.refreshSales(),
                    ),
                    if (isFiltered)
                      IconButton(
                        icon: const Icon(Icons.history, color: Colors.orange),
                        onPressed: () => salesProvider.setDate(null),
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month, color: MoeTheme.primaryBlue, size: 30),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: salesProvider.selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) salesProvider.setDate(picked);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          _buildTotalCard(salesProvider),
          Expanded(
            child: salesProvider.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : salesProvider.sales.isEmpty 
                ? _buildNoSalesView(isFiltered)
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: salesProvider.sales.length,
                    itemBuilder: (context, index) {
                      final sale = salesProvider.sales[index];
                      return _buildSaleTile(sale);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ... (Los widgets _buildTotalCard, _buildSaleTile y _buildNoSalesView se mantienen igual)
  Widget _buildTotalCard(SalesProvider provider) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [MoeTheme.primaryBlue, Color(0xFF1E3A8A)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("GANANCIA TOTAL", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              Text("\$${provider.totalEarnings.toStringAsFixed(0)}", 
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaleTile(dynamic sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
      child: ExpansionTile(
        leading: CircleAvatar(backgroundColor: MoeTheme.lightBlue.withOpacity(0.5), child: const Icon(Icons.receipt, color: MoeTheme.primaryBlue)),
        title: Text("Ticket #${sale.id.substring(0, 5).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('hh:mm a').format(sale.timestamp)),
        trailing: Text("\$${sale.totalPrice.toStringAsFixed(0)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                ...sale.items.map<Widget>((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${item.quantity}x ${item.medicineName}"),
                      Text("\$${item.totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )).toList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNoSalesView(bool isFiltered) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
      const SizedBox(height: 10),
      Text(isFiltered ? "No hubo ventas en esta fecha" : "Aún no hay ventas registradas"),
    ]));
  }
}