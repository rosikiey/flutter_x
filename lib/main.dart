import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_detection_demo/face_detector_painter.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Face Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Face Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var pathPhoto = '';
  var isLoading = false;
  var widthImage = 0.0;
  var heightImage = 0.0;
  var faces = <Face>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          /// Ambil gambar dari galeri
          final imagePicker = await ImagePicker().pickImage(source: ImageSource.gallery);

          /// Pastikan bahwa gambarnya valid
          if (imagePicker != null) {
            /// Tampilkan loading
            setState(() => isLoading = true);

            /// Ambil path image-nya
            pathPhoto = imagePicker.path;

            /// Ambil nilai width dan height dari gambar
            final imageBytes = await File(pathPhoto).readAsBytes();
            final image = await decodeImageFromList(imageBytes);
            widthImage = image.width.toDouble();
            heightImage = image.height.toDouble();

            /// Buat objek GoogleVisionImage dengan datanya adalah gambar yang kita ambil dari galeri
            final googleVisionImage = GoogleVisionImage.fromFilePath(pathPhoto);

            /// Buat objek FaceDetector
            final faceDetector = GoogleVision.instance.faceDetector();

            /// Jalankan proses untuk deteksi wajahnya
            faces.clear();
            faces = await faceDetector.processImage(googleVisionImage);

            /// Tampilkan pesan apakah wajahnya terdeteksi atau tidak
            if (faces.isEmpty) {
              showDialogMessage('Wajah tidak terdeteksi');
            } else {
              showDialogMessage('Wajah terdeteksi');
            }

            /// Sembunyikan loading
            setState(() => isLoading = false);
          }
        },
      ),
      body: buildWidgetBody(),
    );
  }

  Widget buildWidgetBody() {
    /// Tampilkan loading ditengah-tengah layar
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    /// Tampilkan info bahwa tidak ada foto yang diambil
    if (pathPhoto.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Silakan ambil foto dulu ya\n'
                'dengan cara tekan tombol tambah di bagian kanan bawah',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    /// Tampilkan foto yang kita ambil dari kamera atau galeri
    return Center(
      child: CustomPaint(
        foregroundPainter: FaceDetectorPainter(
          Size(widthImage, heightImage),
          faces,
          isReflection: true,
        ),
        child: Image.file(
          File(
            pathPhoto,
          ),
        ),
      ),
    );
  }

  void showDialogMessage(String message) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Info'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('Ok'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Info'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
