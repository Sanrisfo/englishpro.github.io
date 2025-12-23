import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RichTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final InputDecoration? decoration;

  const RichTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.decoration,
  });

  void _addBold() {
    final text = controller.text;
    final selection = controller.selection;
    if (!selection.isValid) return;

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '**${selection.textInside(text)}**',
    );
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.end + 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si pasaron decoration, úsala, si no, construye una básica
    final inputDecoration = decoration ?? InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toolbar (Solo visible si tiene foco o siempre visible para simplicidad)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.format_bold, size: 20),
              tooltip: 'Negrita (Ctrl+B)',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              onPressed: _addBold,
            ),
          ],
        ),
        CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyB, control: true): _addBold,
          },
          child: TextField(
            controller: controller,
            decoration: inputDecoration,
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }
}
