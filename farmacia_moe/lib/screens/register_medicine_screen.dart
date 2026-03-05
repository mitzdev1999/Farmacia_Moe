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
  bool _isSaving = false;

  // Controladores de texto
  final TextEditingController nameController = TextEditingController();
  final TextEditingController principleController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController packagePriceController = TextEditingController();
  final TextEditingController quantityPackController = TextEditingController();
  final TextEditingController buyPriceController = TextEditingController();
  final TextEditingController blockController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  DateTime? selectedDate;
  String generatedCode = "";

  // Lógica de generación de código: Primera y última letra + número o "MED"
  void _updateGeneratedCode(String name) {
    if (name.trim().isEmpty) {
      setState(() => generatedCode = "");
      return;
    }
    
    String firstWord = name.trim().split(' ')[0];
    String firstLetter = firstWord[0].toUpperCase();
    String lastLetter = firstWord[firstWord.length - 1].toUpperCase();
    
    // Buscar cualquier número en el nombre completo (ej: 500mg)
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
      initialDate: DateTime.now().add(const Duration(days: 365)), // Sugerir 1 año a futuro
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: MoeTheme.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _registrarMedicina() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('medicines').add({
        'name': nameController.text.trim().toLowerCase(),
        'activePrinciple': principleController.text.trim().toLowerCase(),
        'code': generatedCode,
        'unitPrice': double.tryParse(unitPriceController.text) ?? 0.0,
        'packagePrice': double.tryParse(packagePriceController.text),
        'quantityPack': int.tryParse(quantityPackController.text),
        'buyPrice': double.tryParse(buyPriceController.text) ?? 0.0,
        'block': blockController.text.trim(),
        'stock': int.tryParse(stockController.text) ?? 0,
        'description': descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        'expirationDate': selectedDate != null ? Timestamp.fromDate(selectedDate!) : null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text("✅ Medicina registrada correctamente")),
        );
        _limpiarFormulario();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text("❌ Error de permisos o red: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState!.reset();
    nameController.clear();
    principleController.clear();
    unitPriceController.clear();
    packagePriceController.clear();
    quantityPackController.clear();
    buyPriceController.clear();
    blockController.clear();
    stockController.clear();
    descriptionController.clear();
    setState(() {
      selectedDate = null;
      generatedCode = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text("Nueva Medicina", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue)),
              const Text("Completa los datos para el inventario", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              
              _buildInput(nameController, "Nombre del producto *", Icons.medication, isRequired: true, onChanged: _updateGeneratedCode),
              
              if (generatedCode.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15, left: 5),
                  child: Text("Código sugerido: $generatedCode", style: const TextStyle(fontWeight: FontWeight.bold, color: MoeTheme.primaryBlue)),
                ),

              _buildInput(principleController, "Principio Activo", Icons.science_outlined),
              
              Row(
                children: [
                  Expanded(child: _buildInput(unitPriceController, "Precio Venta *", Icons.attach_money, isNumber: true, isRequired: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput(buyPriceController, "Precio Compra", Icons.shopping_bag_outlined, isNumber: true)),
                ],
              ),

              Row(
                children: [
                  Expanded(child: _buildInput(packagePriceController, "Precio Pack", Icons.inventory_2_outlined, isNumber: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput(quantityPackController, "Cant. Pack", Icons.grid_view, isNumber: true)),
                ],
              ),

              Row(
                children: [
                  Expanded(child: _buildInput(blockController, "Bloque/Ubicación *", Icons.grid_on, isRequired: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput(stockController, "Stock Inicial *", Icons.add_chart, isNumber: true, isRequired: true)),
                ],
              ),

              _buildInput(descriptionController, "Notas adicionales", Icons.description_outlined, maxLines: 2),

              const SizedBox(height: 10),
              // Selector de Fecha Estilizado
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: MoeTheme.lightBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MoeTheme.primaryBlue.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null ? "Fecha de Vencimiento" : "Vence: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}",
                        style: TextStyle(color: selectedDate == null ? Colors.grey[700] : MoeTheme.primaryBlue, fontWeight: FontWeight.w500),
                      ),
                      const Icon(Icons.calendar_today, color: MoeTheme.primaryBlue),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MoeTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _registrarMedicina,
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Guardar en Inventario", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool isRequired = false, int maxLines = 1, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: MoeTheme.primaryBlue, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          filled: true,
          fillColor: MoeTheme.lightBlue.withOpacity(0.3),
          labelStyle: const TextStyle(color: Colors.black54),
        ),
        validator: (value) => isRequired && (value == null || value.isEmpty) ? "Campo obligatorio" : null,
      ),
    );
  }
}