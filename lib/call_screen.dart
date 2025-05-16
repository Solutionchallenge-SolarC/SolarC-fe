import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiKey = dotenv.env['GOOGLE_API_KEY']!;
final String backendUrl = dotenv.env['BACKEND_URL']!;


class CallScreen extends StatefulWidget {
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(35.1595, 126.8526);
  Set<Marker> _markers = {};
  Map<String, dynamic>? selectedHospital;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) await Geolocator.openLocationSettings();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 16.0));
    await _fetchNearbyClinics(_currentPosition);
  }

  Future<void> _fetchNearbyClinics(LatLng position) async {
    if (_isFetching) return;
    _isFetching = true;

    final List<int> searchRadii = [3000, 5000, 10000, 20000];
    Set<String> addedPlaceIds = {};
    bool foundAny = false;

    for (int radius in searchRadii) {
      final url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=$radius&keyword=\uD53C\uBD80\uACFC%20OR%20\uC131\uD615\uC678\uACFC&language=ko&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      final json = jsonDecode(response.body);

      if (json['status'] == 'OK') {
        final results = json['results'] as List;
        Set<Marker> newMarkers = {};

        for (var place in results) {
          final name = place['name'] ?? '';
          final lat = place['geometry']['location']['lat'];
          final lng = place['geometry']['location']['lng'];
          final placeId = place['place_id'];

          if (addedPlaceIds.contains(placeId)) continue;
          addedPlaceIds.add(placeId);
          foundAny = true;

          newMarkers.add(
            Marker(
              markerId: MarkerId(placeId),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: name,
                onTap: () => _showPlaceDetails(placeId),
              ),
            ),
          );
        }

        setState(() {
          _markers = newMarkers;
        });

        if (foundAny) break;
      }
    }

    if (!foundAny) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('\uD83D\uDE25 \uADFC\uCC98\uC5D0 \uD53C\uBD80\uACFC\uB098 \uC131\uD615\uC678\uACFC \uBCD1\uC6D0\uC744 \uCC3E\uC744 \uC218 \uC5C6\uC2B5\uB2C8\uB2E4.')),
      );
      setState(() {
        selectedHospital = null;
      });
    }

    _isFetching = false;
  }

  Future<void> _showPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,formatted_address,formatted_phone_number,website&language=ko&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    if (json['status'] == 'OK') {
      setState(() {
        selectedHospital = json['result'];
      });
    }
  }

  Future<void> _callDoctor(String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("전화번호가 등록되지 않았습니다.")),
      );
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('❌ 전화 실행 실패: $uri');
    }
  }

  Future<void> _startTelemedicine(String hospitalName) async {
    final roomInfo = await _fetchRoomInfo(hospitalName);
    if (roomInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ 화상 진료 정보를 가져오지 못했습니다.")),
      );
      return;
    }
    String roomId = roomInfo['meeting_code'] ?? '${hospitalName.replaceAll(' ', '_')}_room';

    await Future.delayed(Duration(milliseconds: 500));

    await JitsiMeetWrapper.joinMeeting(
      options: JitsiMeetingOptions(
        roomNameOrUrl: roomId,
        subject: '$hospitalName 화상 진료',
        userDisplayName: '환자',
        userEmail: 'patient@example.com',
        isAudioMuted: false,
        isVideoMuted: false,
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchRoomInfo(String hospitalName) async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/room-info?hospital_name=$hospitalName'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      print('❌ roomInfo 가져오기 실패: $e');
    }
    return null;
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Dr.'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 16.0),
              markers: _markers,
              myLocationEnabled: true,
              onCameraIdle: () async {
                if (mapController != null) {
                  final center = await mapController!.getLatLng(
                    ScreenCoordinate(
                      x: MediaQuery.of(context).size.width ~/ 2,
                      y: MediaQuery.of(context).size.height ~/ 2,
                    ),
                  );
                  await _fetchNearbyClinics(center);
                }
              },
            ),
          ),
          if (selectedHospital != null)
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selectedHospital!['name'] ?? '병원 이름 없음', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('주소: ${selectedHospital!['formatted_address'] ?? '정보 없음'}'),
                  Text('전화: ${selectedHospital!['formatted_phone_number'] ?? '정보 없음'}'),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _callDoctor(selectedHospital!['formatted_phone_number']),
                        child: Text('Call'),
                      ),
                      TextButton(
                        onPressed: () => _startTelemedicine(selectedHospital!['name'] ?? ''),
                        child: Text('Telemedicine'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}