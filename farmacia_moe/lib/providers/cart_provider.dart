import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

class CartItem {
  final Medicine medicine;
  int quantity;
  double customPrice; // Para el botón de descuentos que pediste

  CartItem({required this.medicine, required this.quantity}) 
      : customPrice = 0;

  // Lógica de precio: si la cantidad >= quantityPack, usa packagePrice
  double get total {
    if (customPrice > 0) return customPrice; // Prioridad al descuento manual
    
    if (medicine.quantityPack != null && 
        medicine.packagePrice != null && 
        quantity >= medicine.quantityPack!) {
      return medicine.packagePrice!;
    }
    return medicine.unitPrice * quantity;
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

  // LA VENTA SEGURA (Transacción Atómica)
  Future<String> finalizeSale() async {
    _isSaving = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        List<Map<String, dynamic>> saleItems = [];

        for (var cartItem in _items) {
          DocumentReference medRef = FirebaseFirestore.instance
              .collection('medicines').doc(cartItem.medicine.id);
          
          DocumentSnapshot snap = await transaction.get(medRef);
          int currentStock = snap.get('stock');

          if (currentStock < cartItem.quantity) {
            throw "Stock insuficiente para ${cartItem.medicine.name}";
          }

          // 1. Restar Stock
          transaction.update(medRef, {'stock': currentStock - cartItem.quantity});

          // 2. Preparar item para la colección 'sales'
          saleItems.add({
            'medicineId': cartItem.medicine.id,
            'medicineName': cartItem.medicine.name,
            'unitPrice': cartItem.medicine.unitPrice,
            'packagePrice': cartItem.medicine.packagePrice ?? 0,
            'quantity': cartItem.quantity,
            'quantityPack': cartItem.medicine.quantityPack ?? 0,
            'totalPrice': cartItem.total,
          });
        }

        // 3. Crear registro de venta
        DocumentReference saleRef = FirebaseFirestore.instance.collection('sales').doc();
        transaction.set(saleRef, {
          'items': saleItems,
          'totalPrice': totalCart,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

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