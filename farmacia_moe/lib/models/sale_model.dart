import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final double totalPrice;
  final DateTime timestamp;
  final List<SaleItem> items;

  Sale({required this.id, required this.totalPrice, required this.timestamp, required this.items});

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      items: (data['items'] as List).map((i) => SaleItem.fromMap(i)).toList(),
    );
  }
}

class SaleItem {
  final String medicineName;
  final int quantity;
  final double totalPrice;

  SaleItem({required this.medicineName, required this.quantity, required this.totalPrice});

  factory SaleItem.fromMap(Map data) {
    return SaleItem(
      medicineName: data['medicineName'] ?? 'Desconocido',
      quantity: data['quantity'] ?? 0,
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
    );
  }
}