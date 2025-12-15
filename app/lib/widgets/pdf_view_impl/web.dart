import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildPDFView({
  required String path,
  required String url,
  required Function(int?, int?) onPageChanged,
  required Function(int?) onRender,
  required Function(dynamic) onError,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
        const SizedBox(height: 24),
        const Text(
          'Abrir documento en nueva pestaña',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => launchUrl(Uri.parse(url)),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Ver PDF'),
        ),
      ],
    ),
  );
}
