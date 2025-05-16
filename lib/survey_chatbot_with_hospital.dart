import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:new_solarc/models/survey_questions.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

const String apiKey = 'AIzaSyA2JkMh9phker4s0dOSRpNOUCw9FmZS9Uc';

class SurveyChatbotWithHospital extends StatefulWidget {
  final String diseaseLabel;
  const SurveyChatbotWithHospital({Key? key, required this.diseaseLabel}) : super(key: key);

  @override
  _SurveyChatbotWithHospitalState createState() => _SurveyChatbotWithHospitalState();
}

class _SurveyChatbotWithHospitalState extends State<SurveyChatbotWithHospital> {
  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  List<Map<String, String>> chatHistory = [];
  Map<String, String> answers = {};
  bool isLoading = true;
  bool isSubmitting = false;
  late Position userPosition;
  final ScrollController _scrollController = ScrollController();
  final Set<String> addedPlaceIds = {};

  @override
  void initState() {
    super.initState();
    loadLocalSurvey();
  }

  void loadLocalSurvey() {
    final disease = widget.diseaseLabel;
    final loadedQuestions = getSurveyQuestions(disease, isKorean: false);
    if (loadedQuestions != null) {
      questions = loadedQuestions;
      chatHistory.add({"bot": questions[0]['question']});
    } else {
      chatHistory.add({"bot": "No survey questions found for disease code: $disease"});
    }
    setState(() => isLoading = false);
  }

  void handleAnswer(String answer) async {
    final questionId = questions[currentIndex]['id'].toString();
    setState(() {
      answers[questionId] = answer;
      chatHistory.add({"user": answer});
    });

    await Future.delayed(Duration(milliseconds: 500));

    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex++;
        chatHistory.add({"bot": questions[currentIndex]['question']});
      });
    } else {
      setState(() {
        isSubmitting = true;
        chatHistory.add({"bot": "✅ Survey completed. Preparing hospital info and consultation..."});
      });
      await fetchUserLocation();
      await fetchNearbyHospitals();
      setState(() => isSubmitting = false);
    }

    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> fetchUserLocation() async {
    await Geolocator.requestPermission();
    userPosition = await Geolocator.getCurrentPosition();
  }

  Future<void> fetchNearbyHospitals() async {
    final List<int> searchRadii = [3000, 5000, 10000];
    int displayedCount = 0;

    for (int radius in searchRadii) {
      final url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${userPosition.latitude},${userPosition.longitude}&radius=$radius&keyword=피부과%20OR%20성형외과&language=ko&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      final jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 'OK') {
        final results = jsonData['results'];

        for (var place in results) {
          final placeId = place['place_id'];
          final name = place['name'];

          if (addedPlaceIds.contains(placeId)) continue;
          if (name.contains("요양병원")) continue;
          if (!name.contains("피부과") && !name.contains("성형외과")) continue;

          addedPlaceIds.add(placeId);
          displayedCount++;

          final lat = place['geometry']['location']['lat'];
          final lng = place['geometry']['location']['lng'];
          final mapUrl =
              'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=400x200&markers=color:red%7C$lat,$lng&key=$apiKey';

          final phone = await fetchPhoneNumber(placeId);

          final actionJson = jsonEncode({
            "call": {"label": "Call", "type": "call", "value": phone ?? ""},
            "jitsi": {"label": "Video Call", "type": "jitsi", "value": name}
          });

          setState(() {
            chatHistory.add({"bot": "🏥 $name"});
            chatHistory.add({"map": mapUrl});
            chatHistory.add({"action_pair": actionJson});
          });

          if (displayedCount >= 3) return;
        }
      }
    }

    if (displayedCount == 0) {
      setState(() {
        chatHistory.add({"bot": "😥 근처에 피부과나 성형외과 병원을 찾을 수 없습니다."});
      });
    }
  }

  Future<String?> fetchPhoneNumber(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_phone_number&language=ko&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    return json['result']?['formatted_phone_number'];
  }

  Future<void> launchPhone(String number) async {
    if (number.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("전화번호가 등록되지 않았습니다.")),
      );
      return;
    }
    final uri = Uri.parse('tel:$number');
    if (await launcher.canLaunchUrl(uri)) {
      await launcher.launchUrl(uri);
    } else {
      print('❌ 전화 실행 실패: $uri');
    }
  }

  Future<void> launchJitsiMeeting(String hospitalName) async {
    final roomId = hospitalName.replaceAll(' ', '_') + "_room";
    await JitsiMeetWrapper.joinMeeting(
      options: JitsiMeetingOptions(
        roomNameOrUrl: roomId,
        subject: '$hospitalName Video Call',
        userDisplayName: 'Patient',
        userEmail: 'patient@example.com',
        isAudioMuted: false,
        isVideoMuted: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SolarC ☀️"), centerTitle: true),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final entry = chatHistory[index];
                if (entry.containsKey("bot")) {
                  return ChatBubble(
                    message: entry["bot"]!,
                    isUser: false,
                    profileImage: 'assets/images/chatbot_image.jpg',
                  );
                } else if (entry.containsKey("user")) {
                  return ChatBubble(
                    message: entry["user"]!,
                    isUser: true,
                  );
                } else if (entry.containsKey("map")) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Image.network(entry["map"]!),
                  );
                } else if (entry.containsKey("action_pair")) {
                  final data = jsonDecode(entry["action_pair"]!);
                  final call = data["call"];
                  final jitsi = data["jitsi"];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => launchPhone(call["value"]),
                            icon: Icon(Icons.call, color: Colors.white),
                            label: Text(call["label"], style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF5C6BC0),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => launchJitsiMeeting(jitsi["value"]),
                            icon: Icon(Icons.videocam, color: Colors.white),
                            label: Text(jitsi["label"], style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF26A69A),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          if (!isSubmitting && currentIndex < questions.length)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAnswerButton(Icons.check_circle, "Yes", Color(0xFF43A047), () => handleAnswer("yes")),
                  _buildAnswerButton(Icons.cancel, "No", Color(0xFFE53935), () => handleAnswer("no")),
                ],
              ),
            ),
          if (isSubmitting)
            Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(fontSize: 18, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? profileImage;

  const ChatBubble({required this.message, required this.isUser, this.profileImage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && profileImage != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(profileImage!),
              ),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.teal[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: MarkdownBody(
                data: message,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(fontSize: 16),
                  strong: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
