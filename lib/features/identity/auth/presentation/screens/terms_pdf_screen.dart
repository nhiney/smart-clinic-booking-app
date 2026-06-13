import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsPdfScreen extends StatefulWidget {
  final String pdfUrl;

  const TermsPdfScreen({
    super.key,
    this.pdfUrl = 'https://pub-bc3669a9821248918f203546714adf67.r2.dev/consent/PRIVACY_POLICY.pdf',
  });

  @override
  State<TermsPdfScreen> createState() => _TermsPdfScreenState();
}

class _TermsPdfScreenState extends State<TermsPdfScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    if (kIsWeb) {
      setState(() {
        _isLoading = false;
        _localPath = null; // We'll use network directly on web
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/terms_of_use.pdf';
      final file = File(filePath);

      // To ensure freshness, we download every time for now, or check for existence
      // if (await file.exists()) {
      //   setState(() {
      //     _localPath = filePath;
      //     _isLoading = false;
      //   });
      //   return;
      // }

      final response = await Dio().download(
        widget.pdfUrl,
        filePath,
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('Download progress: $progress%');
          }
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _localPath = filePath;
          _isLoading = false;
        });
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: BrandedAppBar(
        title: l10n.terms_and_conditions,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Mở bằng trình duyệt',
            onPressed: () async {
              final uri = Uri.parse(widget.pdfUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Đang tải tài liệu...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_error != null && _localPath == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Không thể tải tài liệu trực tiếp.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng thử lại hoặc mở bằng trình duyệt.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _downloadFile,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Displaying the PDF
    if (kIsWeb) {
      // On Web, use network directly (CORS is the main issue here)
      return SfPdfViewer.network(
        widget.pdfUrl,
        onDocumentLoadFailed: (details) {
          _showErrorSnackBar(details.description);
        },
      );
    } else {
      // On Mobile, use the downloaded file
      return SfPdfViewer.file(
        File(_localPath!),
        onDocumentLoadFailed: (details) {
          _showErrorSnackBar(details.description);
        },
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi: $message'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Mở trình duyệt',
          textColor: Colors.white,
          onPressed: () async {
            final uri = Uri.parse(widget.pdfUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ),
    );
  }
}
