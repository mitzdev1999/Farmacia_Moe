import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_model.dart';

class SalesProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<Sale> _allSales = []; // Todas las ventas de la DB
  DateTime? _selectedDate;   // Fecha elegida para filtrar
  bool _isLoading = true;

  List<Sale> get sales {
    if (_selectedDate == null) return _allSales;
    return _allSales.where((sale) {
      return sale.timestamp.day == _selectedDate!.day &&
             sale.timestamp.month == _selectedDate!.month &&
             sale.timestamp.year == _selectedDate!.year;
    }).toList();
  }

  DateTime? get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  double get totalEarnings => sales.fold(0, (sum, item) => sum + item.totalPrice);

  void setDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void init() {
    _db.collection('sales')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _allSales = snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList();
      _isLoading = false;
      notifyListeners();
    });
  }
}