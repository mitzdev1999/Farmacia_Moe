import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class RegisterMedicineScreen extends StatefulWidget {
  const RegisterMedicineScreen({super.key});

  @override
  State<RegisterMedicineScreen> createState() => _RegisterMedicineScreenState();
}

class _RegisterMedicineScreenState extends State<RegisterMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final nameController = TextEditingController();
  final principleController = TextEditingController();
  final unitPriceController = TextEditingController();
  final packagePriceController = TextEditingController();
  final quantifyPackController = TextEditingController();
  final buyPriceController = TextEditingController();
  final blockController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  
  DateTime? selectedDate;
  String generatedCode = "";

  // Función para generar el código automáticamente
  void _generateCode(String name) {
    if (name.isEmpty) return;
    
    String firstWord = name.trim().split(' ')[0];
    String firstLetter = firstWord[0].toUpperCase();
    String lastLetter = firstWord[firstWord.length - 1].toUpperCase();
    
    // Buscar números en el nombre (ej: 250MG -> 250)
    RegExp regExp = RegExp(r'\d+');
    var match = regExp.firstMatch(name);
    String suffix = match != null ? match.group(0)! : "MED";
    
    setState(() {
      generatedCode = "$firstLetter$lastLetter-$suffix";
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance.collection('medicines').add({
        'name': nameController.text.toLowerCase(),
        'activePrinciple': principleController.text.toLowerCase(),
        'code': generatedCode,
        'unitPrice': double.parse(unitPriceController.text),
        'packagePrice': double.tryParse(packagePriceController.text),
        'quantityPack': int.tryParse(quantifyPackController.text),
        'buyPrice': double.tryParse(buyPriceController.text),
        'block': blockController.text,
        'stock': int.parse(stockController.text),
        'description': descriptionController.text,
        'expirationDate': selectedDate != null ? Timestamp.fromDate(selectedDate!) : null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Medicina registrada con éxito")));
      _formKey.currentState!.reset();
      setState(() {
        selectedDate = null;
        generatedCode = "";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text("Registrar Medicina", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue)),
              const SizedBox(height: 20),
              
              _input(nameController, "Nombre *", isRequired: true, onChanged: _generateCode),
              Text("Código generado: $generatedCode", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 15),
              
              _input(principleController, "Principio Activo (Opcional)"),
              _input(unitPriceController, "Precio Unitario *", isNumber: true, isRequired: true),
              
              Row(
                children: [
                  Expanded(child: _input(packagePriceController, "Precio Pack", isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _input(quantifyPackController, "Cant. Pack", isNumber: true)),
                ],
              ),
              
              _input(buyPriceController, "Precio de Compra", isNumber: true),
              
              Row(
                children: [
                  Expanded(child: _input(blockController, "Bloque *", isRequired: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _input(stockController, "Stock Inicial *", isNumber: true, isRequired: true)),
                ],
              ),
              
              _input(descriptionController, "Descripción", maxLines: 3),
              
              // Selector de Fecha
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(selectedDate == null ? "Seleccionar Vencimiento" : "Vence: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}"),
                trailing: const Icon(Icons.calendar_month, color: MoeTheme.primaryBlue),
                onTap: () => _selectDate(context),
              ),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: MoeTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: _registrar,
                  child: const Text("Registrar Medicina", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, String label, {bool isNumber = false, bool isRequired = false, int maxLines = 1, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: MoeTheme.lightBlue.withOpacity(0.2),
        ),
        validator: (value) => isRequired && (value == null || value.isEmpty) ? "Requerido" : null,
      ),
    );
  }
}