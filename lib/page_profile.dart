import 'package:flutter/material.dart';
import 'package:netmera_flutter_sdk/Netmera.dart';
import 'package:netmera_flutter_sdk/NetmeraProfileAttribute.dart';

import 'package:netmera_flutter_example/model/MyNetmeraUserProfile.dart';

///
/// Copyright (c) 2026 Netmera Research.
///

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController segments1Controller = TextEditingController();
  final TextEditingController segments2Controller = TextEditingController();

  int? dateOfBirthMillis;

  bool nameSet = false, nameUnset = false;
  bool surnameSet = false, surnameUnset = false;
  bool dateSet = false, dateUnset = false;
  bool genderSet = false, genderUnset = false;
  bool segments1Set = false, segments1Unset = false, segments1Add = false, segments1Remove = false;
  bool segments2Set = false, segments2Unset = false, segments2Add = false, segments2Remove = false;
  bool includeCustomAttributes = false;

  List<String> _toSegments(String text) {
    return text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  MyNetmeraUserProfile getUserProfile() {
    final profile = MyNetmeraUserProfile();

    if (nameSet && nameController.text.isNotEmpty) {
      profile.name.set(nameController.text);
    } else if (nameUnset) {
      profile.name.unset();
    }

    if (surnameSet && surnameController.text.isNotEmpty) {
      profile.surname.set(surnameController.text);
    } else if (surnameUnset) {
      profile.surname.unset();
    }

    if (dateSet && dateOfBirthMillis != null) {
      profile.dateOfBirth.set(dateOfBirthMillis!);
    } else if (dateUnset) {
      profile.dateOfBirth.unset();
    }

    final genderNum = int.tryParse(genderController.text);
    if (genderNum != null && genderNum >= 0 && genderNum < Gender.values.length && genderSet) {
      profile.gender.set(Gender.values[genderNum]);
    } else if (genderUnset) {
      profile.gender.unset();
    }

    final segs1 = _toSegments(segments1Controller.text);
    if (segments1Set && segs1.isNotEmpty) {
      profile.externalSegments.set(segs1);
    } else if (segments1Unset) {
      profile.externalSegments.unset();
    } else if (segments1Add && segs1.isNotEmpty) {
      profile.externalSegments.add(segs1);
    } else if (segments1Remove && segs1.isNotEmpty) {
      profile.externalSegments.remove(segs1);
    }

    final segs2 = _toSegments(segments2Controller.text);
    if (segments2Set && segs2.isNotEmpty) {
      profile.externalSegments.set(segs2);
    } else if (segments2Unset) {
      profile.externalSegments.unset();
    } else if (segments2Add && segs2.isNotEmpty) {
      profile.externalSegments.add(segs2);
    } else if (segments2Remove && segs2.isNotEmpty) {
      profile.externalSegments.remove(segs2);
    }

    if (includeCustomAttributes) {
      profile.luckyNumbers.set([1, 2, 3]);
      profile.isLuckyNumbersEnabled.set(true);
      profile.lastLoginPlatform.set('Flutter');
    }

    return profile;
  }

  void _updateProfileWithCallback() {
    Netmera.updateUserProfile(getUserProfile(),
        onSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User profile updated successfully!')));
          }
        },
        onFailure: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Update profile failed: $error')));
          }
        });
  }

  void _updateProfileAsync() {
    Netmera.updateUserProfile(getUserProfile());
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _checkboxRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _checkboxGroup(List<Widget> rows) {
    return Wrap(
      children: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Name'),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Name', border: OutlineInputBorder()),
          ),
          _checkboxGroup([
            _checkboxRow('SET', nameSet, (v) => setState(() { nameSet = v; if (v) nameUnset = false; })),
            _checkboxRow('UNSET', nameUnset, (v) => setState(() { nameUnset = v; if (v) nameSet = false; })),
          ]),

          _sectionLabel('Surname'),
          TextField(
            controller: surnameController,
            decoration: const InputDecoration(hintText: 'Surname', border: OutlineInputBorder()),
          ),
          _checkboxGroup([
            _checkboxRow('SET', surnameSet, (v) => setState(() { surnameSet = v; if (v) surnameUnset = false; })),
            _checkboxRow('UNSET', surnameUnset, (v) => setState(() { surnameUnset = v; if (v) surnameSet = false; })),
          ]),

          _sectionLabel('Date Of Birth'),
          Row(
            children: [
              Text(dateOfBirthMillis != null
                  ? DateTime.fromMillisecondsSinceEpoch(dateOfBirthMillis!).toString().split(' ')[0]
                  : 'No date'),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: dateOfBirthMillis != null
                        ? DateTime.fromMillisecondsSinceEpoch(dateOfBirthMillis!)
                        : DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => dateOfBirthMillis = date.millisecondsSinceEpoch);
                },
                child: const Text('SET DATE'),
              ),
            ],
          ),
          _checkboxGroup([
            _checkboxRow('SET', dateSet, (v) => setState(() { dateSet = v; if (v) dateUnset = false; })),
            _checkboxRow('UNSET', dateUnset, (v) => setState(() { dateUnset = v; if (v) dateSet = false; })),
          ]),

          _sectionLabel('MALE:0, FEMALE:1, NOT_SPECIFIED:2'),
          TextField(
            controller: genderController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Gender', border: OutlineInputBorder()),
          ),
          _checkboxGroup([
            _checkboxRow('SET', genderSet, (v) => setState(() { genderSet = v; if (v) genderUnset = false; })),
            _checkboxRow('UNSET', genderUnset, (v) => setState(() { genderUnset = v; if (v) genderSet = false; })),
          ]),

          _sectionLabel('Segments e.g. seg1,seg2'),
          TextField(
            controller: segments1Controller,
            decoration: const InputDecoration(hintText: 'Segments', border: OutlineInputBorder()),
          ),
          _checkboxGroup([
            _checkboxRow('SET', segments1Set, (v) => setState(() {
              segments1Set = v; if (v) { segments1Unset = false; segments1Add = false; segments1Remove = false; }
            })),
            _checkboxRow('UNSET', segments1Unset, (v) => setState(() {
              segments1Unset = v; if (v) { segments1Set = false; segments1Add = false; segments1Remove = false; }
            })),
            _checkboxRow('ADD', segments1Add, (v) => setState(() {
              segments1Add = v; if (v) { segments1Set = false; segments1Unset = false; segments1Remove = false; }
            })),
            _checkboxRow('REMOVE', segments1Remove, (v) => setState(() {
              segments1Remove = v; if (v) { segments1Set = false; segments1Unset = false; segments1Add = false; }
            })),
          ]),

          _sectionLabel('Segments e.g. seg1,seg2'),
          TextField(
            controller: segments2Controller,
            decoration: const InputDecoration(hintText: 'Segments', border: OutlineInputBorder()),
          ),
          _checkboxGroup([
            _checkboxRow('SET', segments2Set, (v) => setState(() {
              segments2Set = v; if (v) { segments2Unset = false; segments2Add = false; segments2Remove = false; }
            })),
            _checkboxRow('UNSET', segments2Unset, (v) => setState(() {
              segments2Unset = v; if (v) { segments2Set = false; segments2Add = false; segments2Remove = false; }
            })),
            _checkboxRow('ADD', segments2Add, (v) => setState(() {
              segments2Add = v; if (v) { segments2Set = false; segments2Unset = false; segments2Remove = false; }
            })),
            _checkboxRow('REMOVE', segments2Remove, (v) => setState(() {
              segments2Remove = v; if (v) { segments2Set = false; segments2Unset = false; segments2Add = false; }
            })),
          ]),

          _checkboxRow('Include Custom Attributes', includeCustomAttributes,
              (v) => setState(() => includeCustomAttributes = v)),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _updateProfileWithCallback,
              child: const Text('UPDATE PROFILE ATTRIBUTES'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _updateProfileAsync,
              child: const Text('UPDATE PROFILE ATTRIBUTES ASYNC'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
