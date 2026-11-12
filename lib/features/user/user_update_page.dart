import 'package:flutter/material.dart';
import 'package:netmera_flutter_example/model/MyNetmeraUserProfile.dart';
import 'package:netmera_flutter_example/ui/app_theme.dart';
import 'package:netmera_flutter_example/ui/feedback.dart';
import 'package:netmera_flutter_example/ui/widgets/list_rows.dart';
import 'package:netmera_flutter_example/ui/widgets/operation_selector.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraProfileAttribute.dart';

const _single = [ProfileOperation.set, ProfileOperation.unset];
const _collection = ProfileOperation.values;

class _Field {
  _Field(this.id, this.title, this.operations, {this.hint});

  final String id;
  final String title;
  final List<ProfileOperation> operations;
  final String? hint;
  final controller = TextEditingController();
  ProfileOperation? operation = ProfileOperation.set;

  String get value => controller.text.trim();
}

/// Set uses the parsed value (skipped when it is null); Unset ignores it.
void _applySingle<T>(
  NetmeraProfileAttribute<T> attribute,
  _Field field,
  T? Function(String value) parse,
) {
  switch (field.operation) {
    case ProfileOperation.set:
      final value = parse(field.value);
      if (value != null) attribute.set(value);
    case ProfileOperation.unset:
      attribute.unset();
    default:
      break;
  }
}

void _applyCollection(
  NetmeraProfileAttributeCollection<String> attribute,
  _Field field,
) {
  final parts = field.value
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  switch (field.operation) {
    case ProfileOperation.unset:
      attribute.unset();
    case ProfileOperation.set when parts.isNotEmpty:
      attribute.set(parts);
    case ProfileOperation.add when parts.isNotEmpty:
      attribute.add(parts);
    case ProfileOperation.remove when parts.isNotEmpty:
      attribute.remove(parts);
    default:
      break;
  }
}

String? _nonEmpty(String value) => value.isEmpty ? null : value;

Gender? _parseGender(String value) {
  final index = int.tryParse(value);
  if (index == null || index < 0 || index >= Gender.values.length) return null;
  return Gender.values[index];
}

class UserUpdatePage extends StatefulWidget {
  const UserUpdatePage({super.key});

  @override
  State<UserUpdatePage> createState() => _UserUpdatePageState();
}

class _UserUpdatePageState extends State<UserUpdatePage> {
  final _name = _Field('name', 'Name', _single);
  final _surname = _Field('surname', 'Surname', _single);
  final _segments1 = _Field(
    'externalSegments1',
    'External Segments',
    _collection,
    hint: 'seg1,seg2',
  );
  final _segments2 = _Field(
    'externalSegments2',
    'External Segments',
    _collection,
    hint: 'seg1,seg2',
  );
  final _dateOfBirth = _Field(
    'dateOfBirth',
    'Date of Birth (yyyy-MM-dd)',
    _single,
  );
  final _gender = _Field(
    'gender',
    'Gender (MALE:0, FEMALE:1, NOT_SPECIFIED:2)',
    _single,
  );

  late final _fields = [
    _name,
    _surname,
    _segments1,
    _segments2,
    _dateOfBirth,
    _gender,
  ];

  bool _includeCustomAttributes = false;

  @override
  void dispose() {
    for (final field in _fields) {
      field.controller.dispose();
    }
    super.dispose();
  }

  MyNetmeraUserProfile _buildProfile() {
    final profile = MyNetmeraUserProfile();
    _applySingle(profile.name, _name, _nonEmpty);
    _applySingle(profile.surname, _surname, _nonEmpty);
    _applyCollection(profile.externalSegments, _segments1);
    _applyCollection(profile.externalSegments, _segments2);
    _applySingle(
      profile.dateOfBirth,
      _dateOfBirth,
      (value) => DateTime.tryParse(value)?.millisecondsSinceEpoch,
    );
    _applySingle(profile.gender, _gender, _parseGender);
    if (_includeCustomAttributes) {
      profile.luckyNumbers.set([1, 2, 3]);
      profile.isLuckyNumbersEnabled.set(true);
      profile.lastLoginPlatform.set('Flutter');
    }
    return profile;
  }

  void _update() => Netmera.updateUserProfile(_buildProfile());

  void _updateWithCallback() {
    Netmera.updateUserProfile(
      _buildProfile(),
      onSuccess: () => showFeedback(
        'User profile has been updated successfully!',
        style: FeedbackStyle.success,
      ),
      onFailure: (error) => showFeedback(
        'Failed to update user profile: $error',
        style: FeedbackStyle.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        for (final field in _fields)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(field.title, style: AppTextStyles.rowTitle),
                const SizedBox(height: 8),
                OperationSelector(
                  key: ValueKey('userProfile.${field.id}.operation'),
                  options: field.operations,
                  selected: field.operation,
                  onChanged: (operation) =>
                      setState(() => field.operation = operation),
                ),
                const SizedBox(height: 8),
                TextField(
                  key: ValueKey('userProfile.${field.id}.value'),
                  controller: field.controller,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: field.hint ?? 'Value...',
                  ),
                ),
              ],
            ),
          ),
        SwitchRow(
          key: const ValueKey('userProfile.customAttributes'),
          title: 'Include Custom Attributes',
          subtitle: 'luckyNumbers, isLuckyNumbersEnabled, lastLoginPlatform',
          value: _includeCustomAttributes,
          onChanged: (value) =>
              setState(() => _includeCustomAttributes = value),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                key: const ValueKey('userProfile.submit'),
                onPressed: _update,
                child: const Text('Update User'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                key: const ValueKey('userProfile.submitWithCallback'),
                style: AppButtonStyles.callback,
                onPressed: _updateWithCallback,
                child: const Text('Update User With Callback'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
