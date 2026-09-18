import 'package:flutter/material.dart';
import '../../features/ocorrencias/ocorrencia_filtering.dart';
import '../theme/tokens.dart';

class OcorrenciaFilterResult {
  final String status;
  final String? papel;
  final DateTime? dataInicio;
  final DateTime? dataFim;

  const OcorrenciaFilterResult({
    required this.status,
    this.papel,
    this.dataInicio,
    this.dataFim,
  });
}

Future<OcorrenciaFilterResult?> showOcorrenciaFilterSheet(
  BuildContext context, {
  required List<StatusBucketOption> statusOptions,
  required Map<String, int> statusCounts,
  required String selectedStatus,
  required List<PapelOption> papelOptions,
  required String? selectedPapel,
  required DateTime? dataInicio,
  required DateTime? dataFim,
}) {
  return showModalBottomSheet<OcorrenciaFilterResult>(
    context: context,
    backgroundColor: context.c.bgSurface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _FilterSheetContent(
      statusOptions: statusOptions,
      statusCounts: statusCounts,
      initialStatus: selectedStatus,
      papelOptions: papelOptions,
      initialPapel: selectedPapel,
      initialInicio: dataInicio,
      initialFim: dataFim,
    ),
  );
}

class _FilterSheetContent extends StatefulWidget {
  final List<StatusBucketOption> statusOptions;
  final Map<String, int> statusCounts;
  final String initialStatus;
  final List<PapelOption> papelOptions;
  final String? initialPapel;
  final DateTime? initialInicio;
  final DateTime? initialFim;

  const _FilterSheetContent({
    required this.statusOptions,
    required this.statusCounts,
    required this.initialStatus,
    required this.papelOptions,
    required this.initialPapel,
    required this.initialInicio,
    required this.initialFim,
  });

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  late String _status;
  String? _papel;
  DateTime? _inicio;
  DateTime? _fim;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _papel = widget.initialPapel;
    _inicio = widget.initialInicio;
    _fim = widget.initialFim;
  }

  void _limpar() {
    setState(() {
      _status = kTodosBucket;
      _papel = null;
      _inicio = null;
      _fim = null;
    });
  }

  Future<void> _pickDate({required bool isInicio}) async {
    final now = DateTime.now();
    final c = context.c;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: (isInicio ? _inicio : _fim) ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(primary: c.accent, surface: c.bgElevated, onSurface: c.fg0)
              : ColorScheme.light(primary: c.accent, surface: c.bgElevated, onSurface: c.fg0),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _inicio = picked;
        } else {
          _fim = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: c.fg3, borderRadius: BorderRadius.circular(99)),
                ),
              ),
              Text('Filtros', style: SafeCoreType.title.copyWith(color: c.fg0)),
              const SizedBox(height: 18),
              const _Label('STATUS'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final opt in widget.statusOptions)
                    _FilterChip(
                      label: opt.label,
                      count: widget.statusCounts[opt.key],
                      selected: _status == opt.key,
                      onTap: () => setState(() => _status = opt.key),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _Label('MEU PAPEL'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final opt in widget.papelOptions)
                    _FilterChip(
                      label: opt.label,
                      selected: _papel == opt.value,
                      onTap: () => setState(() => _papel = opt.value),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _Label('PERÍODO (DATA DE REGISTRO)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _DateField(label: 'De', value: _inicio, onTap: () => _pickDate(isInicio: true))),
                  const SizedBox(width: 10),
                  Expanded(child: _DateField(label: 'Até', value: _fim, onTap: () => _pickDate(isInicio: false))),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _limpar,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: c.borderSoft),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SafeCoreRadius.md)),
                      ),
                      child: Text('Limpar', style: SafeCoreType.subtitle.copyWith(color: c.fg1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(
                        OcorrenciaFilterResult(status: _status, papel: _papel, dataInicio: _inicio, dataFim: _fim),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SafeCoreRadius.md)),
                      ),
                      child: Text('Aplicar', style: SafeCoreType.subtitle.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: SafeCoreType.label.copyWith(color: context.c.fg2, letterSpacing: .4),
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, this.count, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      borderRadius: BorderRadius.circular(SafeCoreRadius.pill),
      onTap: onTap,
      child: AnimatedContainer(
        duration: SafeCoreMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? c.accent.withValues(alpha: 0.15) : c.bgElevated,
          borderRadius: BorderRadius.circular(SafeCoreRadius.pill),
          border: Border.all(color: selected ? c.accent : c.borderSoft),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: SafeCoreType.body.copyWith(color: selected ? c.accent : c.fg1),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: c.bgBase, borderRadius: BorderRadius.circular(99)),
                child: Text('$count', style: SafeCoreType.micro.copyWith(color: c.fg2)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final text = value != null
        ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
        : label;
    return InkWell(
      borderRadius: BorderRadius.circular(SafeCoreRadius.sm),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: c.bgElevated,
          borderRadius: BorderRadius.circular(SafeCoreRadius.sm),
          border: Border.all(color: c.borderSoft),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: c.fg2),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: SafeCoreType.body.copyWith(color: value != null ? c.fg0 : c.fg3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
