import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';

class SalesProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<Sale> _allSales = [];
  bool _isLoading = true;

  // Filtros
  DateTime? _selectedDate;   
  DateTime _statsStartDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _statsEndDate = DateTime.now();

  // Getters
  bool get isLoading => _isLoading;
  DateTime? get selectedDate => _selectedDate;
  DateTime get statsStartDate => _statsStartDate;
  DateTime get statsEndDate => _statsEndDate;

  // --- MÉTODOS DE FILTRADO ---
  void setDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setStatsRange(DateTime start, DateTime end) {
    _statsStartDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    _statsEndDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    notifyListeners();
  }

  List<Sale> get sales {
    if (_selectedDate == null) return _allSales;
    return _allSales.where((sale) {
      return sale.timestamp.day == _selectedDate!.day &&
             sale.timestamp.month == _selectedDate!.month &&
             sale.timestamp.year == _selectedDate!.year;
    }).toList();
  }

  double get totalEarnings => sales.fold(0, (sum, item) => sum + item.totalPrice);

  // --- LÓGICA DE ESTADÍSTICAS ---
  List<Sale> get _filteredSalesForStats {
    return _allSales.where((sale) {
      return sale.timestamp.isAfter(_statsStartDate) && 
             sale.timestamp.isBefore(_statsEndDate);
    }).toList();
  }

  Map<String, int> getTopMedicines() {
    Map<String, int> counts = {};
    for (var sale in _filteredSalesForStats) {
      for (var item in sale.items) {
        counts[item.medicineName] = (counts[item.medicineName] ?? 0) + item.quantity;
      }
    }
    var sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  List<double> getSalesDataForRange() {
    int daysInRange = _statsEndDate.difference(_statsStartDate).inDays + 1;
    if (daysInRange <= 0) return [0.0];
    
    int limit = daysInRange > 31 ? 31 : daysInRange;
    List<double> totals = List.filled(limit, 0.0);

    for (var sale in _filteredSalesForStats) {
      int diff = sale.timestamp.difference(_statsStartDate).inDays;
      if (diff >= 0 && diff < limit) {
        totals[diff] += sale.totalPrice;
      }
    }
    return totals;
  }

  // --- LÓGICA DE CARGA OPTIMIZADA (SIN STREAM) ---
  
  // Se llama una sola vez al inicio o manualmente
  Future<void> init() async {
    if (_allSales.isNotEmpty) return; // Si ya hay datos, no re-leer
    await fetchSales();
  }

  // Método manual para refrescar (como el del inventario)
  Future<void> fetchSales() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Hacemos un GET único en lugar de un Snapshot activo
      final snapshot = await _db.collection('sales')
          .orderBy('timestamp', descending: true)
          .limit(500) // Opcional: limitar a las últimas 500 ventas para ahorrar
          .get();

      _allSales = snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Error al cargar ventas: $e");
    }
  }
}