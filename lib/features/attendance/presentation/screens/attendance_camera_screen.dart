import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/camera_utils.dart';
import '../../../../services/face_recognition_service/face_recognition_service.dart';
import '../../../../services/firebase_service/firebase_provider.dart';
import '../../../students/domain/models/student_model.dart';
import 'attendance_summary_screen.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/attendance_model.dart';

class AttendanceCameraScreen extends ConsumerStatefulWidget {
  const AttendanceCameraScreen({super.key});

  @override
  ConsumerState<AttendanceCameraScreen> createState() => _AttendanceCameraScreenState();
}

class _AttendanceCameraScreenState extends ConsumerState<AttendanceCameraScreen> {
  CameraController? _controller;
  bool _isBusy = false;
  final FaceRecognitionService _faceService = FaceRecognitionService();
  
  List<StudentModel> _allStudents = [];
  final Set<String> _presentStudentIds = {};
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    _allStudents = await firebaseService.getStudents().first;
    _totalStudents = _allStudents.length;
    
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras[0], 
      ResolutionPreset.high, 
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // Better for ML Kit on Android
    );
    
    await _controller?.initialize();
    
    _controller?.startImageStream(_processCameraImage);
    if (mounted) setState(() {});
  }

  void _processCameraImage(CameraImage image) async {
    if (_isBusy || _controller == null) return;
    _isBusy = true;

    try {
      final inputImage = CameraUtils.inputImageFromCameraImage(image, _controller!.description);
      if (inputImage == null) return;

      final faces = await _faceService.detectFaces(inputImage);
      
      if (faces.isNotEmpty) {
        // AI Matching Logic
        for (var student in _allStudents) {
          if (!_presentStudentIds.contains(student.id)) {
            // In a real TFLite implementation, you compare face embeddings here.
            // For this flow, we mark the student found in the list.
            _markPresent(student);
            break; 
          }
        }
      }
    } catch (e) {
      debugPrint('Face Processing Error: $e');
    } finally {
      _isBusy = false;
    }
  }

  void _markPresent(StudentModel student) {
    if (!_presentStudentIds.contains(student.id)) {
      setState(() {
        _presentStudentIds.add(student.id);
      });
      // Show Toast as requested
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${student.name} marked present'),
          duration: const Duration(seconds: 1),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _finishAttendance() async {
    await _controller?.stopImageStream();
    
    final absentIds = _allStudents
        .where((s) => !_presentStudentIds.contains(s.id))
        .map((s) => s.id)
        .toList();

    final session = AttendanceSession(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      totalStudents: _totalStudents,
      presentCount: _presentStudentIds.length,
      presentStudentIds: _presentStudentIds.toList(),
      absentStudentIds: absentIds,
    );

    await ref.read(firebaseServiceProvider).saveAttendanceSession(session);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AttendanceSummaryScreen(session: session)),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          _buildOverlay(),
          _buildHeader(),
          _buildBottomCounter(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 280,
              height: 350,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                children: [
                   // Corner borders for a "scanner" look
                   _buildCorner(top: 0, left: 0),
                   _buildCorner(top: 0, right: 0),
                   _buildCorner(bottom: 0, left: 0),
                   _buildCorner(bottom: 0, right: 0),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Align face within the frame', 
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({double? top, double? left, double? right, double? bottom}) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: top == 0 ? const BorderSide(color: AppTheme.secondaryColor, width: 4) : BorderSide.none,
            left: left == 0 ? const BorderSide(color: AppTheme.secondaryColor, width: 4) : BorderSide.none,
            right: right == 0 ? const BorderSide(color: AppTheme.secondaryColor, width: 4) : BorderSide.none,
            bottom: bottom == 0 ? const BorderSide(color: AppTheme.secondaryColor, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('Live Scanner', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: _finishAttendance,
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCounter() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CounterItem(label: 'Total Students', value: _totalStudents.toString()),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _CounterItem(label: 'Present', value: _presentStudentIds.length.toString(), color: AppTheme.successColor),
            Container(width: 1, height: 40, color: Colors.grey.shade300),
            _CounterItem(label: 'Remaining', value: (_totalStudents - _presentStudentIds.length).toString(), color: AppTheme.errorColor),
          ],
        ),
      ),
    );
  }
}

class _CounterItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _CounterItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color ?? AppTheme.primaryColor)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
      ],
    );
  }
}
