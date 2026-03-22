import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

class CartItem {
  final Medicine medicine;
  int quantity;
  double customPrice;

  CartItem({required this.medicine, required this.quantity}) : customPrice = 0;

  double get total {
    // Si hay un precio manual, manda sobre cualquier otra lógica
    if (customPrice > 0) return customPrice;

    // Lógica de paquetes/unidades
    if (medicine.quantityPack == null || medicine.packagePrice == null || medicine.quantityPack! <= 0) {
      return medicine.unitPrice * quantity;
    }

    int cantPack = medicine.quantityPack!;
    double precioPack = medicine.packagePrice!;
    double precioUnit = medicine.unitPrice;

    int numeroDePaquetes = quantity ~/ cantPack; 
    int unidadesSueltas = quantity % cantPack;

    return (numeroDePaquetes * precioPack) + (unidadesSueltas * precioUnit);
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isSaving = false;

  List<CartItem> get items => _items;
  bool get isSaving => _isSaving;

  double get totalCart => _items.fold(0, (sum, item) => sum + item.total);

  void addToCart(Medicine medicine, int quantity) {
    _items.add(CartItem(medicine: medicine, quantity: quantity));
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  // --- MÉTODOS REPARADOS PARA TU ERROR DE COMPILACIÓN ---

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _items.length) {
      // Validamos que no supere el stock disponible que ya conocemos
      if (newQuantity > 0 && newQuantity <= _items[index].medicine.stock) {
        _items[index].quantity = newQuantity;
        notifyListeners();
      }
    }
  }

  void updateCustomPrice(int index, double newPrice) {
    if (index >= 0 && index < _items.length) {
      _items[index].customPrice = newPrice;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // --- LÓGICA DE GUARDADO DE ALTO RENDIMIENTO ---

  Future<String> finalizeSale() async {
    if (_items.isEmpty) return "El carrito está vacío";
    _isSaving = true;
    notifyListeners();

    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      List<Map<String, dynamic>> saleItems = [];

      for (var cartItem in _items) {
        DocumentReference medRef = FirebaseFirestore.instance
            .collection('medicines').doc(cartItem.medicine.id);
        
        // Descontamos stock sin leer el documento (0 lecturas)
        batch.update(medRef, {
          'stock': FieldValue.increment(-cartItem.quantity)
        });

        saleItems.add({
          'medicineId': cartItem.medicine.id,
          'medicineName': cartItem.medicine.name,
          'quantity': cartItem.quantity,
          'totalPrice': cartItem.total,
        });
      }

      DocumentReference saleRef = FirebaseFirestore.instance.collection('sales').doc();
      batch.set(saleRef, {
        'items': saleItems,
        'totalPrice': totalCart,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Se ejecuta todo en un solo viaje al servidor

      _items.clear();
      _isSaving = false;
      notifyListeners();
      return "SUCCESS";
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return e.toString();
    }
  }
}