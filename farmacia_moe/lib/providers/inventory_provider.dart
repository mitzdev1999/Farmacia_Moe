import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

class InventoryProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<Medicine> _allMedicines = [];
  List<Medicine> _filteredMedicines = [];
  bool _isLoading = false;
  Timer? _debounce;

  List<Medicine> get medicines => _filteredMedicines;
  bool get isLoading => _isLoading;

  // Cargar medicinas en tiempo real
  void init() {
    _isLoading = true;
    _db.collection('medicines').snapshots().listen((snapshot) {
      _allMedicines = snapshot.docs.map((doc) => Medicine.fromFirestore(doc)).toList();
      _filteredMedicines = _allMedicines;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Buscador con Debounce de 1.5 segundos
  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 1500), () {
      if (query.isEmpty) {
        _filteredMedicines = _allMedicines;
      } else {
        _filteredMedicines = _allMedicines.where((med) {
          final name = med.name.toLowerCase();
          final principle = med.activePrinciple?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || principle.contains(searchLower);
        }).toList();
      }
      notifyListeners();
    });
  }

  // Filtro de Pendientes (Precio <= 50 o Bloque es Null)
  void filterPendientes() {
    _filteredMedicines = _allMedicines.where((med) {
      return med.unitPrice <= 50 || med.block == null;
    }).toList();
    notifyListeners();
  }

  void showAll() {
    _filteredMedicines = _allMedicines;
    notifyListeners();
  }
}