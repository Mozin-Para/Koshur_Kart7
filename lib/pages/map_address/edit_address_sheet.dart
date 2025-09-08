import 'package:flutter/material.dart';
import 'address_model.dart';
import 'map_picker_bottom_sheet.dart';
import 'search_address_page.dart';

class EditAddressSheet extends StatefulWidget {
  final Address initial;
  const EditAddressSheet({super.key, required this.initial});

  @override
  State<EditAddressSheet> createState() => _EditAddressSheetState();
}

class _EditAddressSheetState extends State<EditAddressSheet> {
  late final TextEditingController _landmarkC;
  late final TextEditingController _villageC;
  late final TextEditingController _cityC;
  late final TextEditingController _districtC;
  late final TextEditingController _stateC;
  late final TextEditingController _countryC;
  late final TextEditingController _pinC;
  late final TextEditingController _locUrlC;
  String _type        = 'Other';
  bool _makeDefault   = false;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _landmarkC  = TextEditingController(text: a.landmark);
    _villageC   = TextEditingController(text: a.village);
    _cityC      = TextEditingController(text: a.city);
    _districtC  = TextEditingController(text: a.district);
    _stateC     = TextEditingController(text: a.state);
    _countryC   = TextEditingController(text: a.country);
    _pinC       = TextEditingController(text: a.pinCode);
    _locUrlC    = TextEditingController(text: a.locationUrl);
    _type       = a.type;
    _makeDefault= a.isDefault;
  }

  @override
  void dispose() {
    _landmarkC.dispose();
    _villageC.dispose();
    _cityC.dispose();
    _districtC.dispose();
    _stateC.dispose();
    _countryC.dispose();
    _pinC.dispose();
    _locUrlC.dispose();
    super.dispose();
  }

  void _save() {
    final edited = widget.initial.copyWith(
      landmark:    _landmarkC.text.trim(),
      village:     _villageC.text.trim(),
      city:        _cityC.text.trim(),
      district:    _districtC.text.trim(),
      state:       _stateC.text.trim(),
      country:     _countryC.text.trim(),
      pinCode:     _pinC.text.trim(),
      locationUrl: _locUrlC.text.trim(),
      type:        _type,
      isDefault:   _makeDefault,
    );
    Navigator.of(context).pop(edited);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (_, ctrl) => SingleChildScrollView(
        controller: ctrl,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16, right: 16, top: 16,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            widget.initial.line.isEmpty ? 'Add Address' : 'Edit Address',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: ['Home', 'Work', 'Other']
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 12),

          for (var pair in {
            'Landmark': _landmarkC,
            'Village': _villageC,
            'City': _cityC,
            'District': _districtC,
            'State': _stateC,
            'Country': _countryC,
            'Pin Code': _pinC
          }.entries) ...[
            TextField(
              controller: pair.value,
              decoration: InputDecoration(labelText: pair.key),
              keyboardType:
              pair.key == 'Pin Code' ? TextInputType.number : null,
            ),
            const SizedBox(height: 8),
          ],

          TextField(
            controller: _locUrlC,
            decoration:
            const InputDecoration(labelText: 'Location URL'),
            readOnly: true,
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final picked = await Navigator.of(context).push<Address>(
                    MaterialPageRoute(
                      builder: (_) => const MapPickerBottomSheet(),
                    ),
                  );
                  if (picked != null) {
                    setState(
                            () => _locUrlC.text = picked.locationUrl);
                  }
                },
                icon: const Icon(Icons.map),
                label: const Text('Pick from Map'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final picked = await Navigator.of(context)
                      .push<Address>(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => const SearchAddressPage(),
                    ),
                  );
                  if (picked != null) {
                    setState(
                            () => _locUrlC.text = picked.locationUrl);
                  }
                },
                icon: const Icon(Icons.search),
                label: const Text('Search Address'),
              ),
            ),
          ]),

          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Use as default'),
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
    );
  }
}