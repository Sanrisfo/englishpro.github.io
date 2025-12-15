import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'pdf_view_impl/stub.dart'
    if (dart.library.io) 'pdf_view_impl/mobile.dart'
    if (dart.library.html) 'pdf_view_impl/web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

/// Un widget de pantalla completa para visualizar archivos PDF.
///
/// Este widget es `Stateful` porque necesita gestionar el estado de la carga
/// del archivo PDF, ya sea desde una URL remota o una ruta local.
///
/// Si la [pdfUrl] proporcionada comienza con `http`, el widget primero
/// descargará el archivo a un directorio temporal y luego lo mostrará.
/// Si es una ruta de archivo local, lo cargará directamente.
///
/// Maneja estados de carga, errores de descarga y la paginación del documento.
///
/// ### Ejemplo de uso:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => const PDFViewerWidget(
///       pdfUrl: 'https://ejemplo.com/documento.pdf',
///       title: 'Guía de Estudio',
///     ),
///   ),
/// );
/// ```
class PDFViewerWidget extends StatefulWidget {
  /// La URL del PDF. Puede ser una URL remota (http/https) o una ruta local.
  final String pdfUrl;

  /// El título que se mostrará en la `AppBar` de la pantalla del visor.
  final String title;

  /// Crea una instancia del visor de PDF.
  const PDFViewerWidget({
    Key? key,
    required this.pdfUrl,
    this.title = 'Documento PDF',
  }) : super(key: key);

  @override
  State<PDFViewerWidget> createState() => _PDFViewerWidgetState();
}

class _PDFViewerWidgetState extends State<PDFViewerWidget> {
  /// La ruta local del archivo PDF después de ser descargado (si es remoto).
  String? _localPath;

  /// Indica si el PDF se está cargando.
  bool _isLoading = true;

  /// Almacena un mensaje de error si la carga falla.
  String? _error;

  /// La página actual que se está visualizando.
  int _currentPage = 0;

  /// El número total de páginas del documento.
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  /// Inicia el proceso de carga del PDF.
  ///
  /// Determina si la URL es remota o local y procede con la
  /// descarga o la asignación directa de la ruta.
  Future<void> _loadPDF() async {
    if (kIsWeb) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      // Si es un recurso local/asset, se usa la ruta directamente.
      if (!widget.pdfUrl.startsWith('http')) {
        setState(() {
          _localPath = widget.pdfUrl;
          _isLoading = false;
        });
        return;
      }

      // Descarga el PDF desde la red.
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          setState(() {
            _localPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Error al descargar PDF: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Página ${_currentPage + 1} de $_totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Construye el cuerpo de la pantalla según el estado actual (cargando, error o éxito).
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando PDF...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar PDF',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadPDF();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return buildPDFView(
      path: _localPath ?? '',
      url: widget.pdfUrl,
      onRender: (pages) {
        if (mounted) {
          setState(() {
            _totalPages = pages ?? 0;
          });
        }
      },
      onPageChanged: (page, total) {
        if (mounted) {
          setState(() {
            _currentPage = page ?? 0;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = error.toString();
          });
        }
      },
    );
  }
}

/// Un botón pre-configurado que abre el visor de PDF [PDFViewerWidget] en
/// una nueva pantalla.
///
/// Simplifica la acción de mostrar un PDF al usuario, encapsulando la
/// lógica de navegación.
class PDFViewerButton extends StatelessWidget {
  /// La URL del PDF a visualizar.
  final String pdfUrl;

  /// El título para la `AppBar` del visor.
  final String title;

  /// El texto que se mostrará en el botón.
  final String buttonText;

  /// Crea una instancia del botón visor de PDF.
  const PDFViewerButton({
    Key? key,
    required this.pdfUrl,
    this.title = 'Documento PDF',
    this.buttonText = 'Ver PDF',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerWidget(
              pdfUrl: pdfUrl,
              title: title,
            ),
          ),
        );
      },
      icon: const Icon(Icons.picture_as_pdf),
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
