import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

class InventoryProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<Medicine> _allMedicines = [];
  List<Medicine> _filteredMedicines = [];
  bool _isLoading = false;
  bool _hasLoaded = false; // Bandera para control de cuota de lecturas
  Timer? _debounce;

  List<Medicine> get medicines => _filteredMedicines;
  bool get isLoading => _isLoading;

  // CAMBIO VITAL: Usamos Future para realizar una petición única y ahorrar lecturas
  Future<void> init() async {
    // Si ya tenemos datos, no volvemos a consultar a Firebase para ahorrar cuota
    if (_hasLoaded) return; 

    _isLoading = true;
    notifyListeners();

    try {
      // .get() descarga la colección una sola vez en lugar de mantener un túnel abierto
      final snapshot = await _db.collection('medicines').get();
      
      _allMedicines = snapshot.docs.map((doc) => Medicine.fromFirestore(doc)).toList();
      _filteredMedicines = _allMedicines;
      _hasLoaded = true; 
    } catch (error) {
      debugPrint("Error en Firestore: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para forzar la recarga si es necesario (ej: un botón de refrescar)
  Future<void> refreshInventory() async {
    _hasLoaded = false;
    await init();
  }

  // MÉTODO PARA ACTUALIZAR TODOS LOS CAMPOS
  Future<void> updateMedicine({
    required String id,
    required String name,
    required String activePrinciple,
    required String block,
    required String description,
    required DateTime? expirationDate,
    required double packagePrice,
    required int quantityPack,
    required int stock,
    required double unitPrice,
  }) async {
    try {
      await _db.collection('medicines').doc(id).update({
        'name': name.toLowerCase(),
        'activePrinciple': activePrinciple.toLowerCase(),
        'block': block,
        'description': description,
        'expirationDate': expirationDate != null ? Timestamp.fromDate(expirationDate) : null,
        'packagePrice': packagePrice,
        'quantityPack': quantityPack,
        'stock': stock,
        'unitPrice': unitPrice,
      });
      
      // Actualizamos la lista local para reflejar el cambio sin re-descargar todo de Firebase
      int index = _allMedicines.indexWhere((m) => m.id == id);
      if (index != -1) {
        // Aquí podrías actualizar el objeto localmente si lo deseas, 
        // o simplemente llamar a refreshInventory() si la cuota no es problema en este punto.
      }
      
    } catch (e) {
      debugPrint("Error al actualizar: $e");
    }
  }

  // Tu lógica de búsqueda es excelente porque filtra en memoria (local) y es gratuita
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