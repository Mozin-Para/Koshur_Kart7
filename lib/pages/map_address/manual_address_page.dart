// lib/pages/map_address/manual_address_page.dart

import 'package:flutter/material.dart';
import 'address_model.dart';

class ManualAddressPage extends StatefulWidget {
  final Address? existing;

  const ManualAddressPage({super.key, this.existing});

  @override
  State<ManualAddressPage> createState() => _ManualAddressPageState();
}

class _ManualAddressPageState extends State<ManualAddressPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _lineC;
  late TextEditingController _cityC;
  late TextEditingController _districtC;
  late TextEditingController _stateC;
  late TextEditingController _countryC;
  late TextEditingController _pinC;

  bool _makeDefault = false;
  String _type      = 'Other';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _lineC     = TextEditingController(text: e?.line);
    _cityC     = TextEditingController(text: e?.city);
    _districtC = TextEditingController(text: e?.district);
    _stateC    = TextEditingController(text: e?.state);
    _countryC  = TextEditingController(text: e?.country);
    _pinC      = TextEditingController(text: e?.pinCode);

    _makeDefault = e?.isDefault ?? false;
    _type        = e?.type      ?? 'Other';
  }

  @override
  void dispose() {
    _lineC.dispose();
    _cityC.dispose();
    _districtC.dispose();
    _stateC.dispose();
    _countryC.dispose();
    _pinC.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // merge edits into existing or empty:
    final base = widget.existing ?? Address.empty();
    final edited = base.copyWith(
      line:      _lineC.text.trim(),
      village:   _cityC.text.trim(),
      city:      _cityC.text.trim(),
      district:  _districtC.text.trim(),
      state:     _stateC.text.trim(),
      country:   _countryC.text.trim(),
      pinCode:   _pinC.text.trim(),
      type:      _type,
      isDefault: _makeDefault,
    );

    Navigator.of(context).pop(edited);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (_, ctl) => SingleChildScrollView(
        controller: ctl,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16, right: 16, top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              widget.existing == null ? 'Add Address' : 'Edit Address',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Type dropdown
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: ['Home', 'Work', 'Other']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),

            // Address fields
            for (var field in {
              'Address Line': _lineC,
              'City': _cityC,
              'District': _districtC,
              'State': _stateC,
              'Country': _countryC,
              'Pin Code': _pinC,
            }.entries) ...[
              TextFormField(
                controller: field.value,
                decoration: InputDecoration(labelText: field.key),
                keyboardType: field.key == 'Pin Code'
                    ? TextInputType.number
                    : TextInputType.text,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter ${field.key.toLowerCase()}'
                    : null,
              ),
              const SizedBox(height: 8),
            ],

            SwitchListTile(
              title: const Text('Use as default address'),
              value: _makeDefault,
              onChanged: (v) => setState(() => _makeDefault = v),
            ),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('SAVE'),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
