import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String? activePrinciple;
  final String code;
  final String? block;
  final int stock;
  final double unitPrice;
  final double? packagePrice;
  final int? quantityPack;
  final double? buyPrice; // Nuevo campo
  final String? description;
  final DateTime? expirationDate;

  Medicine({
    required this.id,
    required this.name,
    this.activePrinciple,
    required this.code,
    this.block,
    required this.stock,
    required this.unitPrice,
    this.packagePrice,
    this.quantityPack,
    this.buyPrice,
    this.description,
    this.expirationDate,
  });

  // Convertir de Firestore a Objeto Dart
  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Medicine(
      id: doc.id,
      name: data['name'] ?? '',
      activePrinciple: data['activePrinciple'],
      code: data['code'] ?? '',
      block: data['block'],
      stock: (data['stock'] ?? 0).toInt(),
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      packagePrice: data['packagePrice']?.toDouble(),
      quantityPack: data['quantityPack']?.toInt(),
      buyPrice: data['buyPrice']?.toDouble(),
      description: data['description'],
      expirationDate: (data['expirationDate'] as Timestamp?)?.toDate(),
    );
  }

  // Convertir de Objeto Dart a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'activePrinciple': activePrinciple,
      'code': code,
      'block': block,
      'stock': stock,
      'unitPrice': unitPrice,
      'packagePrice': packagePrice,
      'quantityPack': quantityPack,
      'buyPrice': buyPrice,
      'description': description,
      'expirationDate': expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
    };
  }
}