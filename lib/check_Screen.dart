import 'dart:io';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'survey_chatbot_with_hospital.dart';
import 'call_screen.dart';

class CheckScreen extends StatelessWidget {
  final String result;
  final String imagePath;

  const CheckScreen({super.key, required this.result, required this.imagePath});

  final Map<String, String> diagnosisDescriptions = const {
    'Actinic Keratosis': 'Actinic keratosis is a rough, scaly patch on the skin caused by years of sun exposure. It most often appears on the face, ears, neck, scalp, or hands. While it is not cancer, it has the potential to turn into squamous cell carcinoma if left untreated.',
    'Basal Cell Carcinoma': 'Basal cell carcinoma is the most common type of skin cancer. It grows slowly and rarely spreads to other parts of the body. Early detection and treatment are important to prevent tissue damage or disfigurement.',
    'Benign Keratosis': 'Benign keratosis includes non-cancerous skin lesions such as seborrheic keratosis and solar lentigines. These spots may appear brown, black, or tan and often have a warty or waxy texture. They are harmless and usually do not require treatment.',
    'Melanocytic Nevus': 'A melanocytic nevus, commonly known as a mole, is a benign cluster of pigment-producing cells. Most moles are harmless, but changes in size, shape, or color may be signs of skin cancer and should be examined by a doctor.',
    'Melanoma': 'Melanoma is a serious and potentially deadly form of skin cancer that arises from pigment cells. It can spread quickly to other organs if not treated early. Warning signs include asymmetrical moles, irregular borders, and varied colors.',
    'Dermatofibroma': 'Dermatofibroma is a small, firm bump that usually appears on the skin of the legs, arms, or upper back. It is caused by a buildup of fibrous tissue and is typically harmless, though it may be itchy or tender.',
    'Vascular Lesion': 'Vascular lesions include a group of benign blood vessel-related conditions, such as hemangiomas and angiomas. They may appear as red, purple, or blue spots on the skin. Most vascular lesions are not dangerous and may fade over time or remain stable.',
  };

  String getDiagnosisExplanation(String result) {
    for (var entry in diagnosisDescriptions.entries) {
      if (result.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return 'No detailed explanation available for this result.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check your skin"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Your skin seems ...',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                result,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                getDiagnosisExplanation(result),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 18),
              const Text(
                '⚠️ Warning: Please consult a doctor for proper diagnosis.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 18),
              const Text(
                'This result is for reference only.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurveyChatbotWithHospital(diseaseLabel: result),
                        ),
                      );
                    },
                    child: Container(
                      width: 130,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.pink[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Column(
                        children: [
                          Text("💬", style: TextStyle(fontSize: 20)),
                          SizedBox(height: 4),
                          Text("Chat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CallScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 130,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.pink[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Column(
                        children: [
                          Text("📞", style: TextStyle(fontSize: 20)),
                          SizedBox(height: 4),
                          Text("Call", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
