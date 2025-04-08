import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/model/MandatoryEvent.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';

class MandatoryEventPage extends StatefulWidget {
  const MandatoryEventPage({super.key});

  @override
  State<MandatoryEventPage> createState() => _MandatoryEventPageState();
}

class _MandatoryEventPageState extends State<MandatoryEventPage> {
  List<bool>? _booelenattrMandatorytrueArray;
  double? _doubleattrMandatorytrue;
  int? _longattrMandatorytrue;
  DateTime? _timestampMandatorytrue;
  String? _nameMandatorytrue;
  List<DateTime>? _dateAttrMandatoryfalseArray;
  List<String>? _surnameMandatoryfalseArray;
  int? _ageMandotoryfalse;
  Mandatoryevent? event;

  final TextEditingController _boolArrayController = TextEditingController();
  final TextEditingController _doubleController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameArrayController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _boolArrayError;
  String? _doubleError;
  String? _longError;
  String? _nameError;
  String? _timestampError;

  @override
  void dispose() {
    _boolArrayController.dispose();
    _doubleController.dispose();
    _longController.dispose();
    _nameController.dispose();
    _surnameArrayController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mandatory Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _boolArrayController,
              decoration: _buildInputDecoration(
                "Boolean Array (comma separated, e.g., true,false)",
                errorText: _boolArrayError,
                isRequired: true,
              ),
              onChanged: (value) {
                setState(() {
                  try {
                    _booelenattrMandatorytrueArray = value.split(',').map((e) {
                      String trimmed = e.trim().toLowerCase();
                      if (trimmed != 'true' && trimmed != 'false') {
                        throw FormatException("Invalid boolean value");
                      }
                      return trimmed == 'true';
                    }).toList();
                    _boolArrayError = null;
                  } catch (e) {
                    _boolArrayError = "Enter comma-separated true/false values";
                    _booelenattrMandatorytrueArray = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _doubleController,
              decoration: _buildInputDecoration(
                "Double Value",
                errorText: _doubleError,
                isRequired: true,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _doubleError = null;
                    _doubleattrMandatorytrue = null;
                    return;
                  }

                  final parsed = double.tryParse(value);
                  if (parsed == null) {
                    _doubleError = "Enter a valid decimal number";
                    _doubleattrMandatorytrue = null;
                  } else {
                    _doubleError = null;
                    _doubleattrMandatorytrue = parsed;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _longController,
              decoration: _buildInputDecoration(
                "Long Value",
                errorText: _longError,
                isRequired: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _longError = null;
                    _longattrMandatorytrue = null;
                    return;
                  }

                  final parsed = int.tryParse(value);
                  if (parsed == null) {
                    _longError = "Enter a valid integer number";
                    _longattrMandatorytrue = null;
                  } else {
                    _longError = null;
                    _longattrMandatorytrue = parsed;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  setState(() {
                    _timestampMandatorytrue = selectedDate;
                    _timestampError = null;
                  });
                }
              },
              child: InputDecorator(
                decoration: _buildInputDecoration(
                  "Timestamp",
                  isRequired: true,
                  errorText: _timestampError,
                ),
                child: Text(
                  _timestampMandatorytrue != null
                      ? "${_timestampMandatorytrue?.toLocal()}".split(' ')[0]
                      : "Select date (required)",
                  style: TextStyle(
                    color: _timestampMandatorytrue != null
                        ? Colors.black87
                        : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: _buildInputDecoration(
                "Name",
                errorText: _nameError,
                isRequired: true,
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _nameError = "Name is required";
                    _nameMandatorytrue = null;
                  } else {
                    _nameError = null;
                    _nameMandatorytrue = value;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _surnameArrayController,
              decoration: _buildInputDecoration("Surnames (comma separated)"),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _surnameMandatoryfalseArray = null;
                  } else {
                    _surnameMandatoryfalseArray =
                        value.split(',').map((e) => e.trim()).toList();
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              decoration: _buildInputDecoration("Age (Optional)"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _ageMandotoryfalse = null;
                  } else {
                    _ageMandotoryfalse = int.tryParse(value);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final selectedDates = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDates != null) {
                  setState(() {
                    _dateAttrMandatoryfalseArray = [
                      selectedDates.start,
                      selectedDates.end,
                    ];
                  });
                }
              },
              child: InputDecorator(
                decoration: _buildInputDecoration("Date Range (Optional)"),
                child: Text(
                  _dateAttrMandatoryfalseArray != null
                      ? "${_dateAttrMandatoryfalseArray![0].toLocal()}"
                              .split(' ')[0] +
                          " to ${_dateAttrMandatoryfalseArray![1].toLocal()}"
                              .split(' ')[0]
                      : "Select date range",
                  style: TextStyle(
                    color: _dateAttrMandatoryfalseArray != null
                        ? Colors.black87
                        : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                bool isValid = true;

                if (_booelenattrMandatorytrueArray == null) {
                  setState(() {
                    _boolArrayError = "Boolean array is required";
                  });
                  isValid = false;
                }

                if (_doubleattrMandatorytrue == null) {
                  setState(() {
                    _doubleError = "Double value is required";
                  });
                  isValid = false;
                }

                if (_longattrMandatorytrue == null) {
                  setState(() {
                    _longError = "Long value is required";
                  });
                  isValid = false;
                }

                if (_timestampMandatorytrue == null) {
                  setState(() {
                    _timestampError = "Timestamp is required";
                  });
                  isValid = false;
                }

                if (_nameMandatorytrue == null || _nameMandatorytrue!.isEmpty) {
                  setState(() {
                    _nameError = "Name is required";
                  });
                  isValid = false;
                }

                if (!isValid) {
                  return;
                }

                event = Mandatoryevent(
                  booelenattrMandatorytrueArray:
                      _booelenattrMandatorytrueArray!,
                  doubleattrMandatorytrue: _doubleattrMandatorytrue!,
                  longattrMandatorytrue: _longattrMandatorytrue!,
                  timestampMandatorytrue: _timestampMandatorytrue!,
                  nameMandatorytrue: _nameMandatorytrue!,
                );

                if (_ageMandotoryfalse != null) {
                  event?.setAgeMandotoryfalse(_ageMandotoryfalse!);
                }
                if (_dateAttrMandatoryfalseArray != null) {
                  event?.setDateAttrMandatoryfalseArray(
                      _dateAttrMandatoryfalseArray!);
                }
                if (_surnameMandatoryfalseArray != null) {
                  event?.setSurnameMandatoryfalseArray(
                      _surnameMandatoryfalseArray!);
                }
    
                Netmera.sendEvent(event!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Event sent successfully")),
                );
              },
              child: const Text("Send Event"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label, {
    String? errorText,
    bool isRequired = false,
  }) {
    return InputDecoration(
      labelText: isRequired ? "$label (required)" : label,
      errorText: errorText,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF435e96)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF435e96)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF435e96), width: 2.0),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2.0),
      ),
      hintStyle: const TextStyle(color: Color(0xFF435e96)),
      labelStyle: const TextStyle(color: Color(0xFF435e96)),
    );
  }
}
