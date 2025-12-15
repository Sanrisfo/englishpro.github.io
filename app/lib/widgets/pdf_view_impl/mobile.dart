import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

Widget buildPDFView({
  required String path,
  required String url,
  required Function(int?, int?) onPageChanged,
  required Function(int?) onRender,
  required Function(dynamic) onError,
}) {
  return PDFView(
    filePath: path,
    autoSpacing: true,
    enableSwipe: true,
    pageSnap: true,
    swipeHorizontal: false,
    nightMode: false,
    onRender: onRender,
    onPageChanged: (page, total) => onPageChanged(page, total ?? 0),
    onError: onError,
    onPageError: (page, error) => onError('Page $page: $error'),
  );
}
