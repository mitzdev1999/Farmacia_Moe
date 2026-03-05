import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

class CartItem {
  final Medicine medicine;
  int quantity;
  double customPrice;

  CartItem({required this.medicine, required this.quantity}) : customPrice = 0;

  // LÓGICA MATEMÁTICA DE PRECIOS (Paquetes + Unidades)
  double get total {
    // Si hay un precio manual (descuento), tiene prioridad total
    if (customPrice > 0) return customPrice;

    // Si no tiene configuración de paquetes, cálculo simple
    if (medicine.quantityPack == null || medicine.packagePrice == null || medicine.quantityPack! <= 0) {
      return medicine.unitPrice * quantity;
    }

    int cantPack = medicine.quantityPack!;
    double precioPack = medicine.packagePrice!;
    double precioUnit = medicine.unitPrice;

    // División entera (~/) para saber cuántos paquetes completos hay
    int numeroDePaquetes = quantity ~/ cantPack; 
    
    // Residuo (%) para saber cuántas unidades sobran
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

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0 && newQuantity <= _items[index].medicine.stock) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  void updateCustomPrice(int index, double newPrice) {
    _items[index].customPrice = newPrice;
    notifyListeners();
  }

  // TRANSACCIÓN SEGURA EN FIREBASE
  Future<String> finalizeSale() async {
    if (_items.isEmpty) return "El carrito está vacío";
    _isSaving = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        List<Map<String, dynamic>> saleItems = [];

        for (var cartItem in _items) {
          DocumentReference medRef = FirebaseFirestore.instance
              .collection('medicines').doc(cartItem.medicine.id);
          
          DocumentSnapshot snap = await transaction.get(medRef);
          if (!snap.exists) throw "El producto ${cartItem.medicine.name} ya no existe.";

          int currentStock = snap.get('stock');
          if (currentStock < cartItem.quantity) {
            throw "Stock insuficiente para ${cartItem.medicine.name}. Disponible: $currentStock";
          }

          // 1. Descontar Stock
          transaction.update(medRef, {'stock': currentStock - cartItem.quantity});

          // 2. Preparar el registro detallado para la venta
          saleItems.add({
            'medicineId': cartItem.medicine.id,
            'medicineName': cartItem.medicine.name,
            'quantity': cartItem.quantity,
            'totalPrice': cartItem.total,
          });
        }

        // 3. Crear el ticket de venta
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