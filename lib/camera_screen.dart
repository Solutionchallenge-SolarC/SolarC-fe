import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'check_Screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> cameras;
  CameraController? controller;
  bool isRearCameraSelected = true;
  bool _isCameraDisposed = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(
      isRearCameraSelected ? cameras[0] : cameras[1],
      ResolutionPreset.medium,
    );
    try {
      await controller!.initialize();
      if (mounted && !_isCameraDisposed) {
        setState(() {});
      }
    } catch (e) {
      print("❌ Camera initialization error: $e");
    }
  }

  @override
  void dispose() {
    _isCameraDisposed = true;
    controller?.dispose();
    super.dispose();
  }

  void switchCamera() async {
    _isCameraDisposed = true;
    await controller?.dispose();

    isRearCameraSelected = !isRearCameraSelected;

    _isCameraDisposed = false; // ✅ 이 위치로 변경
    await _initCamera();
  }

  Future<void> takePictureAndAnalyze() async {
    if (controller == null || !controller!.value.isInitialized || _isCameraDisposed) return;

    final photo = await controller!.takePicture();
    final file = File(photo.path);

    print("📸 사진 경로: ${photo.path}");

    try {
      await controller?.dispose();
      _isCameraDisposed = true;

      final result = await analyzeImageWithFastAPI(file.path);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CheckScreen(
            result: result,
            imagePath: file.path,
          ),
        ),
      );
    } catch (e) {
      print("❌ 분석 실패: $e");
    }
  }

  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print("🖼️ 갤러리에서 선택된 사진: ${pickedFile.path}");
      final result = await analyzeImageWithFastAPI(pickedFile.path);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CheckScreen(
            result: result,
            imagePath: pickedFile.path,
          ),
        ),
      );
    } else {
      print("❗갤러리에서 사진 선택 취소됨");
    }
  }

  Future<String> analyzeImageWithFastAPI(String imagePath) async {
    final uri = Uri.parse("https://da4d-2001-2d8-f137-de5d-bcf5-35-b12a-5b58.ngrok-free.app/predict");

    final request = http.MultipartRequest('POST', uri)
      ..fields['threshold'] = '0.5'
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    try {
      final response = await request.send().timeout(Duration(seconds: 60));
      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        print("📥 서버 응답 본문: ${res.body}");

        final data = jsonDecode(res.body);

        final top = data['top_prediction'];
        if (top != null && top['label'] != null) {
          return top['label'];
        }

        if (data['predictions'] != null) {
          final preds = Map<String, dynamic>.from(data['predictions']);
          if (preds.isNotEmpty) {
            final topEntry = preds.entries.reduce(
                  (a, b) => (a.value as num) > (b.value as num) ? a : b,
            );
            return topEntry.key;
          }
        }

        return "Unknown";
      } else {
        return "❌ Server error (${response.statusCode})";
      }
    } on TimeoutException {
      return "❌ Timeout";
    } catch (e) {
      return "❌ Error: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Check your skin", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Expanded(
            child: (controller != null &&
                controller!.value.isInitialized &&
                !_isCameraDisposed)
                ? CameraPreview(controller!)
                : Center(child: CircularProgressIndicator()),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 왼쪽: Select
                Expanded(
                  child: GestureDetector(
                    onTap: pickImageFromGallery,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.photo_library, size: 32),
                        Text("Select"),
                      ],
                    ),
                  ),
                ),

                // 가운데: Camera 버튼
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: takePictureAndAnalyze,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                // 오른쪽: Turn around
                Expanded(
                  child: GestureDetector(
                    onTap: switchCamera,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flip_camera_android, size: 32),
                        Text("Turn around"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "Call"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notification"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
