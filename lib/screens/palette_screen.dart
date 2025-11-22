// lib/screens/palette_screen.dart // Reverted filename comment
import 'package:flutter/foundation.dart'
    show compute, kIsWeb; // Added compute back
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_profile_model.dart';
import '../utils/transitions_helper.dart'; // Keep if used

// --- Reverted Screen Name ---
class PaletteScreen extends StatefulWidget {
  const PaletteScreen({super.key});

  @override
  State<PaletteScreen> createState() => _PaletteScreenState(); // Reverted State Name
}

// --- Reverted State Name ---
class _PaletteScreenState extends State<PaletteScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false;
  String? _capturedImagePath;
  Uint8List? _capturedBytes;
  String? _analyzedUndertone;

  late final AnimationController _resultAnimController;
  late final Animation<double> _resultAnim;
  late final AnimationController _buttonPulseController;
  late final Animation<double> _buttonPulseAnim;

  // Theme Color
  final Color themeColor = const Color(0xFF8B7355);
  final Color lightBackgroundColor = const Color(
    0xFFF8F5F2,
  ); // Consistent light background

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _resultAnim = CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.easeOut,
    );

    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _buttonPulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _buttonPulseController, curve: Curves.easeInOut),
    );
  }

  // --- Camera Initialization ---
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError('No cameras found.');
        return;
      }
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e, st) {
      debugPrint('Camera init error: $e\n$st');
      if (mounted) _showError('Could not initialize camera: $e');
    }
  }

  // --- Capture & Analyze ---
  Future<void> _captureAndAnalyze() async {
    if (!_isCameraInitialized ||
        _cameraController == null ||
        _cameraController!.value.isTakingPicture) {
      _showError('Camera not ready or busy.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analyzedUndertone = null;
      _capturedImagePath = null;
      _capturedBytes = null;
    });

    try {
      final XFile picture = await _cameraController!.takePicture();
      final Uint8List bytes = await picture.readAsBytes();

      setState(() {
        _capturedImagePath = picture.path;
        _capturedBytes = bytes;
      });

      // Use compute for analysis in separate isolate
      final undertone = await compute(_analyzeSkinTone, bytes);

      if (!mounted) return;

      setState(() {
        _analyzedUndertone = undertone;
        _isAnalyzing = false;
      });

      Provider.of<UserProfileModel>(
        context,
        listen: false,
      ).updateSkinTone(undertone);
      _resultAnimController.forward(from: 0);
      _showResultDialog(undertone);
    } catch (e, st) {
      debugPrint('Capture/analyze error: $e\n$st');
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _showError('Error during capture/analysis: $e');
      }
    }
  }

  // --- Analysis Logic (Static for compute) ---
  static Future<String> _analyzeSkinTone(Uint8List bytes) async {
    try {
      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) return 'Neutral';

      final int cropSize = (math.min(decoded.width, decoded.height) * 0.4)
          .toInt();
      final int xStart = (decoded.width ~/ 2 - cropSize ~/ 2).clamp(
        0,
        decoded.width - 1,
      );
      final int yStart = (decoded.height ~/ 2 - cropSize ~/ 2).clamp(
        0,
        decoded.height - 1,
      );
      final int actualCropWidth = math.min(cropSize, decoded.width - xStart);
      final int actualCropHeight = math.min(cropSize, decoded.height - yStart);

      final List<List<double>> hsvSamples = [];

      for (int y = yStart; y < yStart + actualCropHeight; y++) {
        for (int x = xStart; x < xStart + actualCropWidth; x++) {
          final dynamic p = decoded.getPixel(x, y);
          int r, g, b;
          if (p is int) {
            final rgb = _extractRgbFromIntStatic(p);
            r = rgb[0];
            g = rgb[1];
            b = rgb[2];
          } else if (p is img.Pixel) {
            r = p.r.toInt();
            g = p.g.toInt();
            b = p.b.toInt();
          } else {
            continue;
          }

          final hsv = _rgbToHsvStatic(r, g, b);
          hsvSamples.add(hsv);
        }
      }

      if (hsvSamples.isEmpty) return 'Neutral';

      double avgH = 0, avgS = 0, avgV = 0;
      for (final hv in hsvSamples) {
        avgH += hv[0];
        avgS += hv[1];
        avgV += hv[2];
      }
      avgH /= hsvSamples.length;
      avgS /= hsvSamples.length;
      avgV /= hsvSamples.length;

      final undertone = _determineUndertoneStatic(avgH, avgS, avgV);

      return undertone;
    } catch (e, st) {
      debugPrint('Static Analysis error: $e\n$st');
      return 'Neutral';
    }
  }

  // --- Static Helper Functions ---
  static List<int> _extractRgbFromIntStatic(int pixel) {
    /* ... same logic ... */
    final int rA = (pixel >> 16) & 0xFF;
    final int gA = (pixel >> 8) & 0xFF;
    final int bA = pixel & 0xFF;
    final int rB = pixel & 0xFF;
    final int gB = (pixel >> 8) & 0xFF;
    final int bB = (pixel >> 16) & 0xFF;
    final sA = _rgbToHsvStatic(rA, gA, bA)[1];
    final sB = _rgbToHsvStatic(rB, gB, bB)[1];
    return sA >= sB ? [rA, gA, bA] : [rB, gB, bB];
  }

  static List<double> _rgbToHsvStatic(int r, int g, int b) {
    /* ... same logic ... */
    final double rf = r / 255.0;
    final double gf = g / 255.0;
    final double bf = b / 255.0;
    final double maxVal = math.max(rf, math.max(gf, bf));
    final double minVal = math.min(rf, math.min(gf, bf));
    final double delta = maxVal - minVal;
    double h = 0.0;
    if (delta != 0) {
      if (maxVal == rf) {
        h = 60 * (((gf - bf) / delta) % 6);
      } else if (maxVal == gf) {
        h = 60 * (((bf - rf) / delta) + 2);
      } else {
        h = 60 * (((rf - gf) / delta) + 4);
      }
    }
    if (h < 0) h += 360;
    final double s = maxVal == 0 ? 0 : delta / maxVal;
    final double v = maxVal;
    return [h, s, v];
  }

  static String _determineUndertoneStatic(double h, double s, double v) {
    /* ... same logic ... */
    if (s < 0.1 || v < 0.2 || v > 0.95) return 'Neutral';
    if ((h >= 30 && h <= 65) || (h >= 0 && h <= 20)) {
      return 'Warm';
    } else if (h >= 190 && h <= 300) {
      return 'Cool';
    }
    return 'Neutral';
  }

  // --- Styled Result Dialog ---
  void _showResultDialog(String undertone) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _resultAnimController,
          curve: Curves.elasticOut,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
          actionsPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          title: Row(
            children: [
              TweenAnimationBuilder<double>(
                /* ... same icon animation ... */
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      undertone == 'Warm'
                          ? Icons.wb_sunny_outlined
                          : (undertone == 'Cool'
                                ? Icons.ac_unit_outlined
                                : Icons.balance_outlined),
                      color: _undertoneColor(undertone),
                      size: 30,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Undertone Detected!',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                undertone,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _undertoneColor(undertone),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Analysis based on the central region of the image.',
                style: GoogleFonts.inter(
                  height: 1.4,
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: themeColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Text(
                'Got It!',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _resultAnimController.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  // --- Undertone Color Helper ---
  Color _undertoneColor(String? u) {
    switch (u) {
      case 'Warm':
        return const Color(0xFFF59E0B);
      case 'Cool':
        return const Color(0xFF3B82F6);
      case 'Neutral':
        return const Color(0xFF10B981);
      default:
        return Colors.grey.shade600;
    }
  }

  // --- Styled Error SnackBar ---
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  // --- Build Method with Themed UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Skin Tone Analysis',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Instruction Card ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: themeColor,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Your Undertone',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Center your face in the square below using good, natural lighting.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // --- Camera Preview ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _isCameraInitialized &&
                                  _cameraController != null &&
                                  _cameraController!.value.isInitialized
                              ? CameraPreview(_cameraController!)
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: themeColor,
                                    ),
                                  ),
                                ),
                          IgnorePointer(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: themeColor.withOpacity(0.8),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          if (_isAnalyzing)
                            Container(
                              color: Colors.black.withOpacity(0.4),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Capture Button ---
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
              child: ScaleTransition(
                scale: _isAnalyzing
                    ? const AlwaysStoppedAnimation(1.0)
                    : _buttonPulseAnim,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: _isAnalyzing ? 2 : 6,
                  ),
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.camera_alt_outlined, size: 22),
                  label: Text(
                    _isAnalyzing ? 'Analyzing...' : 'Capture & Analyze',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: (!_isCameraInitialized || _isAnalyzing)
                      ? null
                      : _captureAndAnalyze,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- AnimatedPulsingBorder (Keep if using, otherwise remove) ---
// class AnimatedPulsingBorder extends StatefulWidget { /* ... */ }
// class _AnimatedPulsingBorderState extends State<AnimatedPulsingBorder> with SingleTickerProviderStateMixin { /* ... */ }
