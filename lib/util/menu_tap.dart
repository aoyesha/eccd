import 'package:flutter/material.dart';

class MenuTap extends StatelessWidget {
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;

  const MenuTap({
    super.key,
    required this.onActivate,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'activate', child: Text('Activate')),
        PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
      ],
      onSelected: (value) {
        if (value == 'activate') onActivate();
        if (value == 'deactivate') onDeactivate();
      },
    );
  }
}
