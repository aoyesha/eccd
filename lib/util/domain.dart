import 'package:flutter/material.dart';

class DomainDropdown extends StatefulWidget {
  final List<String> domains;
  final ValueChanged<String?> onChanged;

  const DomainDropdown({
    super.key,
    required this.domains,
    required this.onChanged,
});
  @override
  State<DomainDropdown> createState() => _DomainDropdownState();
}

class _DomainDropdownState extends State<DomainDropdown> {
  String? selectedDomain;

  final List<String> domain = [
    'All',
    'Gross Motor',
    'Fine Motor',
    'Self Help',
    'Dressing',
    'Toilet',
    'Receptive Language',
    'Expressive Language',
    'Cognitive',
    'Social Emotional'
  ];
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedDomain,
      hint: const Text('Select Domain'),
      items: widget.domains.map((d) {
        return DropdownMenuItem<String>(
          value: d,
          child: Text(d),
        );
      }).toList(),
      onChanged: (val){
        setState(() {
          selectedDomain = val;
        });
        widget.onChanged(val);
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }
}