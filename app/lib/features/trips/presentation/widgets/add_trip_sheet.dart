import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/trip.dart';
import '../../domain/trip_draft.dart';

class AddTripSheet extends StatefulWidget {
  const AddTripSheet({
    required this.selectedDate,
    required this.onSave,
    super.key,
  });

  final DateTime selectedDate;
  final Future<void> Function(Trip trip) onSave;

  @override
  State<AddTripSheet> createState() => _AddTripSheetState();
}

class _AddTripSheetState extends State<AddTripSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _commissionController = TextEditingController();
  final _id = const Uuid().v4();
  late final Duration _offset;
  late DateTime _start;
  late DateTime _end;
  PaymentMethod _payment = PaymentMethod.cash;
  bool _saving = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _offset = now.timeZoneOffset;
    _start = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      now.hour,
      now.minute,
    );
    _end = _start.add(const Duration(minutes: 20));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.light().copyWith(
      scaffoldBackgroundColor: AppTheme.receiptPaper,
      canvasColor: AppTheme.receiptPaper,
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9CA3AF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Новая поездка',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                _DateTimeField(
                  label: 'Начало',
                  value: _start,
                  onChanged: (value) => setState(() => _start = value),
                ),
                const SizedBox(height: 12),
                _DateTimeField(
                  label: 'Конец',
                  value: _end,
                  onChanged: (value) => setState(() => _end = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    suffixText: '₸',
                    border: OutlineInputBorder(),
                  ),
                  validator: (_) => _draft().validate()['amount'],
                ),
                const SizedBox(height: 12),
                SegmentedButton<PaymentMethod>(
                  segments: const [
                    ButtonSegment(
                      value: PaymentMethod.cash,
                      label: Text('Наличные'),
                      icon: Icon(Icons.payments_outlined),
                    ),
                    ButtonSegment(
                      value: PaymentMethod.card,
                      label: Text('Карта'),
                      icon: Icon(Icons.credit_card),
                    ),
                  ],
                  selected: {_payment},
                  onSelectionChanged: (value) =>
                      setState(() => _payment = value.first),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commissionController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Комиссия',
                    suffixText: '₸',
                    border: OutlineInputBorder(),
                  ),
                  validator: (_) => _draft().validate()['commission'],
                ),
                if (_serverError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _serverError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Сохранить'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _save() async {
    if (_saving) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _serverError = null);
    final errors = _draft().validate();
    if (!_formKey.currentState!.validate() || errors.containsKey('end')) {
      if (errors.containsKey('end')) {
        setState(() => _serverError = errors['end']);
      }
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.onSave(_draft().toTrip());
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() => _serverError = error.toString());
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  TripDraft _draft() => TripDraft(
    id: _id,
    start: TripTime(local: _start, offset: _offset),
    end: TripTime(local: _end, offset: _offset),
    amount: int.tryParse(_amountController.text),
    payment: _payment,
    commission: int.tryParse(_commissionController.text),
  );
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final date = await showDatePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        initialDate: value,
      );
      if (date == null || !context.mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(value),
      );
      if (time != null) {
        onChanged(
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        );
      }
    },
    borderRadius: BorderRadius.circular(4),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text(
        '${formatDate(value)} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
      ),
    ),
  );
}
