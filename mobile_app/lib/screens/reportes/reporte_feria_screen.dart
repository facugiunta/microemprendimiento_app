import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReporteFeriaScreen extends StatefulWidget {
  const ReporteFeriaScreen({super.key});

  @override
  State<ReporteFeriaScreen> createState() => _ReporteFeriaScreenState();
}

class _ReporteFeriaScreenState extends State<ReporteFeriaScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _inversionController;
  late TextEditingController _gastosController;
  DateTime _fechaSeleccionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _inversionController = TextEditingController();
    _gastosController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _inversionController.dispose();
    _gastosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reporte de Feria',
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
              decoration: const InputDecoration(
                labelText: 'Nombre de la feria',
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  initialDate: _fechaSeleccionada,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (fecha != null) setState(() => _fechaSeleccionada = fecha);
              },
              child: InputDecorationTextField(
                'Fecha de la feria',
                '${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inversionController,
              decoration: const InputDecoration(
                labelText: 'Inversión del puesto',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _gastosController,
              decoration: const InputDecoration(labelText: 'Gastos varios'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Guardar Reporte'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputDecorationTextField extends StatelessWidget {
  final String label;
  final String value;

  const InputDecorationTextField(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        hintText: value,
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
