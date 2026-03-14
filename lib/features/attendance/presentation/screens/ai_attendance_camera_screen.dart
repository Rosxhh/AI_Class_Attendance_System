import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../../core/theme/app_colors.dart';

class AIAttendanceCameraScreen extends StatefulWidget {
  const AIAttendanceCameraScreen({super.key});

  @override
  State<AIAttendanceCameraScreen> createState() => _AIAttendanceCameraScreenState();
}

class _AIAttendanceCameraScreenState extends State<AIAttendanceCameraScreen> {
  CameraController? _cameraController;
  bool _isBusy = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController?.initialize();
    if (!mounted) return;

    _cameraController?.startImageStream(_processCameraImage);
    setState(() {});
  }

  void _processCameraImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      // Logic to convert CameraImage to InputImage for ML Kit
      // Then use _faceDetector.processImage(inputImage)
      // Then compare embeddings with stored students
      
      // For now, simulating detection
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isBusy = false;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          _buildOverlay(),
          _buildBottomPanel(),
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: Center(
        child: Container(
          width: 250,
          height: 350,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.secondary, width: 2),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Recognized', '12', AppColors.success),
                _buildStatItem('Remaining', '18', AppColors.warning),
                _buildStatItem('Total', '30', AppColors.primary),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Scanning classroom...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text(
              'Slowly pan the camera across all students',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Finish attendance and show summary
              },
              child: const Text('Finish Attendance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
