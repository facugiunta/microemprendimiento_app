import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/inversion_provider.dart';
import 'package:mobile_app/models/inversion.dart';
import 'package:google_fonts/google_fonts.dart';

class InversionFormScreen extends StatefulWidget {
  final int? inversionId;

  const InversionFormScreen({super.key, this.inversionId});

  @override
  State<InversionFormScreen> createState() => _InversionFormScreenState();
}

class _InversionFormScreenState extends State<InversionFormScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _descController;
  late TextEditingController _montoController;
  String _categoriaSeleccionada = Inversion.categorias[0];
  final DateTime _fechaSeleccionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _descController = TextEditingController();
    _montoController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final nombre = _nombreController.text.trim();
    final monto = double.tryParse(_montoController.text) ?? 0;

    if (nombre.isEmpty || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos obligatorios')),
      );
      return;
    }

    final inversionProvider = context.read<InversionProvider>();

    bool success;
    if (widget.inversionId != null) {
      success = await inversionProvider.actualizarInversion(
        widget.inversionId!,
        nombre: nombre,
        descripcion: _descController.text,
        monto: monto,
        categoria: _categoriaSeleccionada,
        fecha: _fechaSeleccionada,
      );
    } else {
      success = await inversionProvider.crearInversion(
        nombre: nombre,
        descripcion: _descController.text,
        monto: monto,
        categoria: _categoriaSeleccionada,
        fecha: _fechaSeleccionada,
      );
    }

    if (success && mounted) {
      context.go('/home/inversiones');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.inversionId != null ? 'Editar Inversión' : 'Nueva Inversión',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _montoController,
              decoration: const InputDecoration(labelText: 'Monto *'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _categoriaSeleccionada,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: Inversion.categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _categoriaSeleccionada = value!),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Consumer<InversionProvider>(
                builder: (context, provider, _) => ElevatedButton(
                  onPressed: provider.isLoading ? null : _handleSave,
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
