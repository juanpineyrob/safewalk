import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/geocoding_service.dart';

class BuscarDestinoSheet extends StatefulWidget {
  const BuscarDestinoSheet({super.key});

  @override
  State<BuscarDestinoSheet> createState() => _BuscarDestinoSheetState();
}

class _BuscarDestinoSheetState extends State<BuscarDestinoSheet> {
  final _geocoding = GeocodingService();
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  List<SugerenciaLugar> _resultados = [];
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChange(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 380), () => _buscar(value));
  }

  Future<void> _buscar(String q) async {
    if (q.trim().length < 3) {
      setState(() {
        _resultados = [];
        _buscando = false;
      });
      return;
    }
    setState(() => _buscando = true);
    try {
      final r = await _geocoding.buscar(q);
      if (!mounted) return;
      setState(() {
        _resultados = r;
        _buscando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resultados = [];
        _buscando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.superficieAlta,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Buscar destino', style: theme.textTheme.titleLarge),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  focusNode: _focus,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Pocitos, Plaza Independencia…',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: _onChange,
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: _buscando
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _resultados.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                _controller.text.trim().length < 3
                                    ? 'Escribe al menos 3 caracteres'
                                    : 'Sin resultados',
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _resultados.length,
                              separatorBuilder: (_, __) => const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Divider(),
                              ),
                              itemBuilder: (context, i) {
                                final s = _resultados[i];
                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  leading: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppTheme.verdeSuave,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.place_outlined,
                                      color: AppTheme.verdePrimario,
                                      size: 19,
                                    ),
                                  ),
                                  title: Text(
                                    s.etiqueta.split(',').first.trim(),
                                    style: theme.textTheme.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    s.etiqueta,
                                    style: theme.textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.grisTerciario,
                                  ),
                                  onTap: () => Navigator.of(context).pop(s),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
