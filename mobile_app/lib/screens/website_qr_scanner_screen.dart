
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/api_config.dart';
import '../services/api_service.dart';

class WebsiteQrScannerScreen extends StatefulWidget {
  const WebsiteQrScannerScreen({super.key});

  @override
  State<WebsiteQrScannerScreen> createState() =>
      _WebsiteQrScannerScreenState();
}

class _WebsiteQrScannerScreenState
    extends State<WebsiteQrScannerScreen> {
  String? _scannedCode;
  String _message = 'Scan the QR code displayed on the website.';
  String _ownerName = '';
  List<dynamic> _workshops = [];

  bool _processing = false;
  bool _approved = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || _scannedCode != null) return;

    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .firstWhere(
          (value) => value != null && value.trim().isNotEmpty,
          orElse: () => null,
        );

    if (code == null) return;

    setState(() {
      _processing = true;
      _message = 'Checking QR code...';
    });

    try {
      final result = await ApiService.post(
        '${ApiConfig.baseUrl}auth/website-pairing/scan/',
        {'code': code},
      );

      if (!mounted) return;

      setState(() {
        _scannedCode = code;
        _ownerName = result['workshop_owner']?.toString() ?? '';
        _workshops = result['workshops'] is List
            ? result['workshops'] as List
            : [];
        _message = 'Website login request received.';
        _processing = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _message = error.toString().replaceFirst('Exception: ', '');
        _processing = false;
      });
    }
  }

  Future<void> _respondToRequest(bool approved) async {
    final code = _scannedCode;

    if (code == null || _processing) return;

    setState(() {
      _processing = true;
      _message = approved
          ? 'Approving website login...'
          : 'Rejecting website login...';
    });

    try {
      await ApiService.post(
        '${ApiConfig.baseUrl}auth/website-pairing/approve/',
        {
          'code': code,
          'approved': approved,
        },
      );

      if (!mounted) return;

      setState(() {
        _approved = approved;
        _processing = false;
        _message = approved
            ? 'Website login approved successfully.'
            : 'Website login rejected.';
      });

      if (approved) {
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) Navigator.pop(context, true);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _processing = false;
        _message = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _scanAgain() {
    setState(() {
      _scannedCode = null;
      _ownerName = '';
      _workshops = [];
      _approved = false;
      _processing = false;
      _message = 'Scan the QR code displayed on the website.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Website QR Login'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 55,
                color: Color(0xFF1565C0),
              ),
              const SizedBox(height: 12),
              const Text(
                'Connect to Website',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              if (_scannedCode == null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 320,
                    child: MobileScanner(
                      onDetect: _onDetect,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Position the website QR code inside the camera frame.',
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.desktop_windows,
                          size: 45,
                          color: Color(0xFF1565C0),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Website Login Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Workshop Owner: $_ownerName'),
                        const SizedBox(height: 8),
                        if (_workshops.isNotEmpty)
                          ..._workshops.map(
                            (name) => Text(name.toString()),
                          ),
                        const SizedBox(height: 16),
                        const Text(
                          'Do you approve signing in to the Smart Auto Care website using your account?',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (!_approved) ...[
                  ElevatedButton.icon(
                    onPressed: _processing
                        ? null
                        : () => _respondToRequest(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve Website Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _processing
                        ? null
                        : () => _respondToRequest(false),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject Request'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 45,
                  ),
                  const Text(
                    'Approved',
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _processing ? null : _scanAgain,
                  child: const Text('Scan Another QR Code'),
                ),
              ],

              if (_processing) ...[
                const SizedBox(height: 18),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
