import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thechain_shared/theme/dark_mystique_theme.dart';
import 'package:thechain_shared/widgets/mystique_components.dart';
import 'package:thechain_shared/api/api_client.dart';

/// Screen for scanning QR codes to join The Chain
/// Uses mobile_scanner package for camera-based scanning
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _scannerController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isProcessing = false;
  bool _hasScanned = false;
  String? _errorMessage;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
      _errorMessage = null;
    });

    try {
      // Parse the QR code data - expected format: ticketId:signature
      final parts = rawValue.split(':');
      if (parts.length < 2) {
        throw Exception('Invalid QR code format');
      }

      final ticketId = parts[0];
      final signature = parts.sublist(1).join(':'); // Handle colons in signature

      // Call backend to validate ticket
      final apiClient = ApiClient();
      final scanResult = await apiClient.scanTicket(ticketId, signature);

      if (!mounted) return;

      // Navigate to scan result screen
      Navigator.pushReplacementNamed(
        context,
        '/scan-result',
        arguments: scanResult,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _toggleTorch() {
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
    _scannerController.toggleTorch();
  }

  void _resetScanner() {
    setState(() {
      _hasScanned = false;
      _isProcessing = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkMystiqueTheme.deepVoid,
      appBar: AppBar(
        backgroundColor: DarkMystiqueTheme.shadowPurple.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DarkMystiqueTheme.etherealPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Invitation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: DarkMystiqueTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: _torchEnabled
                  ? DarkMystiqueTheme.warningAura
                  : DarkMystiqueTheme.textSecondary,
            ),
            onPressed: _toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Overlay with scanning frame
          _buildScannerOverlay(),

          // Bottom info panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: DarkMystiqueTheme.deepVoid.withOpacity(0.8),
              child: const Center(
                child: MystiqueLoadingIndicator(
                  message: 'Validating invitation...',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final left = (constraints.maxWidth - scanAreaSize) / 2;
        final top = (constraints.maxHeight - scanAreaSize) / 2 - 60;

        return Stack(
          children: [
            // Semi-transparent background with cutout
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                DarkMystiqueTheme.deepVoid.withOpacity(0.7),
                BlendMode.srcOut,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Animated scan frame
            Positioned(
              left: left,
              top: top,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: scanAreaSize,
                    height: scanAreaSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: DarkMystiqueTheme.ghostCyan.withOpacity(_pulseAnimation.value),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DarkMystiqueTheme.ghostCyan.withOpacity(0.3 * _pulseAnimation.value),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Corner decorations
                        _buildCorner(Alignment.topLeft),
                        _buildCorner(Alignment.topRight),
                        _buildCorner(Alignment.bottomLeft),
                        _buildCorner(Alignment.bottomRight),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Instruction text above scan area
            Positioned(
              left: 0,
              right: 0,
              top: top - 60,
              child: Text(
                'Position the QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DarkMystiqueTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner(Alignment alignment) {
    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? BorderSide(color: DarkMystiqueTheme.etherealPurple, width: 4)
                : BorderSide.none,
            bottom: !isTop
                ? BorderSide(color: DarkMystiqueTheme.etherealPurple, width: 4)
                : BorderSide.none,
            left: isLeft
                ? BorderSide(color: DarkMystiqueTheme.etherealPurple, width: 4)
                : BorderSide.none,
            right: !isLeft
                ? BorderSide(color: DarkMystiqueTheme.etherealPurple, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            DarkMystiqueTheme.deepVoid.withOpacity(0.9),
            DarkMystiqueTheme.deepVoid,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DarkMystiqueTheme.errorPulse.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DarkMystiqueTheme.errorPulse.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: DarkMystiqueTheme.errorPulse,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: DarkMystiqueTheme.errorPulse,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              MystiqueButton(
                text: 'Try Again',
                icon: Icons.refresh,
                onPressed: _resetScanner,
                variant: MystiqueButtonVariant.secondary,
              ),
              const SizedBox(height: 16),
            ],

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DarkMystiqueTheme.shadowPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DarkMystiqueTheme.mysticViolet.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.qr_code,
                      color: DarkMystiqueTheme.etherealPurple,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan Invitation QR Code',
                          style: TextStyle(
                            color: DarkMystiqueTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ask a member to show their invitation QR code',
                          style: TextStyle(
                            color: DarkMystiqueTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Manual entry option
            TextButton(
              onPressed: () => _showManualEntryDialog(),
              child: Text(
                'Enter code manually',
                style: TextStyle(
                  color: DarkMystiqueTheme.ghostCyan,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    final ticketController = TextEditingController();
    final signatureController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DarkMystiqueTheme.shadowPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Enter Invitation Code',
          style: TextStyle(color: DarkMystiqueTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ticketController,
              style: TextStyle(color: DarkMystiqueTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Ticket ID',
                labelStyle: TextStyle(color: DarkMystiqueTheme.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: DarkMystiqueTheme.mysticViolet.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: DarkMystiqueTheme.etherealPurple),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: signatureController,
              style: TextStyle(color: DarkMystiqueTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Signature',
                labelStyle: TextStyle(color: DarkMystiqueTheme.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: DarkMystiqueTheme.mysticViolet.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: DarkMystiqueTheme.etherealPurple),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: DarkMystiqueTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processManualEntry(ticketController.text, signatureController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DarkMystiqueTheme.mysticViolet,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _processManualEntry(String ticketId, String signature) async {
    if (ticketId.isEmpty || signature.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both ticket ID and signature';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ApiClient();
      final scanResult = await apiClient.scanTicket(ticketId, signature);

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/scan-result',
        arguments: scanResult,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to validate invitation';
      });
    }
  }
}
