import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/sales_provider.dart';
import '../theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    // Asegura que los datos existan al cargar las estadísticas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final chartData = salesProvider.getSalesDataForRange();
    final topMed = salesProvider.getTopMedicines();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Análisis de Ventas", 
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue)),
                    Text(
                      "${DateFormat('dd/MM').format(salesProvider.statsStartDate)} - ${DateFormat('dd/MM').format(salesProvider.statsEndDate)}",
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // BOTÓN REFRESH
                    IconButton(
                      onPressed: () => salesProvider.fetchSales(),
                      icon: const Icon(Icons.refresh, color: Colors.green),
                    ),
                    IconButton(
                      onPressed: () => _openRangePicker(context, salesProvider),
                      icon: const Icon(Icons.calendar_today_rounded, color: MoeTheme.primaryBlue, size: 28),
                    ),
                  ],
                )
              ],
            ),
            
            const SizedBox(height: 30),

            _buildSectionTitle("Ingresos Diarios"),
            const SizedBox(height: 20),
            _buildChartContainer(chartData, salesProvider),

            const SizedBox(height: 40),

            _buildSectionTitle("Productos más vendidos"),
            const SizedBox(height: 15),
            if (topMed.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(30),
                child: Text("No hay registros en este rango", style: TextStyle(color: Colors.grey)),
              ))
            else
              ...topMed.entries.map((e) => _buildTopTile(e.key, e.value)).toList(),
          ],
        ),
      ),
    );
  }

  // --- LOS MÉTODOS WIDGET SE MANTIENEN IGUAL ---
  Future<void> _openRangePicker(BuildContext context, SalesProvider provider) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: provider.statsStartDate, end: provider.statsEndDate),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: MoeTheme.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      provider.setStatsRange(picked.start, picked.end);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87));
  }

  Widget _buildChartContainer(List<double> data, SalesProvider provider) {
    return Container(
      height: 240,
      padding: const EdgeInsets.only(top: 30, right: 10, left: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: MoeTheme.primaryBlue,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                DateTime dateOfBar = provider.statsStartDate.add(Duration(days: group.x.toInt()));
                return BarTooltipItem(
                  "${DateFormat('dd/MM').format(dateOfBar)}\n",
                  const TextStyle(color: Colors.white70, fontSize: 10),
                  children: [
                    TextSpan(
                      text: "\$${rod.toY.toStringAsFixed(0)}",
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          ),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) => 
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: data[i], 
                color: MoeTheme.primaryBlue, 
                width: data.length > 12 ? 8 : 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4))
              )
            ])
          ),
        ),
      ),
    );
  }

  Widget _buildTopTile(String name, int qty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: MoeTheme.lightBlue,
            radius: 18,
            child: Icon(Icons.trending_up, color: MoeTheme.primaryBlue, size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
            child: Text("$qty unid.", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}