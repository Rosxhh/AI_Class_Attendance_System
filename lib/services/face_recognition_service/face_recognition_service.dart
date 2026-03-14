import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class FaceRecognitionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<List<Face>> detectFaces(InputImage inputImage) async {
    return await _faceDetector.processImage(inputImage);
  }

  // Note: In a real production app, you would use a TFLite model (like MobileFaceNet)
  // to extract embeddings (List<double>) from the face crop and compare them.
  // This is a simplified version for the purpose of the structure.
  
  double compareFaces(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) return 1.0;
    
    double sum = 0;
    for (int i = 0; i < embedding1.length; i++) {
      sum += pow(embedding1[i] - embedding2[i], 2);
    }
    return sqrt(sum); // Euclidean distance
  }

  void dispose() {
    _faceDetector.close();
  }
}
