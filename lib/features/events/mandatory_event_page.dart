import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/features/events/event_senders.dart';
import 'package:netmera_flutter_example/model/MandatoryEvent.dart';
import 'package:netmera_flutter_example/ui/app_colors.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';

class MandatoryEventPage extends StatefulWidget {
  const MandatoryEventPage({super.key});

  @override
  State<MandatoryEventPage> createState() => _MandatoryEventPageState();
}

class _MandatoryEventPageState extends State<MandatoryEventPage> {
  final _boolArray = TextEditingController();
  final _double = TextEditingController();
  final _long = TextEditingController();
  final _name = TextEditingController();
  final _surnames = TextEditingController();
  final _age = TextEditingController();
  DateTime? _timestamp;
  DateTimeRange? _dateRange;

  Map<String, String> _errors = {};

  @override
  void dispose() {
    for (final controller in [
      _boolArray,
      _double,
      _long,
      _name,
      _surnames,
      _age,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  List<bool>? _parseBoolArray() {
    final values = _boolArray.text
        .split(',')
        .map((e) => e.trim().toLowerCase());
    if (values.any((e) => e != 'true' && e != 'false')) return null;
    return values.map((e) => e == 'true').toList();
  }

  List<String>? _parseSurnames() {
    final text = _surnames.text.trim();
    return text.isEmpty ? null : text.split(',').map((e) => e.trim()).toList();
  }

  void _send() {
    final boolArray = _parseBoolArray();
    final doubleValue = double.tryParse(_double.text.trim());
    final longValue = int.tryParse(_long.text.trim());
    final name = _name.text.trim();

    setState(() {
      _errors = {
        if (boolArray == null)
          'boolArray': 'Enter comma-separated true/false values',
        if (doubleValue == null) 'double': 'Enter a valid decimal number',
        if (longValue == null) 'long': 'Enter a valid integer number',
        if (_timestamp == null) 'timestamp': 'Timestamp is required',
        if (name.isEmpty) 'name': 'Name is required',
      };
    });
    if (_errors.isNotEmpty) return;

    final event = MandatoryEvent(
      booelenattrMandatorytrueArray: boolArray!,
      doubleattrMandatorytrue: doubleValue!,
      longattrMandatorytrue: longValue!,
      timestampMandatorytrue: _timestamp!,
      nameMandatorytrue: name,
    );
    final age = int.tryParse(_age.text.trim());
    if (age != null) event.setAgeMandotoryfalse(age);
    final surnames = _parseSurnames();
    if (surnames != null) event.setSurnameMandatoryfalseArray(surnames);
    if (_dateRange != null) {
      event.setDateAttrMandatoryfalseArray([
        _dateRange!.start,
        _dateRange!.end,
      ]);
    }

    EventSenders.send(event);
    showFeedback('MandatoryEvent sent.');
  }

  Future<void> _pickTimestamp() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _timestamp = date);
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (range != null) setState(() => _dateRange = range);
  }

  static String _day(DateTime date) => date.toLocal().toString().split(' ')[0];

  @override
  Widget build(BuildContext context) {
    final dateRange = _dateRange;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Field(
          id: 'boolArray',
          label: 'Boolean Array (required)',
          hint: 'true,false',
          controller: _boolArray,
          error: _errors['boolArray'],
        ),
        _Field(
          id: 'double',
          label: 'Double Value (required)',
          controller: _double,
          error: _errors['double'],
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
        ),
        _Field(
          id: 'long',
          label: 'Long Value (required)',
          controller: _long,
          error: _errors['long'],
          keyboardType: TextInputType.number,
        ),
        _PickerField(
          id: 'timestamp',
          label: 'Timestamp (required)',
          value: _timestamp == null ? null : _day(_timestamp!),
          placeholder: 'Select date',
          error: _errors['timestamp'],
          onTap: _pickTimestamp,
        ),
        _Field(
          id: 'name',
          label: 'Name (required)',
          controller: _name,
          error: _errors['name'],
        ),
        _Field(
          id: 'surnames',
          label: 'Surnames (optional)',
          hint: 'comma separated',
          controller: _surnames,
        ),
        _Field(
          id: 'age',
          label: 'Age (optional)',
          controller: _age,
          keyboardType: TextInputType.number,
        ),
        _PickerField(
          id: 'dateRange',
          label: 'Date Range (optional)',
          value: dateRange == null
              ? null
              : '${_day(dateRange.start)} to ${_day(dateRange.end)}',
          placeholder: 'Select date range',
          onTap: _pickDateRange,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          key: const ValueKey('mandatoryEvent.send'),
          onPressed: _send,
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.id,
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.keyboardType,
  });

  final String id;
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? error;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        key: ValueKey('mandatoryEvent.$id'),
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: error,
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.id,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.error,
  });

  final String id;
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        key: ValueKey('mandatoryEvent.$id'),
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(labelText: label, errorText: error),
          child: Text(
            value ?? placeholder,
            style: TextStyle(
              color: value == null ? AppColors.placeholder : AppColors.label,
            ),
          ),
        ),
      ),
    );
  }
}
