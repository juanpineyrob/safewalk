import 'package:flutter/material.dart';

class ReportarZonaDatos {
  final String nombre;
  final String? descripcion;
  final String categoria;
  final double radioMetros;

  const ReportarZonaDatos({
    required this.nombre,
    this.descripcion,
    required this.categoria,
    required this.radioMetros,
  });
}

class ReportarZonaDialog extends StatefulWidget {
  const ReportarZonaDialog({super.key, required this.lat, required this.lon});

  final double lat;
  final double lon;

  @override
  State<ReportarZonaDialog> createState() => _ReportarZonaDialogState();
}

class _ReportarZonaDialogState extends State<ReportarZonaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _descripcion = TextEditingController();
  String _categoria = 'general';
  double _radio = 75;

  static const _categorias = [
    'general',
    'iluminacion',
    'asaltos',
    'vandalismo',
    'transito',
  ];

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ReportarZonaDatos(
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim().isEmpty
            ? null
            : _descripcion.text.trim(),
        categoria: _categoria,
        radioMetros: _radio,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reportar zona peligrosa'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ubicación: ${widget.lat.toStringAsFixed(5)}, '
                '${widget.lon.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v ?? 'general'),
              ),
              const SizedBox(height: 12),
              Text('Radio: ${_radio.round()} m'),
              Slider(
                value: _radio,
                min: 20,
                max: 500,
                divisions: 48,
                label: '${_radio.round()} m',
                onChanged: (v) => setState(() => _radio = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _enviar,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 40),
          ),
          child: const Text('Reportar'),
        ),
      ],
    );
  }
}
