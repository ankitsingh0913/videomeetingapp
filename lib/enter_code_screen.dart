import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:videomeetingapp/tokenservices.dart';
import 'package:videosdk/videosdk.dart';
import 'new_room_screen.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  TextEditingController _controller = TextEditingController();
  Room? _room;
  Map<String, Participant> participants = {};
  String? joined;

  void joinRoom(String roomId) async {
    try {
      String token = await TokenService.getToken();
      _room = VideoSDK.createRoom(
        roomId: roomId,
        token: token,
        displayName: "Ankit's Org",
        micEnabled: true,
        camEnabled: true,
        defaultCameraIndex: 1,
      );

      setRoomEventListener();
      _room?.join();
    } catch (error) {
      print('Error fetching token: $error');
    }
  }

  void setRoomEventListener() {
    _room?.on(Events.roomJoined, () {
      setState(() {
        joined = "JOINED";
        participants.putIfAbsent(_room!.localParticipant.id, () => _room!.localParticipant);
      });
    });

    _room?.on(Events.participantJoined, (Participant participant) {
      setState(() => participants.putIfAbsent(participant.id, () => participant));
    });

    _room?.on(Events.participantLeft, (String participantId) {
      if (participants.containsKey(participantId)) {
        setState(() => participants.remove(participantId));
      }
    });

    _room?.on(Events.roomLeft, () {
      participants.clear();
      Navigator.popUntil(context, ModalRoute.withName('/'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join Meeting"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                  labelText: "Example : abc-efg-dhi",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  joinRoom(_controller.text);
                  setState(() {
                    joined = "JOINING";
                  });
                },
                child: Text(
                  "Join",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(100, 45),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              Divider(
                thickness: 2,
                color: Colors.grey[400],
                indent: 40,
                endIndent: 40,
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => CreateMeeting(participants: participants));
                },
                child: Text(
                  "Create a Meeting",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(300, 45),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
