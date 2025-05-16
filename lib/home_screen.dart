import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'camera_screen.dart';
import 'call_screen.dart';
import 'survey_chatbot_with_hospital.dart';
import 'home_chat_screen.dart';

Color getBackgroundColor(int uv) {
  if (uv <= 2) return Colors.green.shade500;
  if (uv <= 5) return Colors.yellow.shade600;
  return Colors.red.shade400;
}

String getEmotionFace(int uv) {
  if (uv <= 2) return "😄";
  if (uv <= 5) return "😐";
  return "😨";
}

String getStatusMessage(int uv) {
  if (uv <= 2) return "It’s safe outside!";
  if (uv <= 5) return "Be cautious!";
  return "Avoid the sun!";
}

class HomeScreen extends StatefulWidget {
  final String? diseaseLabel;
  const HomeScreen({Key? key, this.diseaseLabel}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? uvIndex;
  String region = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUVIndex();
  }

  Future<void> fetchUVIndex() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final lat = position.latitude;
      final lon = position.longitude;

      final apiKey = dotenv.env['UV_API_KEY']!;
      final url = 'https://api.openweathermap.org/data/2.5/uvi?lat=$lat&lon=$lon&appid=$apiKey';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔥 영어 주소 요청
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon, localeIdentifier: "en");
        String cityName = "Unknown";
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          cityName = p.locality?.isNotEmpty == true
              ? p.locality!
              : (p.subAdministrativeArea?.isNotEmpty == true
              ? p.subAdministrativeArea!
              : (p.administrativeArea ?? "Unknown"));
        }

        setState(() {
          uvIndex = data['value'].round();
          region = cityName;
        });
      } else {
        throw Exception('Failed to fetch UV index');
      }
    } catch (e) {
      print("Error fetching UV Index or region: $e");
      setState(() {
        uvIndex = 100;
        region = "Unknown";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (uvIndex == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Color backgroundColor = getBackgroundColor(uvIndex!);
    String face = getEmotionFace(uvIndex!);
    String message = getStatusMessage(uvIndex!);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double containerHeight = constraints.maxHeight * 0.5;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Center(
                  child: Text(
                    region,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(offset: Offset(3, 3), blurRadius: 4.0, color: Colors.black12),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(face, style: TextStyle(fontSize: 90)),
                SizedBox(height: 12),
                Text(
                  "UV: $uvIndex",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(offset: Offset(2, 2), blurRadius: 4.0, color: Colors.black12),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: containerHeight,
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Text(
                        message,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      SizedBox(height: 8),
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CameraScreen()),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: backgroundColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("🔎", style: TextStyle(fontSize: 28)),
                                        SizedBox(height: 4),
                                        Text("Check your skin", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HomeChatScreen(diseaseLabel: widget.diseaseLabel ?? "bkl"),
                                        ),
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.only(right: 4),
                                        decoration: BoxDecoration(
                                          color: backgroundColor.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("💬", style: TextStyle(fontSize: 28)),
                                              Text("ChatBot", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => CallScreen()),
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.only(left: 4),
                                        decoration: BoxDecoration(
                                          color: backgroundColor.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("📞", style: TextStyle(fontSize: 28)),
                                              Text("Call Dr.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
